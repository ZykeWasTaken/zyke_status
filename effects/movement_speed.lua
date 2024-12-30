RegisterQueueKey("movementSpeed", {
    onTick = function(val)
        SetRunSprintMultiplierForPlayer(PlayerId(), val)
    end,
    onResourceStop = function()
        print("onResourceStop movementSpeed")
        SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
    end,
    reset = function()
        print("reset movementSpeed")
        SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
    end
})