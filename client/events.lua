local function syncStatus(statuses)
    if (not Cache.statuses) then Cache.statuses = {} end

    for name, status in pairs(statuses) do
        if (status == "nil") then
            Cache.statuses[name] = nil
        else
            Cache.statuses[name] = status
        end
    end
end

-- Wonder why we do this? It's explained in the `SyncPlayerStatus` server function
local backwardsCompat = Config.Settings.backwardsCompatibility
if (backwardsCompat.enabled == true) then
    if (Framework == "ESX") then
        RegisterNetEvent("zyke_status:compatibility:onTick", function(_, statuses)
            syncStatus(statuses)
        end)
    elseif (Framework == "QB") then
        RegisterNetEvent("hud:client:UpdateNeeds", function(_, _, statuses)
            syncStatus(statuses)
        end)
    end
else
    RegisterNetEvent("zyke_status:SyncStatus", function(statuses)
        syncStatus(statuses)
    end)
end

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