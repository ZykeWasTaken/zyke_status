---@type ServerCache
Cache = {
    statuses = {},
    directEffects = {},
    existingStatuses = {},
}

-- We have to call the SetMetaData export directly to have the correct invoker
UsingQbox = GetResourceState("qbx_core") == "started" and true or false

---@param name string @primary
local function getPlayersForStatus(name)
    local _statuses = Cache.statuses or {}
    local players = {}

    for plyId, statuses in pairs(_statuses) do
        if (statuses[name]) then
            players[plyId] = statuses[name]
        end
    end

    return players
end

-- Loop the existing statuses and perform onTick for all available players
CreateThread(function()
    local baseSpeed = 1000 -- Do not touch
    local interval = Config.Settings.threadInterval

    local lastDbSave = os.time()

    while (1) do
        -- Modify the base thread speed for better performance
        -- Processes the same data, but in slower intervals with multipliers for all values
        local additionalWait = 0
        if (interval.playerScaling == true) then
            local totPlys = GetNumPlayerIndices()
            additionalWait = totPlys * interval.playerScalingAddition
        end

        local multiplier = interval.baseInterval + additionalWait
        if (multiplier > interval.databaseSave) then
            multiplier = interval.databaseSave
        end

        local sleep = baseSpeed * multiplier

        Wait(sleep)

        local existingStatuses = Cache.existingStatuses
        for statusName, values in pairs(existingStatuses) do
            if (values.onTick) then
                values.onTick(getPlayersForStatus(statusName), multiplier)
            end
        end

        -- We save during logout, but to be safe, save every x amount of seconds
        if (os.time() - lastDbSave > interval.databaseSave) then
            lastDbSave = os.time()
            for plyId in pairs(Cache.statuses) do
                local _plyId = tonumber(plyId)

                if (_plyId) then
                    SavePlayerToDatabase(_plyId)
                end
            end
        end
    end
end)