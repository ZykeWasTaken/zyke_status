Config.Status.drunk = {
    ["base"] = {
        value = {
            drain = 0.1
        },
        effect = {
            threshold = 15.0, -- For addiction, remember that this is reversed, satisfaction drops from 100.0
            screenEffect = "BikerFilter",
        },
    }
}