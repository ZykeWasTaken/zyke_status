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
    local tickSpeed = 1000 -- Probably shouldn't touch
    local lastDbSave = os.time()
    local dbSaveInterval = 180 -- s

    while (1) do
        Wait(tickSpeed)

        local existingStatuses = Cache.existingStatuses
        for statusName, values in pairs(existingStatuses) do
            if (values.onTick) then
                values.onTick(getPlayersForStatus(statusName))
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