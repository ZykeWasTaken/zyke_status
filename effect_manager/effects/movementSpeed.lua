-- Using GetEntitySpeed the default speed running straight is ~7.05
-- Using a 7.06 max speed multiplier, setting movementSpeed to 0.9, you are roughly running at ~6.35 at max
-- 7.06 max speed multipler seem to be the sweet spot to regulate your max speed, using a 7.05 multiplier will make your movement speed be about 7.046

-- Please note that reducing the speed too much may look incredibly weird and act somewhat weird
-- We recommend not going lower than 0.8, paired with some modified running perhaps

---@class MovementSpeedValue
---@field value number

RegisterQueueKey("movementSpeed", {
    ---@param val MovementSpeedValue | number
    ---@return MovementSpeedValue
    normalize = function(val)
        local _type = type(val)

        if (_type == "number") then
            return {value = val}
        elseif (_type == "table") then
            return {value = val.value or 1.0}
            ---@diagnostic disable-next-line: missing-return @ table or number, always returns something
        end
    end,
    ---@param val1 MovementSpeedValue
    ---@param val2 MovementSpeedValue
    ---@return integer
    compare = function(val1, val2)
        -- Numeric comparison - HIGHEST speed wins (least restrictive)
        if (val1.value > val2.value) then return -1
        elseif (val1.value < val2.value) then return 1
        else return 0 end
    end,
    ---@param val MovementSpeedValue
    onTick = function(val)
        SetRunSprintMultiplierForPlayer(PlayerId(), val.value)
        SetEntityMaxSpeed(PlayerPedId(), val.value * 7.06)
    end,
    onResourceStop = function()
        SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
        SetEntityMaxSpeed(PlayerPedId(), 7.06)
    end,
    reset = function()
        SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
        SetEntityMaxSpeed(PlayerPedId(), 7.06)
    end
})