Config.Status.hunger = {
    ["base"] = {
        value = {
            -- Per second 0.005 takes 200 seconds to drain 1%, which is ~320 minutes for 100%
            drain = 0.005,
        },
        effect = {
            {threshold = 20.0, screenEffect = "WeaponUpgrade"}, -- A screen effect to simulate that you are being affected by hunger
            {threshold = 10.0, walkingStyle = "move_m@sad@a", blockSprinting = true, blockJumping = true}, -- Walking more sluggish, block high-energy actions like sprinting and jumping
            {threshold = 0.0, damage = 0.25}, -- Start taking some damage
        }
    }
}