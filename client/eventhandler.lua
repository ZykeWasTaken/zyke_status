RegisterNetEvent("zyke_status:SyncStatus", function(statuses)
    for name, status in pairs(statuses) do
        if (status == "nil") then
            Cache.statuses[name] = nil
        else
            Cache.statuses[name] = status
        end
    end
end)

AddEventHandler("zyke_lib:OnCharacterLogout", function()
    Cache.statuses = nil
end)