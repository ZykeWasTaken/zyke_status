---@type ClientCache
Cache = {
    statuses = nil
}

-- List of functions for effects
-- Indexed by primary.secondary
EffectFunctions = {}

Wait(100)
Cache.statuses = Z.callback.await("zyke_status:GetPlayerStatus")
TriggerEvent("zyke_status:OnStatusFetched")

AddEventHandler("zyke_lib:OnCharacterSelect", function()
    Cache.statuses = Z.callback.await("zyke_status:GetPlayerStatus")
    TriggerEvent("zyke_status:OnStatusFetched")
end)