function CreateStatus()

end

-- Separate the name if it has multi
--[[
    By grabbing a single, you can simply do GetStatus("stress")
    If you wish to grab a multi, such as addiction, you have to do GetStatus("addiction.weed")
]]

---@param name StatusName
function SeparateStatusName(name)
    local primary, secondary = name:match("([^%.]+)%.([^%.]+)")
    if (not primary) then return name, name end -- If no primary can be found, there is no dot separator

    return primary, secondary
end

---@param plyId PlayerId
---@param primary StatusName
function SyncPlayerStatus(plyId, primary)
    TriggerClientEvent("zyke_status:SyncStatus", plyId, primary, Cache.statuses[plyId][primary])
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