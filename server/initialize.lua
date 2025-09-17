-- Initializes all values that need to exist, such as players
-- All caches, functions etc have to be defined before

-- Hoisting this, gets populated once the base values have been registered
local baseValues = {}

---@param plyId PlayerId
local function ensureBaseStatusValues(plyId)
    Cache.statuses[plyId] = Z.table.copy(baseValues)
end

---@param plyId PlayerId
local function fetchStatusFromDatabase(plyId)
    local identifier = Z.getIdentifier(plyId)
    if (not identifier) then return end

    local dbStatus = MySQL.scalar.await("SELECT data FROM zyke_status WHERE identifier = ?", {identifier})
    local decoded = dbStatus and json.decode(dbStatus)

    -- If nothing is saved, set to the default base values
    if (not decoded) then return ResetStatuses(plyId) end

    -- If saved, apply the values
    for status in pairs(Cache.existingStatuses) do
        if (not Cache.statuses[plyId][status]) then
            Cache.statuses[plyId][status] = {values = {}}
        end

        if (decoded[status]) then
            for _status, statusData in pairs(decoded[status].values) do
                Cache.statuses[plyId][status].values[_status] = statusData
            end
        end
    end
end

---@param plyId PlayerId
local function initializePlayer(plyId)
    Z.debug("Attempting to initialize", plyId)

    ensureBaseStatusValues(plyId)
    fetchStatusFromDatabase(plyId)
    EnsureDirectEffectsFromDatabase(plyId)

    SyncPlayerStatus(plyId, GetAllPrimaryStatuses())
    EnsurePlayerSubStatusesCache(plyId)
end

---@param plyId PlayerId
---@param statusNames StatusNames
function EnsurePlayerSubStatus(plyId, statusNames)
    if (not plyId) then return end
    local status = Cache.statuses[plyId]

    local primary = statusNames[1]
    local secondary = statusNames[2] or statusNames[1]

    if (status) then
        if (not status[primary]) then
            Cache.statuses[plyId][primary] = {values = {}}
        end

        if (not status[primary].values[secondary]) then
            ---@diagnostic disable-next-line: missing-fields
            Cache.statuses[plyId][primary].values[secondary] = {}
        end

        for key, baseValue in pairs(Cache.existingStatuses[primary].baseValues) do
            Cache.statuses[plyId][primary].values[secondary][key] = baseValue
        end
    end

    EnsureSubStatus(primary, secondary)
end

while (not QueriesExecuted) do Wait(10) end

---@param plyId PlayerId
AddEventHandler("zyke_lib:OnCharacterSelect", function(plyId)
    initializePlayer(plyId)
end)

---@param plyId PlayerId
AddEventHandler("zyke_lib:OnCharacterLogout", function(plyId)
    SavePlayerToDatabase(plyId)
    Cache.statuses[plyId] = nil
    Cache.directEffects[plyId] = nil
end)

Wait(1000)

local reversedStatuses = GetReversedStatuses()
for status, values in pairs(Cache.existingStatuses) do
    baseValues[status] = {}

    -- Iterate the defined statuses where baseValues is defined to be above 0

    -- Always skip addiction, since that should not be part of the default stats
    baseValues[status].values = {}
    if (status ~= "addiction") then
        for key, baseValue in pairs(values.baseValues) do
            if (
                reversedStatuses[status] == true and baseValue > 0.0
            ) then
                for secName, statusSett in pairs(Config.Status[status]) do
                    local _secName = values.multi == false and status or secName

                    if (baseValues[status].values[_secName] == nil) then
                        baseValues[status].values[_secName] = {}
                    end

                    baseValues[status].values[_secName][key] = baseValue
                end
            end
        end
    end

    if (Z.table.count(baseValues[status].values) == 0) then
        baseValues[status] = nil
    end
end

local players = Z.getPlayers()
for i = 1, #players do
    initializePlayer(players[i])
end

TriggerClientEvent("zyke_status:HasInitialized", -1)