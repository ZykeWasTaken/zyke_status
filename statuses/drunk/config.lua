Config.Status.drunk = {
    ["base"] = {
        value = {
            drain = 0.1
        },
        effect = {
            {threshold = 10.0, walkingStyle = "move_m@buzzed"},
            {threshold = 20.0, screenEffect = "BeastLaunch02", walkingStyle = "move_m@drunk@slightlydrunk"},
            {threshold = 30.0, screenEffect = "BikerFilter", walkingStyle = "move_m@drunk@a", blurryVision = true},
            {threshold = 50.0, screenEffect = "DaxTrip03", walkingStyle = "move_m@drunk@verydrunk"},
        },
    }
}