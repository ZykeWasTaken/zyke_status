Config.Status.high = {
    ["base"] = {
        value = {
            drain = 0.01
        },
        effect = {
            threshold = 30.0,
            screenEffect = "BikerFilter",
        },
    },
    ["coke"] = {
        value = {
            drain = 0.01
        },
        effect = {
            threshold = 5.0,
            movementSpeed = 1.2, -- Max
            screenEffect = "DaxTrip03",
        }
    }
}