Config.Status.hunger = {
    ["base"] = {
        value = {
            -- Per second 0.005 takes 200 seconds to drain 1%, which is ~320 minutes for 100%
            drain = 0.005,
        },
        effect = {
            {
                -- Start being hungry, slight screen effect
                threshold = 20.0,
                screenEffect = {value = "WeaponUpgrade", intensity = 0.6},
            },
            {
                -- Start being very hungry, noticeable screen effect
                -- Very slight camera shaking
                threshold = 10.0,
                screenEffect = {value = "WeaponUpgrade", intensity = 0.7},
                cameraShaking = {value = "DRUNK_SHAKE", intensity = 0.2},
                walkingStyle = "move_m@sad@a",
            },
            {
                -- Complete starvation
                -- Very noticeable screen effect, impaired vision
                -- Taking slow damage
                -- Noticeable camera shaking, feeling dizzy
                -- Restricted movement due to low energy levels
                threshold = 0.0,
                screenEffect = {value = "WeaponUpgrade", intensity = 0.8},
                cameraShaking = {value = "DRUNK_SHAKE", intensity = 0.8},
                blockSprinting = true,
                blockJumping = true,
                damage = 0.25
            },
        }
    }
}