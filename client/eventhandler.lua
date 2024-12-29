RegisterNetEvent("zyke_status:SyncStatus", function(name, data)
    Cache.statuses[name] = data
end)