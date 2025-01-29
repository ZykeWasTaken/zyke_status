Z.callback.register("zyke_status:GetPlayerStatus", function(plyId) return GetAllRawStatuses(plyId) end)

---@param plyId PlayerId
RegisterNetEvent("zyke_lib:OnRespawn", function(plyId)
    ResetStatuses(plyId)
end)