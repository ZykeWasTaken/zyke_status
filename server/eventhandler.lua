Z.callback.register("zyke_status:GetPlayerStatus", function(plyId) return GetAllRawStatuses(plyId) end)

---@param plyId PlayerId
RegisterNetEvent("zyke_lib:OnRespawn", function(plyId)
    -- Only reset if the player is already loaded before
    -- Otherwise it will cause various issues with selecting your character
    if (not Cache.statuses[plyId]) then return end

    ResetStatuses(plyId)
end)