function GetAllRawStatuses()
    return Cache.statuses
end

-- Second return is if initialized, certain values needs to be reversed, such as satisfaction rates
-- If the value is not initialized, don't display it, or note that it may be incorrect
-- TODO: Fix and initialize this, so that the client has all the max values
-- Slightly weird way to handle this, but it ensures consistency if a beginner developer is trying to implement this
---@param name StatusName
---@return {value: number} | PlayerStatus | AddictionStatus, boolean
function GetRawStatus(name)
    local primary, secondary = SeparateStatusName(name)

    if (not Cache.statuses) then return {value = 0.0}, false end
    if (not Cache.statuses[primary]) then return {value = 0.0}, false end

    return Cache.statuses[primary].values[secondary], true
end

-- ########## List of shorthand functions to grab common and specific values ########## --

---@return number
exports("GetStress", function()
    return GetRawStatus("stress").value
end)

CreateThread(function()
    while (1) do
        Wait(1000)

        local stress = exports["zyke_status"]:GetStress()
        if (stress > 0.0) then
            print("Stress", stress)
        end
    end
end)