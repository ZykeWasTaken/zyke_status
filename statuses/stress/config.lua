Config.Status.stress = {
    ["base"] = {
        -- Gradually impair vision with a blurry & saturating screen effect with some camera shaking
        -- The first few thresholds are manageable, you'll see that you are getting some effects but won't affect gameplay
        -- When you reach roughly the mid-point of the maximum threshold, it'll really kick off and restrict you
        -- You can adjust this as needed, current lows shows some imparment with highs really messing with you
        effect = {
            {
                threshold = 10.0,
                screenEffect = {value = "BarryFadeOut", intensity = 0.1},
                cameraShaking = {value = "DRUNK_SHAKE", intensity = 0.05},
            },
            {
                threshold = 20.0,
                screenEffect = {value = "BarryFadeOut", intensity = 0.3},
                cameraShaking = {value = "DRUNK_SHAKE", intensity = 0.1},
            },
            {
                threshold = 30.0,
                screenEffect = {value = "BarryFadeOut", intensity = 0.5},
                cameraShaking = {value = "DRUNK_SHAKE", intensity = 0.2},
            },
            {
                threshold = 50.0,
                screenEffect = {value = "BarryFadeOut", intensity = 0.8},
                cameraShaking = {value = "DRUNK_SHAKE", intensity = 0.8},
            },
            {
                threshold = 70.0,
                screenEffect = {value = "BarryFadeOut", intensity = 1.5},
                cameraShaking = {value = "DRUNK_SHAKE", intensity = 1.5},
            },
        }
    }
}