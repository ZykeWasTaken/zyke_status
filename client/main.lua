---@type ClientCache
Cache = {
    statuses = nil,
    directEffects = nil
}

-- List of functions for effects
-- Indexed by primary.secondary
EffectFunctions = {}

local function init()
    Cache.statuses = Z.callback.await("zyke_status:GetPlayerStatus")
    Cache.directEffects = Z.callback.await("zyke_status:GetPlayerDirectEffects")
    TriggerEvent("zyke_status:OnDirectEffectsUpdated", Cache.directEffects, {})

    TriggerEvent("zyke_status:OnStatusFetched")
end

AddEventHandler("zyke_lib:OnCharacterSelect", function()
    init()
end)

RegisterNetEvent("zyke_status:HasInitialized", function()
    init()
end)

RegisterNetEvent("zyke_lib:OnLoaderFinished", function()
    while not (LocalPlayer.state["z:hasLoaded"]) do
        Wait(100)
    end

    if (Cache.statuses ~= nil) then return end

    init()
end)

AddEventHandler("zyke_status:OnPlayerStatusUnfrozen", function()
    init()
end)