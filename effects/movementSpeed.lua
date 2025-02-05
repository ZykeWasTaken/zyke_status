RegisterQueueKey("movementSpeed", {
    onTick = function(val)
        SetRunSprintMultiplierForPlayer(PlayerId(), val)
    end,
    onResourceStop = function()
        SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
    end,
    reset = function()
        SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
    end
})