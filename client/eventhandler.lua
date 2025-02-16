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
    -- Go through all statuses and run the reset for the effects
    -- This is to allow smooth character switching
    ClearEffectQueue()

    Cache.statuses = nil
end)

RegisterNetEvent("zyke_status:OnHealPlayer", function()
    SetEntityHealth(PlayerPedId(), GetPedMaxHealth(PlayerPedId()))
    TriggerServerEvent("zyke_status:OnHealPlayer")
end)