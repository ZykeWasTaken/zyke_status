---@type ServerCache
Cache = {
    statuses = {},
    existingStatuses = {},
}

---@param name string @primary
local function getPlayersForStatus(name)
    local players = {}

    for plyId, statuses in pairs(Cache.statuses) do
        if (statuses[name]) then
            players[plyId] = statuses[name]
        end
    end

    return players
end

-- Loop the existing statuses and perform an action every second, if one is specified
CreateThread(function()
    local tickSpeed = 1000
    local lastDbSave = os.time()
    local dbSaveInterval = 180

    while (1) do
        Wait(tickSpeed)

        for statusName, values in pairs(Cache.existingStatuses) do
            local prim = SeparateStatusName(statusName)

            if (values.onTick) then
                values.onTick(getPlayersForStatus(prim))
            end
        end

        for plyId in pairs(Cache.statuses) do
            local _plyId = tonumber(plyId)
            if (_plyId) then
                if (CompatibilityFuncs) then
                    CompatibilityFuncs.SetStatus(_plyId)
                end
            end
        end

        -- We save during logout, but to be save, save every x amount of seconds
        if (os.time() - lastDbSave > dbSaveInterval) then
            lastDbSave = os.time()
            for plyId in pairs(Cache.statuses) do
                local _plyId = tonumber(plyId)

                if (_plyId) then
                    SavePlayerToDatabase(_plyId)
                end
            end
        end

        -- print(json.encode(Cache.statuses, {indent = true}))
    end
end)

-- RegisterCommand("pluhhh", function(source)
--     TriggerEvent('esx_status:getStatus', source, 'thirst', function(status)
--         print(json.encode(status, {indent = true}))
--     end)
-- end, false)