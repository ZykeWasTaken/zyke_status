Z.callback.register("zyke_status:GetPlayerStatus", function(plyId) return GetAllRawStatuses(plyId) end)

-- TODO: When spawning your character, just by switching it, this will trigger
-- Need to find some event that just respawns if you are no longer dead, which is not available by default, perhaps I have to make some custom event for it
-- ---@param plyId PlayerId
-- RegisterNetEvent("zyke_lib:OnRespawn", function(plyId)
--     -- Only reset if the player is already loaded before
--     -- Otherwise it will cause various issues with selecting your character
--     if (not Cache.statuses[plyId]) then return end

--     ResetStatuses(plyId)
-- end)