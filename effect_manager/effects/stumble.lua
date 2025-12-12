-- Whilst active, makes you stumble more easily
-- When walking it's very rare, but when running it will frequently happen
-- The effect value will multiply the chance at the very end, so 2.0 value will double your chance of stumbling

---@class StumbleValue
---@field value number

local baseChance = 1 -- 1% chance to stumble, every second, should be low if we're just standing still
local walkingAddition = 3 -- 3% EXTRA chance to stumble, added on top of baseChance
local runningAddition = 10 -- 10% EXTRA chance to stumble, added on top of baseChance, walkingAddition is not added if runningAddition is being added

-- Track the active value, so that we can have different roll chances based on your high
local value = 0.0

RegisterQueueKey("stumble", {
    ---@param val StumbleValue | number
    ---@return StumbleValue
    normalize = function(val)
        local _type = type(val)

        if (_type == "number") then
            return {value = val}
        elseif (_type == "table") then
            return {value = val.value or 0.0}
            ---@diagnostic disable-next-line: missing-return @ table or number, always returns something
        end
    end,
    ---@param val1 StumbleValue
    ---@param val2 StumbleValue
    ---@return integer
    compare = function(val1, val2)
        -- Numeric comparison - HIGHEST stumble chance wins (most severe)
        if (val1.value > val2.value) then return -1
        elseif (val1.value < val2.value) then return 1
        else return 0 end
    end,
	---@param val StumbleValue
    onStart = function(val)
        value = val.value

        CreateThread(function()
            while (value ~= 0.0) do
				local stumbleRoll = math.random(1, 10000) / 100 -- 2 decimal support
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

				-- If we did hit the roll, set us to ragdoll
				if (stumbleRoll <= chance) then
					SetPedToRagdoll(PlayerPedId(), 500, 2000, 0, false, false, false)
				end

				Wait(1000)
            end
        end)
    end,
	---@param val StumbleValue
	onTick = function(val)
		value = val.value
	end,
	onStop = function()
		value = 0.0
	end,
    reset = function()
        value = 0.0
    end,
})