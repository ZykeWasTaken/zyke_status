---@type ClientCache
Cache = {
    statuses = {}
}

Cache.statuses = Z.callback.await("zyke_status:GetPlayerStatus")

-- Dev
CreateThread(function()
    while (1) do
        local offset = 0.0
        for baseStatus, statusData in pairs(Cache.statuses) do
            for status, subData in pairs(statusData.values) do
                for valueKey, value in pairs(subData) do
                    Z.drawText(baseStatus .. "." .. status .. "." .. valueKey .. ": " .. value, 0.5, 0.01 + offset)
                    offset += 0.025
                end
            end
        end

        Wait(0)
    end
end)