Config.Status.caffeine = {
    ["base"] = {
        value = {
            -- Per second 0.05 takes 20 seconds to drain 1%, which is ~33 minutes for 100%
            drain = 0.05
        },
        effect = {
            {threshold = 5.00, movementSpeed = 1.05},
            {threshold = 10.0, movementSpeed = 1.08},
            {threshold = 20.0, movementSpeed = 1.1},
            {threshold = 30.0, movementSpeed = 1.15},
            {threshold = 40.0, movementSpeed = 1.2, damage = 1},
            {threshold = 50.0, movementSpeed = 1.3, damage = 2},
        },
    }
}