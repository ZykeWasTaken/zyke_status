Config.Status.hunger = {
    ["base"] = {
        value = {
            drain = 0.003,
            -- drain = 0.1,
        },
        effect = {
            threshold = 10.0,
            screenEffect = "BeastLaunch02",
            damage = 1, -- Per tick, note that this can not be a decimal
        }
    }
}