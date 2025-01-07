-- TODO Make some zyke_lib feature to add to the statuses

-- This will fetch the base status for your framework
-- This needs to be converted to work with our structure from all different frameworks
---@param player table
---@return table
function GetBasePlayerStatus(player)
    if (Framework == "ESX") then
        local status = {}

        return status
    elseif (Framework == "QB") then
        local status = {}

        return status
    end

    error("MISSING SUPPORTED FRAMEWORK!")

    return {}
end

-- Same as the fetching, we need to make sure the resource is backwards compatible with other systems
-- We take our data and translate it to the base of the framework
---@param status table
---@return table
function CreateBasePlayerStatus(status)
    if (Framework == "ESX") then
        local baseStatus = {}

        return status
    elseif (Framework == "QB") then
        local baseStatus = {}

        return status
    end

    error("MISSING SUPPORTED FRAMEWORK!")

    return {}
end

---@param plyId PlayerId
function GetAllRawStatuses(plyId)
    return Cache.statuses[plyId] or {}
end

---@param plyId PlayerId
---@param primary StatusName | StatusName[]
function SyncPlayerStatus(plyId, primary)
    if (type(primary) ~= "table") then
        primary = {primary}
    end

    local statuses = {}
    for i = 1, #primary do
        local val = Cache.statuses[plyId][primary]
        if (val == nil) then
            val = "nil"
        end

        statuses[primary[i]] = val
    end

    TriggerClientEvent("zyke_status:SyncStatus", plyId, statuses)
end

-- Returns the entire table to modify
-- This will always go through, since every player is initialized
-- The only exception is if the player has not yet selected a character
-- The secondary, if using multi, is not always guaranteed to exist
---@param plyId PlayerId
---@param name StatusName
---@return PlayerStatuses | nil
function GetPlayerBaseStatusTable(plyId, name)
    local primary = SeparateStatusName(name)

    return Cache.statuses[plyId] and Cache.statuses[plyId][primary] or nil
end

---@param plyId PlayerId
---@param name StatusName
---@return number
function GetStatus(plyId, name)
    local primary, secondary = SeparateStatusName(name)

    if (not Cache.statuses[plyId]) then return 0.0 end
    if (not Cache.statuses[plyId][primary]) then return 0.0 end

    local value = GetPlayerBaseStatusTable(plyId, name)
    return value and value.values?[secondary]?.value or 0.0
end

exports("GetStatus", GetStatus)

---@param plyId PlayerId
---@param name StatusName
---@param amount number
function RemoveFromStatus(plyId, name, amount)
    local primary, secondary = SeparateStatusName(name)
    EnsurePlayerSubStatus(plyId, primary, secondary)
    local hasRemoved = Cache.existingStatuses[primary].onRemove(plyId, name, amount)

    if (hasRemoved) then
        SyncPlayerStatus(plyId, primary)
    end
end

exports("RemoveFromStatus", RemoveFromStatus)

-- Add value to the status
---@param plyId PlayerId
---@param name StatusName
---@param amount number
function AddToStatus(plyId, name, amount)
    local primary, secondary = SeparateStatusName(name)
    EnsurePlayerSubStatus(plyId, primary, secondary)
    local hasAdded = Cache.existingStatuses[primary].onAdd(plyId, name, amount)

    if (hasAdded) then
        SyncPlayerStatus(plyId, primary)
    end
end

exports("AddToStatus", AddToStatus)

RegisterCommand("get_status", function(source, args, raw)
    local status = args[1]
    local amount = GetStatus(source, status)

    print(amount)
end, false)

RegisterCommand("add_to_status", function(source, args)
    local status, amount = args[1], tonumber(args[2])

    AddToStatus(source, status, amount or 1.0)
end, false)

---@param plyId PlayerId
---@param name StatusName
function ValidateStatusModification(plyId, name)
    local primary, secondary = SeparateStatusName(name)

    local value = GetPlayerBaseStatusTable(plyId, name)
    if (not value) then return false, nil end

    EnsurePlayerSubStatus(plyId, primary, secondary)

    return true, value, primary, secondary
end

---@param plyId PlayerId
function SavePlayerToDatabase(plyId)
    local statuses = Cache.statuses[plyId]
    if (not statuses) then return end

    local plyIdentifier = Z.getIdentifier(plyId)
    if (not plyIdentifier) then return end

    local data = json.encode(statuses)

    MySQL.query.await("INSERT INTO zyke_status (identifier, data) VALUES (?, ?) ON DUPLICATE KEY UPDATE data = ?", {plyIdentifier, data, data})
end