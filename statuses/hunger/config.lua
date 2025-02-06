Config.Status.hunger = {
    ["base"] = {
        value = {
            drain = 0.003,
            -- drain = 0.1,
        },
        effect = {
            {threshold = 30.0, screenEffect = "BeastLaunch02"}, -- Some base screen effect
            {threshold = 20.0, walkingStyle = "move_m@sad@a"}, -- Walking more sluggish
            {threshold = 5.0, screenEffect = "WeaponUpgrade", damage = 1}, -- New screen effect, to simulate the severity, start taking damage, still retaining the walkingStyle from before
            {threshold = 0.0, damage = 1}, -- Retains all other effects, but adds on to the damage value, now doing 2 damage per tick instead
        }
    }
}