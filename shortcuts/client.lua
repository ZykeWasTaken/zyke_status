-- Shortcuts to common functions, for easier development

---@return number
exports("GetStress", function()
    return GetRawStatus({"stress", "stress"}).value
end)

---@return number
exports("GetHunger", function()
    return GetRawStatus({"hunger", "hunger"}).value
end)

---@return number
exports("GetThirst", function()
    return GetRawStatus({"thirst", "thirst"}).value
end)

---@return number
exports("GetDrunk", function()
    return GetRawStatus({"drunk", "drunk"}).value
end)