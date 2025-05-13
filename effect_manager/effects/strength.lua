local handHash = `WEAPON_UNARMED`

RegisterQueueKey("strength", {
    onStart = function(val)
		SetWeaponDamageModifier(handHash, val)
    end,
	reset = function()
		SetWeaponDamageModifier(handHash, 1.0)
	end,
	onResourceStop = function()
		SetWeaponDamageModifier(handHash, 1.0)
	end
})