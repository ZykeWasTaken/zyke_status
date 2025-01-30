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
    while (1) do
        Wait(1000)

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

        -- print(json.encode(Cache.statuses, {indent = true}))
    end
end)