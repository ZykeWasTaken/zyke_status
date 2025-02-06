Config.Status.thirst = {
    ["base"] = {
        value = {
            drain = 0.005,
            -- drain = 0.1,
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