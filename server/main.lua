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
    local baseSpeed = 1000 -- Do not touch
    local multiplier = 3 -- If 3, waits baseSpeed * 3, and applied data * 3, slower updates for performance reasons

    local lastDbSave = os.time()
    local dbSaveInterval = 180 -- s

    while (1) do
        Wait(baseSpeed * multiplier)

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