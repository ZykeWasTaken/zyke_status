-- A module to allow freezing the status of players
-- Trigger the export to freeze & trigger to unfreeze, we also handle cleanup if the player leaves / changes character
-- This means that nothing will happen for this player, good fit for "afk" modes, events, etc
-- This does not satisfy any character needs, we just stop the onTick & any active effects from continuing to run, your status is still cached & can be fetched

---@class FrozenPlayer
---@field plyId PlayerId
---@field frozenAt OsTime

---@type table<PlayerId, FrozenPlayer>
local frozenPlayers = {}

---@param plyId PlayerId
function FreezeStatus(plyId)
	if (frozenPlayers[plyId]) then return end

	frozenPlayers[plyId] = {
		plyId = plyId,
		frozenAt = os.time()
	}

	TriggerClientEvent("zyke_status:OnPlayerStatusFrozen", plyId)
	TriggerEvent("zyke_status:OnPlayerStatusFrozen", plyId)

	Z.debug("Froze status for", plyId)
end

---@param plyId PlayerId
function UnfreezeStatus(plyId)
	if (not frozenPlayers[plyId]) then return end

	frozenPlayers[plyId] = nil

	TriggerClientEvent("zyke_status:OnPlayerStatusUnfrozen", plyId)
	TriggerEvent("zyke_status:OnPlayerStatusUnfrozen", plyId)

	Z.debug("Unfroze status for", plyId)
end

---@return table<PlayerId, FrozenPlayer>
function GetFrozenPlayers()
	return frozenPlayers
end

---@param plyId PlayerId
---@return boolean
function IsPlayerFrozen(plyId)
	return frozenPlayers[plyId] ~= nil
end

RegisterServerEvent("zyke_lib:OnCharacterLogout", function(plyId)
	if (not IsPlayerFrozen(plyId)) then return end

	UnfreezeStatus(plyId)
end)

exports("FreezeStatus", FreezeStatus)
exports("UnfreezeStatus", UnfreezeStatus)
exports("GetFrozenPlayers", GetFrozenPlayers)
exports("IsPlayerFrozen", IsPlayerFrozen)