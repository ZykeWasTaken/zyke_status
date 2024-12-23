-- Settings specifically for addiction
Config.Status.addiction = {
    ["base"] = { -- Base value if nothing else is defined
        addiction = {
            drain = 0.01,
            threshold = 20.0,
        },
        value = {
            drain = 0.01
        }
    },
    ["thc"] = { -- Specifically for THC, harder to get addicted
        addiction = {
            drain = 0.01,
            threshold = 20.0,
        },
        value = {
            drain = 0.01
        }
    }
}