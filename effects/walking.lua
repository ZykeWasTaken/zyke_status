RegisterQueueKey("walkingStyle", {
    onTick = function(val)
        -- SetRunSprintMultiplierForPlayer(PlayerId(), val)
    end,
    onResourceStop = function()
        print("onResourceStop walkingStyle")
    end,
    reset = function()
        print("reset walkingStyle")
    end
})