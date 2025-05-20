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

    -- Modify the base thread speed for better performance
    -- Processes the same data, but in slower intervals with multipliers for all values
    local multiplier = interval.multiplier
    local lastDbSave = os.time()

    while (1) do
        if (interval.playerScaling) then
            local totPlys = GetNumPlayerIndices()

            if (totPlys > 0) then
                local floor, ceiling = interval.multiplier, 180

                multiplier = interval.multiplier + (totPlys * interval.multiplier * interval.playerScaling)

                if (multiplier < floor) then
                    multiplier = floor
                elseif (multiplier > ceiling) then
                    multiplier = ceiling
                end
            else
                multiplier = interval.multiplier > 30 and interval.multiplier or 30
            end
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