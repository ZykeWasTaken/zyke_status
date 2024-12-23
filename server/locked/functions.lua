
function CreateStatus()

end

-- Separate the name if it has multi
--[[
    By grabbing a single, you can simply do GetStatus("stress")
    If you wish to grab a multi, such as addiction, you have to do GetStatus("addiction.weed")
]]

---@param name StatusName
local function separateName(name)
    local primary, secondary = name:match("([^%.]+)%.([^%.]+)")
    if (not secondary) then secondary = primary end

    return primary, secondary
end

-- Returns the entire table to modify
-- This will always go through, since every player is initialized
-- The only exception is if the player has not yet selected a character
-- The secondary, if using multi, is not always guaranteed to exist
---@param plyId PlayerId
---@param name StatusName
---@return PlayerStatuses | nil
function GetPlayerBaseStatusTable(plyId, name)
    local primary = separateName(name)

    return Cache.statuses[plyId] and Cache.statuses[plyId][primary] or nil
end

---@param plyId PlayerId
---@param name StatusName
---@return number
function GetStatus(plyId, name)
    local primary, secondary = separateName(name)

    if (not Cache.statuses[plyId]) then return 0.0 end
    if (not Cache.statuses[plyId][primary]) then return 0.0 end

    local value = GetPlayerBaseStatusTable(plyId, name)
    return value and value.values?[secondary]?.value or 0.0
end

exports("GetStatus", GetStatus)

---@param plyId PlayerId
---@param name StatusName
function RemoveFromStatus(plyId, name, amount)
    local primary, secondary = separateName(name)

    -- If the value doesn't exist, just return
    -- If you are removing something, we don't need to handle the value
    local value = GetPlayerBaseStatusTable(plyId, name)
    if (not value) then return end

    EnsurePlayerSubStatus(plyId, primary, secondary)

    value.values[secondary].value -= amount
    if (value.values[secondary].value < 0) then
        value.values[secondary].value = 0
    end
end

-- Add value to the status
---@param plyId PlayerId
---@param name StatusName
---@param amount number
function AddToStatus(plyId, name, amount)
    local primary, secondary = separateName(name)

    local value = GetPlayerBaseStatusTable(plyId, name)
    if (not value) then return end

    EnsurePlayerSubStatus(plyId, primary, secondary)

    value.values[secondary].value += amount
    if (value.values[secondary].value > 100.0) then
        value.values[secondary].value = 100.0
    end
end

RegisterCommand("get_status", function(source, args, raw)
    local status = args[1]
    local amount = GetStatus(source, status)

    print(amount)
end, false)

RegisterCommand("add_to_status", function(source, args)
    local status, amount = args[1], tonumber(args[2])

    AddToStatus(source, status, amount or 1.0)
end, false)