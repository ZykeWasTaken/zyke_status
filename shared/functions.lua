-- Separate the name if it has multi
--[[
    By grabbing a single, you can simply do GetStatus("stress")
    If you wish to grab a multi, such as addiction, you have to do GetStatus("addiction.weed")
]]

---@param name StatusName
---@return string, string, string
function SeparateStatusName(name)
    local primary, secondary = name:match("([^%.]+)%.([^%.]+)")
    if (not primary) then return name, name, name .. "." .. name end -- If no primary can be found, there is no dot separator

    return primary, secondary, primary .. "." .. secondary
end

---@param name StatusName
function GetStatusSettings(name)
    local prim, sec = SeparateStatusName(name)

    return Config.Status[prim][sec] or Config.Status[prim].base
end

-- Checks the threshold and if you should run the effect
-- Some effects may be reversed, so we define it in here
---@param name StatusName
---@param statusData PlayerStatus | AddictionStatus
function IsWithinEffectThreshold(name, statusData)
    local prim = SeparateStatusName(name)
    local settings = GetStatusSettings(name)

    if (not settings.effect) then return false end

    local reversed = Z.table.new({"addiction"})
    if (reversed:contains(prim)) then
        return statusData.value <= settings.effect.threshold
    else
        return statusData.value >= settings.effect.threshold
    end
end

-- Verifies if the primary exists, because of our dynamic system you can have any substatus, if it is a multi-status
---@param name StatusName
---@return boolean
function IsStatusNameValid(name)
    local prim, sec = SeparateStatusName(name)

    -- TODO: Verify if it is multi-status and if it can be dynamic
    -- If it is not multi, it has to be an exact name match
    -- if it is multi, it just has to match the primary

    return Config.Status[prim] ~= nil
end

---@param tbl
function EnsureValue()

end