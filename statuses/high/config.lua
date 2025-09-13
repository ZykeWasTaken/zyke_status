Config.Status.high = {
    ["base"] = {
        value = {
            drain = 0.01
        },
        effect = {
            {threshold = 30.0, screenEffect = "BikerFilter"}
        },
    },
    ["coke"] = {
        value = {
            drain = 0.01
        },
        effect = {
            {
                threshold = 5.0,
                movementSpeed = 1.2, -- Max
                screenEffect = "DaxTrip03",
            }
        }
    },
    ["nicotine"] = {
        value = {
            drain = 0.05
        },
        effect = {
            {
                threshold = 5.0,
                screenEffect = "DanceIntensity02",
            },
            {
                threshold = 10.0,
                screenEffect = "NG_filmic15",
            }
        }
    },
    ["thc"] = {
        value = {drain = 0.05},
        effect = {
            {threshold = 10.0, screenEffect = "BeastLaunch02"},
            {threshold = 30.0, walkingStyle = "move_m@buzzed"},
            {threshold = 60.0, walkingStyle = "move_m@drunk@slightlydrunk"},
            {threshold = 80.0, walkingStyle = "move_m@drunk@a"},
        }
    },
    -- ex. whippets, nitrous oxide, usually quick highs by limiting oxygen to the brain
    -- We have quick highs & dizzy effects, if we reach closer to 100% high we will have very dangerous effects since the brain is completely deprived of oxygen
    ["n2o"] = {
        value = {
            drain = 1.0
        },
        effect = {
            {threshold = 10.0, walkingStyle = "move_m@buzzed", stumble = 0.05},
            {threshold = 20.0, screenEffect = "BeastLaunch02", walkingStyle = "move_m@drunk@slightlydrunk", stumble = 0.1},
            {threshold = 30.0, stumble = 0.2},
            {threshold = 40.0, screenEffect = "BikerFilter", walkingStyle = "move_m@drunk@a", stumble = 0.35},
            {threshold = 50.0, stumble = 0.75},
            {threshold = 70.0, screenEffect = "DaxTrip03", walkingStyle = "move_m@drunk@verydrunk", stumble = 1.5, damage = 1.0},
            {threshold = 90.0, damage = 3.0},
        }
    },
    ["fentanyl"] = {
        value = {drain = 0.05},
        effect = {
            {threshold = 5.0, screenEffect = "BeastLaunch02", walkingStyle = "move_m@buzzed", damage = 1.0},
            {threshold = 10.0, screenEffect = "DaxTrip03", walkingStyle = "move_m@drunk@verydrunk", stumble = 1.5, damage = 2.0},
            {threshold = 20.0, damage = 3.0},
            {threshold = 30.0, damage = 3.0},
            {threshold = 40.0, damage = 3.0},
        }
    }
}