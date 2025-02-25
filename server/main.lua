---@type ServerCache
Cache = {
    statuses = {},
    existingStatuses = {},
}

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
    local playerScale = Config.Settings.automaticIntervalScaling

    -- Modify the base thread speed for better performance
    -- Processes the same data, but in slower intervals with multipliers for all values
    -- Thread works fine in 1 multiplier, processes ~100 players at ~0.04ms
    local baseSpeed = 1000 -- Do not touch
    local multiplier = 3

    local lastDbSave = os.time()
    local dbSaveInterval = 180 -- s

    while (1) do
        if (playerScale) then
            local totalPlayers = GetNumPlayerIndices()

            -- 50 players = 10s
            -- 100 players = 20s
            -- 300 players = 60s & hits ceiling
            if (totalPlayers > 0) then
                local floor, ceiling = 3, 60

                multiplier = math.floor(totalPlayers / 5)
                if (multiplier < floor) then
                    multiplier = floor
                elseif (multiplier > ceiling) then
                    multiplier = ceiling
                end
            else
                multiplier = 30
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
        if (os.time() - lastDbSave > dbSaveInterval) then
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