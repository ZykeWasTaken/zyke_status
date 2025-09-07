---@type ServerCache
Cache = {
    statuses = {},
    directEffects = {},
    existingStatuses = {},
}

-- We have to call the SetMetaData export directly to have the correct invoker
UsingQbox = GetResourceState("qbx_core") == "started" and true or false

-- Populate this once all status configs have loaded
-- SInce this main file starts early for the cache to exist, there could be timing
---@type table<PrimaryName, {[SecondaryName]: {interval: number, lastUpdated: OsTime}}>
local statusTimeouts = {}

-- Track all of the high priority statuses that needs a tighter loop
---@type table<PrimaryName, {[SecondaryName]: boolean}>
local highPriorityStatuses = {}

-- Ensuring that a player is in here every time
---@type table<PlayerId, boolean>
local priorityPlayers = {}

---@param plyId PlayerId
function AddPriorityPlayer(plyId)
    priorityPlayers[plyId] = true
end

---@param plyId PlayerId
function RemovePriorityPlayer(plyId)
    priorityPlayers[plyId] = nil
end

-- Returns whether the player should be in the priority list or not
-- Iterates all of the high priority statuses and checks if the player has any of them
---@param plyId PlayerId
---@return boolean
function ShouldBePriorityPlayer(plyId)
    local plyStatuses = Cache.statuses[plyId]
    if (not plyStatuses) then return false end

    for primary, subStatuses in pairs(highPriorityStatuses) do
        for subName, _ in pairs(subStatuses) do
            if (plyStatuses[primary]?.values?[subName]?.value and plyStatuses[primary].values[subName].value > 0.0) then
                return true
            end
        end
    end

    return false
end

---@param primary PrimaryName
---@param secondary SecondaryName
---@return boolean
function IsStatusPriority(primary, secondary)
    local highPriority = highPriorityStatuses[primary]
    if (not highPriority) then return false end

    return highPriority[secondary] or false
end

local baseInterval = Config.Settings.threadInterval.baseInterval

-- Triggered when a primary status is registered, or secondary is ensured, and we figure out what type of timer it needs
-- Different statuses needs different timers because of the drain
-- Most statuses take ages to drain, and draining it every few minutes won't make a difference
-- But some statuses, like n2o high, need to be drained every few seconds since it is a quick high
---@param primary PrimaryName
function PopulateStatusTimeout(primary)
    local subStatuses = Cache.existingStatuses[primary].subStatuses
    if (not subStatuses) then return end

    statusTimeouts[primary] = {}
    for secName in pairs(subStatuses) do
        if (statusTimeouts[primary][secName]) then goto continue end

        local drain = Config.Status[primary][secName]?.value?.drain or Config.Status[primary]?.base?.value?.drain
        if (drain == nil) then goto continue end -- Some statuses don't have a drain

        local highPriority = drain and drain > 0.1
        local timer = highPriority and 1.0 or baseInterval

        statusTimeouts[primary][secName] = {interval = timer, lastUpdated = os.time()}

        if (highPriority) then
            if (not highPriorityStatuses[primary]) then highPriorityStatuses[primary] = {} end

            highPriorityStatuses[primary][secName] = true
        end

        ::continue::
    end
end

-- SecondaryName, multiplier
---@alias PlyStatusesToUpdate {[1]: SecondaryName, [2]: number}

-- Loop the existing statuses and perform onTick for all available players
CreateThread(function()
    local interval = Config.Settings.threadInterval

    local lastDbSave = os.time()
    local plyStatuses = Cache.statuses or {} -- fallback for the linter

    ---@param primary PrimaryName
    ---@param toUpdate SecondaryName[]
    ---@param plyId PlayerId
    ---@param plysToUpdate {[1]: PlayerId, [2]: PlyStatusesToUpdate[]}[]
    ---@param multipliers {[SecondaryName]: number} @Phased out later for individual player multipliers
    local function addPlayerToUpdate(primary, toUpdate, plyId, plysToUpdate, multipliers)
        ---@type PlyStatusesToUpdate[]
        local plyStatusesToUpdate = {}
        local shouldInclude = false

        for i = 1, #toUpdate do
            local val = plyStatuses[plyId][primary]?.values?[toUpdate[i]]?.value
            local hasValue = val ~= nil

            -- Skip if we don't have the status, or if it is at 0
            -- We don't need to process drain for empty values
            if (
                hasValue and
                (val > 0.0 or
                primary == "addiction") -- Another clause for addiction stuff, since that should tick even if it's at 0.0
            ) then
                -- TODO: Storing individual multiplier in here so that we can do individual player multipliers in the future
                local multiplier = multipliers[toUpdate[i]]
                if (multiplier == nil) then multiplier = 1.0 end

                plyStatusesToUpdate[#plyStatusesToUpdate+1] = {toUpdate[i], multiplier}
                shouldInclude = true
            end
        end

        if (shouldInclude) then
            ---@diagnostic disable-next-line: assign-type-mismatch
            plysToUpdate[#plysToUpdate+1] = {plyId, plyStatusesToUpdate}
        end
    end

    -- Every non-priority interval, we refresh the priority players
    -- This is the only way they are removed, after being added via AddToStatus
    local function refreshPriorityPlayers()
        for plyId in pairs(priorityPlayers) do
            if (not ShouldBePriorityPlayer(plyId)) then
                RemovePriorityPlayer(plyId)
            end
        end
    end

    local sleep = 1000

    while (1) do
        Wait(sleep)

        local cachedPlys = Cache.statuses or {}
        local now = os.time()
        local isHighPriority = true

        for primary, subStatuses in pairs(statusTimeouts) do
            ---@type SecondaryName[]
            local toUpdate = {}
            local multipliers = {}

            -- Find out what statuses should be updated this interval
            for subName, values in pairs(subStatuses) do
                local diff = now - values.lastUpdated

                if (diff >= values.interval) then
                    multipliers[subName] = diff

                    values.lastUpdated = now

                    if (isHighPriority) then
                        isHighPriority = IsStatusPriority(primary, subName)
                    end

                    toUpdate[#toUpdate+1] = subName
                end
            end

            -- Verify that there are statuses that needs to be updated this interval
            if (#toUpdate == 0) then goto endOfUpdate end

            ---@type {[1]: PlayerId, [2]: PlyStatusesToUpdate[]}[]
            local plysToUpdate = {}

            -- If high priority, only iterate those players
            if (isHighPriority) then
                for plyId in pairs(priorityPlayers) do
                    addPlayerToUpdate(primary, toUpdate, plyId, plysToUpdate, multipliers)
                end
            else
                -- If enough time has gone by and this is a slow interval hitting, we iterate all players
                for plyId in pairs(cachedPlys) do
                    addPlayerToUpdate(primary, toUpdate, plyId, plysToUpdate, multipliers)
                end
            end

            -- Verify that we actually have someone to process
            if (next(plysToUpdate) == nil) then goto endOfUpdate end

            local onTick = Cache.existingStatuses[primary].onTick
            if (onTick) then
                onTick(plysToUpdate)
            end

            ::endOfUpdate::
        end

        if (not isHighPriority) then
            refreshPriorityPlayers()
        end

        -- We save during logout, but to be safe, save every x amount of seconds
        if (os.time() - lastDbSave > interval.databaseSave) then
            lastDbSave = os.time()
            for plyId in pairs(Cache.statuses) do
                local _plyId = tonumber(plyId)

                if (_plyId) then
                    SavePlayerToDatabase(_plyId)
                end
            end
        end
    end
end)