Config.Status.high = {
    ["base"] = {
        effect = {
            threshold = 30.0, -- For addiction, remember that this is reversed, satisfaction drops from 100.0
            screenEffect = "BeastLaunch02",
        },
    },
    ["coke"] = {
        effect = {
            threshold = 5.0,
            movementSpeed = 1.2,
            screenEffect = "BeastLaunch02",
        }
    }
}