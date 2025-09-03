-- Whilst active, makes you stumble more easily
-- When walking it's very rare, but when running it will frequently happen
-- The effect value will multiply the chance at the very end, so 2.0 value will double your chance of stumbling

local baseChance = 1 -- 1% chance to stumble, every second, should be low if we're just standing still
local walkingAddition = 3 -- 3% EXTRA chance to stumble, added on top of baseChance
local runningAddition = 10 -- 10% EXTRA chance to stumble, added on top of baseChance, walkingAddition is not added if runningAddition is being added

-- Track the active value, so that we can have different roll chances based on your high
local value = 0.0

RegisterQueueKey("stumble", {
    onStart = function(val)
		if (type(val) ~= "number") then return end
        value = val

        CreateThread(function()
            while (value ~= 0.0) do
				local stumbleRoll = math.random(1, 100)
				local chance = baseChance

				local isWalking = IsPedWalking(PlayerPedId()) == 1 -- Just walking normally
				local isRunning = IsPedRunning(PlayerPedId()) == 1 -- When you're running but no stamina
				local isSprinting = IsPedSprinting(PlayerPedId()) == 1 -- When you're running with stamina

				if (isRunning or isSprinting) then
					chance += runningAddition
				elseif (isWalking) then
					chance += walkingAddition
				end

				chance *= value

				print("value", value, "stumbleRoll", stumbleRoll, "chance", chance)

				-- If we did hit the roll, set us to ragdoll
				if (stumbleRoll <= chance) then
					SetPedToRagdoll(PlayerPedId(), 500, 2000, 0, false, false, false)
				end

				Wait(1000)
            end
        end)
    end,
	onTick = function(val)
		if (type(val) ~= "number") then return end

		value = val
	end,
	onStop = function()
		value = 0.0
	end,
    reset = function()
        value = 0.0
    end,
})