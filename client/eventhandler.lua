RegisterNetEvent("zyke_status:SyncStatus", function(statuses)
    if (not Cache.statuses) then Cache.statuses = {} end

    for name, status in pairs(statuses) do
        if (status == "nil") then
            Cache.statuses[name] = nil
        else
            Cache.statuses[name] = status
        end
    end
end)

RegisterNetEvent("zyke_lib:OnCharacterLogout", function()
    Cache.statuses = nil
end)