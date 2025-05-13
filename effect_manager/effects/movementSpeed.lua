-- Using GetEntitySpeed the default speed running straight is ~7.05
-- Using a 7.06 max speed multiplier, setting movementSpeed to 0.9, you are roughly running at ~6.35 at max
-- 7.06 max speed multipler seem to be the sweet spot to regulate your max speed, using a 7.05 multiplier will make your movement speed be about 7.046

-- Please note that reducing the speed too much may look incredibly weird and act somewhat weird
-- We recommend not going lower than 0.8, paired with some modified running perhaps

RegisterQueueKey("movementSpeed", {
    onTick = function(val)
        SetRunSprintMultiplierForPlayer(PlayerId(), val)
        SetEntityMaxSpeed(PlayerPedId(), val * 7.06)
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