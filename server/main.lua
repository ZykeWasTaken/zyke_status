---@type ServerCache
Cache = {
    statuses = {},
    directEffects = {},
    existingStatuses = {},
}

-- We have to call the SetMetaData export directly to have the correct invoker
UsingQbox = GetResourceState("qbx_core") == "started" and true or false

---@param name string @primary
local function getPlayersForStatus(name)
    local _statuses = Cache.statuses or {}
    local players = {}

    for plyId, statuses in pairs(_statuses) do
        if (statuses[name]) then
            players[plyId] = statuses[name]
        end
    end

    return players
end

-- Loop the existing statuses and perform onTick for all available players
CreateThread(function()
    local interval = Config.Settings.threadInterval

    local lastDbSave = os.time()

    -- Track when the next update should happen, so we can run quicker iterations if needed, since we are otherwise stuck in a long sleep
    local nextUpdate = 0
    local firstUpdate = true

    while (1) do
        local sleep = 1000

        if (nextUpdate < os.time()) then
            -- Decide when we should update all players, for better performance
            -- Processes the same data, but in slower intervals with multipliers for all values
            local additionalWait = 0
            if (interval.playerScaling == true) then
                local totPlys = GetNumPlayerIndices()
                additionalWait = totPlys * interval.playerScalingAddition
            end

            local multiplier = interval.baseInterval + additionalWait
            if (multiplier > interval.databaseSave) then
                multiplier = interval.databaseSave
            end

            nextUpdate = os.time() + multiplier

            if (not firstUpdate) then
                local existingStatuses = Cache.existingStatuses
                for statusName, values in pairs(existingStatuses) do
                    if (values.onTick) then
                        values.onTick(getPlayersForStatus(statusName), multiplier)
                    end
                end
            end

            firstUpdate = false
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

        Wait(sleep)
    end
end)