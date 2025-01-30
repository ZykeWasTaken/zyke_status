-- Initializes all values that need to exist, such as players
-- All caches, functions etc have to be defined before

---@param plyId PlayerId
local function ensureBaseStatusValues(plyId)
    Cache.statuses[plyId] = {}

    for status, statusSettings in pairs(Cache.existingStatuses) do
        local values = {}
        if (statusSettings.multi ~= true) then
            values = {
                -- TODO: Fix values
                [status] = {value = 0.0}
            }
        end

        Cache.statuses[plyId][status] = {
            values = values
        }
    end
end

---@param plyId PlayerId
local function fetchStatusFromDatabase(plyId)
    local identifier = Z.getIdentifier(plyId)
    if (not identifier) then return end

    local dbStatus = MySQL.scalar.await("SELECT data FROM zyke_status WHERE identifier = ?", {identifier})
    local decoded = dbStatus and json.decode(dbStatus)

    if (decoded) then
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
end

---@param plyId PlayerId
local function initializePlayer(plyId)
    ensureBaseStatusValues(plyId)
    fetchStatusFromDatabase(plyId)
end

---@param plyId PlayerId
---@param primary StatusName
---@param secondary SubStatusName
function EnsurePlayerSubStatus(plyId, primary, secondary)
    if (not Cache.statuses[plyId][primary].values[secondary]) then
        -- Cache.statuses[plyId][primary].values[secondary] = {value = 0.0}
        Cache.statuses[plyId][primary].values[secondary] = {}

        for key, baseValue in pairs(Cache.existingStatuses[primary].baseValues) do
            Cache.statuses[plyId][primary].values[secondary][key] = baseValue
        end
    end
end

Wait(100)
local players = Z.getPlayers()
for i = 1, #players do
    -- initializeStatusesForPlayer(players[i])
    initializePlayer(players[i])
end

---@param plyId PlayerId
AddEventHandler("zyke_lib:OnCharacterSelect", function(plyId)
    initializePlayer(plyId)
end)

---@param plyId PlayerId
AddEventHandler("zyke_lib:OnCharacterLogout", function(plyId)
    SavePlayerToDatabase(plyId)
    Cache.statuses[plyId] = nil
end)