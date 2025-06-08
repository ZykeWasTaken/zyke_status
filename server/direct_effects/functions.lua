-- Fetches from database and sets the cache
---@param plyId PlayerId
function EnsureDirectEffectsFromDatabase(plyId)
	local identifier = Z.getIdentifier(plyId)
	if (not identifier) then return end

	local directCalls = MySQL.scalar.await("SELECT direct_effects FROM zyke_status WHERE identifier = ?", {identifier})
	local decoded = directCalls and json.decode(directCalls) or {}

	Cache.directEffects[plyId] = decoded
end

---@param plyId PlayerId
---@return table<QueueKey, DirectEffect[]>
function GetAllRawDirectEffects(plyId)
    return Cache.directEffects[plyId] or {}
end

local mergeThreshold = Config.Settings.directEffects.accuracyMerge
local function canMergeValues(newVal, currVal)
	return newVal >= currVal - mergeThreshold and newVal <= currVal + mergeThreshold
end

---@param plyId PlayerId
---@return table<QueueKey, integer | number | string | boolean>
function GetDirectEffectsForClient(plyId)
	local formattedEffects = {}
	local plyEffects = Cache.directEffects[plyId]

	for key, value in pairs(plyEffects) do
		formattedEffects[key] = value[1].value
	end

	return formattedEffects
end

---@param plyId PlayerId
---@param removedEffects QueueKey[]?
local function syncDirectEffectsToClient(plyId, removedEffects)
	TriggerClientEvent("zyke_status:OnDirectEffectsUpdated", plyId, GetDirectEffectsForClient(plyId), removedEffects or {})
end

---@param plyId PlayerId
---@param effects DirectEffectInput[]
function AddDirectEffect(plyId, effects)
	-- When adding an effect, we may already have a similar one in here
	-- Make sure that we merge them if so, to lessen the iterations needed

	local plyEffects = Cache.directEffects[plyId]

	-- We also sort the effects properly
	for i = 1, #effects do
		-- If the effect is completely empty, we can just add it
		if (not plyEffects[effects[i].name]) then
			plyEffects[effects[i].name] = {}

			plyEffects[effects[i].name][#plyEffects[effects[i].name]+1] = {
				value = effects[i].value,
				duration = effects[i].duration
			}
		else
			local newVal = effects[i].value

			if (type(newVal) == "boolean") then
				-- If it's a boolean, just set the current value at the top to the value
				local newDur = effects[i].duration + (plyEffects[effects[i].name]?[1]?.duration or 0)

				plyEffects[effects[i].name][1] = {value = newVal, duration = newDur}
			else
				local newValType = type(newVal)

				-- Iterate all of the cached effects to see where we should add this in
				-- If we are higher than the value we are currently iterating, we should add it to the top, or merge it to the value if it is within range
				local hasAdded = false
				for j = 1, #plyEffects[effects[i].name] do
					local effect = plyEffects[effects[i].name][j]
					local currVal = effect.value

					if (newValType == "number") then
						-- First, check if we are above, and if so, we should add it above the current index
						-- We also double check and make sure that we are not within merge range
						if (newVal >= currVal) then
							if (not canMergeValues(newVal, currVal)) then
								table.insert(plyEffects[effects[i].name], j, {value = newVal, duration = effects[i].duration})
								hasAdded = true
							else
								local newDur = effect.duration + effects[i].duration
								plyEffects[effects[i].name][j] = {value = newVal, duration = newDur}
								hasAdded = true
							end

							break
						end

						-- If they're close enough to eachother, we merge them
						if (canMergeValues(newVal, currVal)) then
							local newDur = effect.duration + effects[i].duration
							plyEffects[effects[i].name][j] = {value = newVal, duration = newDur}
							hasAdded = true
						end
					elseif (newValType == "string") then
						if (newVal == currVal) then
							local newDur = effect.duration + effects[i].duration
							plyEffects[effects[i].name][j] = {value = newVal, duration = newDur}
							hasAdded = true
						end
					end
				end

				if (not hasAdded) then
					plyEffects[effects[i].name][#plyEffects[effects[i].name]+1] = {value = newVal, duration = effects[i].duration}
				end
			end
		end
	end

	syncDirectEffectsToClient(plyId)
end

exports("AddDirectEffect", AddDirectEffect)

-- RegisterCommand("test_direct_effects", function(plyId)
-- 	AddDirectEffect(plyId, {
-- 		{
-- 			name = "movementSpeed",
-- 			value = math.random(100, 149) / 100,
-- 			duration = math.random(1, 100)
-- 		},
-- 		{
-- 			name = "cameraShaking",
-- 			value = true,
-- 			duration = math.random(1, 100)
-- 		}
-- 	})
-- end, false)

-- Temporary testing loop to manage the effects
CreateThread(function()
	local waitInterval = 3000

	while (1) do
		Wait(waitInterval)

		---@type table<PlayerId, table<QueueKey, DirectEffect[]>>
		---@diagnostic disable-next-line: assign-type-mismatch
		local directEffects = Cache.directEffects

		for plyId in pairs(directEffects) do
			local queueKeysRemoved = {}
			local plyEffects = Cache.directEffects[plyId]
			local toRemove = waitInterval / 1000

			for queueKey, directEffectData in pairs(plyEffects) do

				local removedIdxs = 0
				for i = 1, #directEffectData do
					i = i - removedIdxs

					local effect = directEffectData[i]
					local totalCanRemove = effect.duration

					if (totalCanRemove <= toRemove) then
						toRemove -= totalCanRemove
						table.remove(directEffectData, i)
						queueKeysRemoved[#queueKeysRemoved+1] = queueKey
						removedIdxs += 1
					else
						directEffectData[i].duration -= toRemove
						break
					end
				end

				if (#directEffectData == 0) then
					plyEffects[queueKey] = nil
				end
			end

			if (#queueKeysRemoved > 0) then
				syncDirectEffectsToClient(plyId, queueKeysRemoved)
			end
		end
	end
end)