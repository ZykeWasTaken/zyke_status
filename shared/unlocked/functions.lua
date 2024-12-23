-- Separate the name if it has multi
--[[
    By grabbing a single, you can simply do GetStatus("stress")
    If you wish to grab a multi, such as addiction, you have to do GetStatus("addiction.weed")
]]

---@param name StatusName
---@return string, string
function SeparateStatusName(name)
    local primary, secondary = name:match("([^%.]+)%.([^%.]+)")
    if (not primary) then return name, name end -- If no primary can be found, there is no dot separator

    return primary, secondary
end