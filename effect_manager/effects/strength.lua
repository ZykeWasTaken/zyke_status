local handHash = `WEAPON_UNARMED`

RegisterQueueKey("strength", {
    onTick = function(val)
		if (type(val) ~= "number") then return end

		SetWeaponDamageModifier(handHash, val)
    end,
	reset = function()
		SetWeaponDamageModifier(handHash, 1.0)
	end,
	onResourceStop = function()
		SetWeaponDamageModifier(handHash, 1.0)
	end
})