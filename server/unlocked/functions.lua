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
function GetRawStatuses(plyId)
    return Cache.statuses[plyId]
end