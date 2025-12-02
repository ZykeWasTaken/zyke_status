---@class StrengthValue
---@field value number

local handHash = `WEAPON_UNARMED`

RegisterQueueKey("strength", {
    ---@param val StrengthValue | number
    ---@return StrengthValue
    normalize = function(val)
        return {
            value = val.value or 1.0
        }
    end,
    ---@param val1 StrengthValue
    ---@param val2 StrengthValue
    ---@return integer
    compare = function(val1, val2)
        -- Numeric comparison - HIGHEST strength wins
        if (val1.value > val2.value) then return -1
        elseif (val1.value < val2.value) then return 1
        else return 0 end
    end,
    ---@param val StrengthValue
    onTick = function(val)
		SetWeaponDamageModifier(handHash, val.value)
    end,
	reset = function()
		SetWeaponDamageModifier(handHash, 1.0)
	end,
	onResourceStop = function()
		SetWeaponDamageModifier(handHash, 1.0)
	end
})