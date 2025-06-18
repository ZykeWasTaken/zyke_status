function GetAllRawStatuses()
    return Cache.statuses
end

exports("GetAllRawStatuses", GetAllRawStatuses)

-- Second return is if initialized
---@param statusNames StatusNames
---@return {value: number} | PlayerStatus | AddictionStatus, boolean
function GetRawStatus(statusNames)
    local primary, secondary = statusNames[1], statusNames[2] or statusNames[1]

    if (not Cache.statuses) then return {value = 0.0}, false end
    if (not Cache.statuses[primary]) then return {value = 0.0}, false end

    return Cache.statuses[primary].values[secondary], true
end

exports("GetRawStatus", GetRawStatus)