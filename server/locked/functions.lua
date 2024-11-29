
function CreateStatus()

end

-- Separate the name if it has multi
--[[
    By grabbing a single, you can simply do GetStatus("stress")
    If you wish to grab a multi, such as addiction, you have to do GetStatus("addiction.weed")
]]

local function separateName(name)
    return name:match("([^%.]+)%.([^%.]+)")
end

---@param plyId PlayerId
---@param name StatusName
function GetStatus(plyId, name)
    local primary, secondary = separateName(name) -- TODO: Verify what secondary returns, if it is nil or ""
    local base = Cache.statuses[plyId][primary]
    local values = secondary and base.values[secondary] or base.values[primary]
    if (not values) then return nil end
end