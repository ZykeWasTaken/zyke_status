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
            if (not statuses) then return end

            syncStatus(statuses)
        end)
    elseif (Framework == "QB") then
        RegisterNetEvent("hud:client:UpdateNeeds", function(_, _, statuses)
            if (not statuses) then return end

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

local keyPrefix = "direct_effect:"
---@param currEffects table<StatusName, integer | number | string | boolean>
---@param removedEffects QueueKey[] @List of effects that was removed this tick, none of these effects would be inside of currEffects
RegisterNetEvent("zyke_status:OnDirectEffectsUpdated", function(currEffects, removedEffects)
    Cache.directEffects = currEffects

    for i = 1, #removedEffects do
        RemoveFromQueue(removedEffects[i], keyPrefix .. removedEffects[i], nil)
    end

    for queueKey, value in pairs(currEffects) do
        local key = keyPrefix .. queueKey

        if (not DoseKeyExistsInQueueKey(queueKey, key)) then
            AddToQueue(queueKey, key, nil, value)
        end
    end
end)