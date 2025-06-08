-- This solution allows us to add decimals for health & armor without the need to track the leftover decimals
-- This is meant to solve the issue of adding to a stat in quick iterations with small values

-- Since Gta requires us to give whole numbers, the only way to accurateley give an entity health & armor, you need to manually track the leftover decimals
-- Via the export, we automatically handle all of this for you

-- This is slightly primitive because it doesn't do outside checks for checking if the decimal should even be added, e.g if your armor was removed and we cache a decimal that should not exist

local stats = {
	["health"] = 0.0,
	["armor"] = 0.0,
}

---@param stat "health" | "armor"
---@param amount number
function AddToStat(stat, amount)
	if (not stats[stat]) then return end

	local isPositive = amount > 0.0
	local newVal = stats[stat] + amount

	local decimal = newVal
	if (not isPositive) then
		decimal = newVal - math.ceil(newVal)
	else
		decimal = newVal - math.floor(newVal)
	end

	-- If the value is between -1.0 and 1.0, we can't process it and just leave it for now
	if (
		newVal < 1.0
		and newVal > -1.0
	) then
		stats[stat] = newVal
		return
	end

	local ply = PlayerPedId()

	if (stat == "health") then
		local currHealth = GetEntityHealth(ply)
		local isNewValPositive = newVal > 0.0
		local newHealth = currHealth + (isNewValPositive and math.floor(newVal) or math.ceil(newVal))

		SetEntityHealth(ply, newHealth)
		stats[stat] = decimal

		return
	elseif (stat == "armor") then
		local currArmor = GetPedArmour(ply)
		local isNewValPositive = newVal > 0.0
		local newArmor = currArmor + (isNewValPositive and math.floor(newVal) or math.ceil(newVal))

		SetPedArmour(ply, newArmor)
		stats[stat] = decimal

		return
	end
end

exports("AddToStat", AddToStat)