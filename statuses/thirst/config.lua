Config.Status.thirst = {
    ["base"] = {
        value = {
            -- Per second 0.01 takes 100 seconds to drain 1%, which is ~160 minutes for 100%
            drain = 0.01,
        },
        effect = {
            {
                threshold = 10.0,
                screenEffect = "BeastLaunch02",
                damage = 1, -- Per tick, note that this can not be a decimal due to Gta limitations
                walkingStyle = "move_m@sad@a",
            }
        }
    }
}