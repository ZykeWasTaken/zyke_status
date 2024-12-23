-- Initializes all values that need to exist, such as players
-- All caches, functions etc have to be defined before

---@param plyId PlayerId
local function initializeStatusesForPlayer(plyId)
    Cache.statuses[plyId] = {}

    local identifier = Z.getIdentifier(plyId)
    if (not identifier) then return end

    local savedStatus = MySQL.single.await("SELECT data from zyke_status WHERE identifier = ?", {identifier})
    local decoded = savedStatus and json.decode(savedStatus)

    for status, statusSettings in pairs(Cache.existingStatuses) do
        -- Base values

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

        -- If you have any saved values
        if (decoded) then
            for _status, statusData in pairs(decoded[status].values) do
                Cache.statuses[plyId][status].values[_status] = {
                    -- TODO: Fix vlaues
                    value = statusData.value or 0.0
                }
            end
        end
    end
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

local players = Z.getPlayers()
for i = 1, #players do
    initializeStatusesForPlayer(players[i])
end