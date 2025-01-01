-- Shortcuts to common functions, for easier development

---@return number
exports("GetStress", function()
    return GetRawStatus("stress").value
end)

---@return number
exports("GetHunger", function()
    return GetRawStatus("hunger").value
end)

---@return number
exports("GetThirst", function()
    return GetRawStatus("thirst").value
end)