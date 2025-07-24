Config.Status.thirst = {
    ["base"] = {
        value = {
            -- Per second 0.01 takes 100 seconds to drain 1%, which is ~160 minutes for 100%
            drain = 0.01,
        },
        effect = {
            {threshold = 20.0, screenEffect = "BeastLaunch02"},
            {threshold = 10.0, blockSprinting = true, blockJumping = true, walkingStyle = "move_m@sad@a"},
            {threshold = 0.0, damage = 0.25}
        }
    }
}