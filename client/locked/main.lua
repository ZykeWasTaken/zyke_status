---@type ClientCache
Cache = {
    statuses = {}
}

Cache.statuses = Z.callback.await("zyke_status:GetPlayerStatus")

-- Dev
CreateThread(function()
    while (1) do
        local statusStr = ""
        for baseStatus, statusData in pairs(Cache.statuses) do
            for status, subData in pairs(statusData.values) do
                -- statusStr = statusStr .. status .. ": " .. subData.value .. "\n"

                for valueKey, value in pairs(subData) do
                    statusStr = statusStr .. baseStatus .. "." .. status .. "." .. valueKey .. ": " .. value .. "\n"
                end
            end
        end

        Z.drawText(statusStr, 0.5, 0.01)

        Wait(0)
    end
end)