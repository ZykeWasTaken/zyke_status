Config.Status.thirst = {
    ["base"] = {
        value = {
            -- Per second 0.01 takes 100 seconds to drain 1%, which is ~160 minutes for 100%
            drain = 0.01,
        },
        effect = {
            {
                -- Minor shaking & screen effect
                threshold = 20.0,
                screenEffect = {value = "BeastLaunch02", intensity = 0.25},
                cameraShaking = {value = "DRUNK_SHAKE", intensity = 0.2}
            },
            {
                -- Noticeable shaking & screen effect
                -- Due to dehydration, block sprinting & jumping
                -- Walking style is more sluggish
                threshold = 10.0,
                screenEffect = {value = "BeastLaunch02", intensity = 0.5},
                cameraShaking = {value = "DRUNK_SHAKE", intensity = 0.35},
                blockSprinting = true,
                blockJumping = true,
                walkingStyle = "move_m@sad@a"
            },
            {
                -- Complete dehydration
                -- Very noticeable shaking & screen effect, impaired vision
                -- Taking slow damage
                threshold = 0.0,
                screenEffect = {value = "BeastLaunch02", intensity = 1.0},
                cameraShaking = {value = "DRUNK_SHAKE", intensity = 0.75},
                damage = 0.25
            },
        }
    }
}