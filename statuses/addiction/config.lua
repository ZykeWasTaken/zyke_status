-- Settings specifically for addiction
Config.Status.addiction = {
    ["base"] = { -- Base value if nothing else is defined
        addiction = {
            drain = 0.01,
            threshold = 20.0,
        },
        value = {
            drain = 0.01
        },
        effect = {
            {
                threshold = 20.0, -- For addiction, remember that this is reversed, satisfaction drops from 100.0
                screenEffect = "BeastLaunch02",
            }
        },
    },
    ["thc"] = { -- Specifically for THC, harder to get addicted
        addiction = {
            drain = 0.01,
            threshold = 20.0,
        },
        value = {
            drain = 5.01
        },
        effect = {
            {
                threshold = 20.0, -- For addiction, remember that this is reversed, satisfaction drops from 100.0
                screenEffect = "BeastLaunch02",
            }
        },
    },
    ["nicotine"] = {
        addiction = {
            drain = 0.002,
            threshold = 10.0,
        },
        value = {
            drain = 0.5
        },
        effect = {
            {
                threshold = 80.0, -- For addiction, remember that this is reversed, satisfaction drops from 100.0
                screenEffect = "BeastLaunch02",
            }
        },
    }
}