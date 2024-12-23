---@type ServerCache
Cache = {
    statuses = {},
    existingStatuses = {},
}

-- Loop the existing statuses and perform an action every second, if one is specified
CreateThread(function()
    while (1) do
        Wait(1000)

        for _, values in pairs(Cache.existingStatuses) do
            if (values.tickFn) then
                values.tickFn()
            end
        end

        print(json.encode(Cache.statuses, {indent = true}))
    end
end)