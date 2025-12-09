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
                notification = {value = "stress1", play = "start"}
                -- notification = {value = "stress1", play = "start", force = true} -- You can use force here to forcefully always play this notification even if you surpass multiple thresholds in one go
            },
            {
                threshold = 20.0,
                screenEffect = {value = "BarryFadeOut", intensity = 0.3},
                cameraShaking = {value = "DRUNK_SHAKE", intensity = 0.1},
                notification = {value = "stress2", play = "start"}
            },
            {
                threshold = 30.0,
                screenEffect = {value = "BarryFadeOut", intensity = 0.5},
                cameraShaking = {value = "DRUNK_SHAKE", intensity = 0.2},
                notification = {value = "stress3", play = "start"}
            },
            {
                threshold = 50.0,
                screenEffect = {value = "BarryFadeOut", intensity = 0.8},
                cameraShaking = {value = "DRUNK_SHAKE", intensity = 0.8},
                notification = {value = "stress4", play = "start"}
            },
            {
                threshold = 70.0,
                screenEffect = {value = "BarryFadeOut", intensity = 1.5},
                cameraShaking = {value = "DRUNK_SHAKE", intensity = 1.5},
                notification = {value = "stress5", play = "start"}
                -- notification = {value = "You are feeling critically stressed.", type = "warning", play = "start"} -- We also allow direct notification messages without any translations
            },
        }
    }
}