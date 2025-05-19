Config = Config or {}

Config.Settings = {
    debug = true,
    decimalAccuracy = 6,
    backwardsCompatibility = {
        -- Offers backwards compatibility with ESX & QBCore, however, it does create unsecure events (Not by us, we simply mimick what they do)
        enabled = true,
        -- To combat some systems simply not nil-checking, we provide a set of default data to ensure there is no error
        -- Yes, this is not a good solution, but this has to be done to avoid troubleshooting other people's codes and creating snippets for them
        -- It is disabled by default because it should not be used, but can be enabled if you are having errors with fetching statuses sometimes
        dummyReturn = false,

        -- QBCore & Qbox Specific
        -- You can manage this directly within our system if you want
        -- But to simplify our guide, we don't take control of these by default
        -- https://github.com/qbcore-framework/qb-core/blob/main/server/events.lua#L151
        -- https://github.com/Qbox-project/qbx_smallresources/blob/main/qbx_consumables/server.lua#L159
        addThirstEvent = false,
        addHungerEvent = false,
    },
    stressEvents = {
        -- A lot of huds & status management systems already manage stress, and we catch the common events they send out
        -- Because of this, we may create duplicate events resulting in twice the gain & relieve
        -- To combat this, you can easily disable these events that we catch
        -- However, if your server is not already catching these, you can keep these enabled
        gainStress = false,
        relieveStress = false
    },
    threadInterval = {
        playerScaling = 0.02, -- Percentage scaling based on player count
        multiplier = 30, -- s, max 180, recommended 5-30
        databaseSave = 180, -- s
    },
    smallResources = {
        ["driving"] = {
            enabled = false,
            minSpeed = 100.0, -- Minimum average speed to trigger, in km/h
            gainAmount = {min = 0.1, max = 0.5} -- Every 10s, 1 decimal max
        },
    }
}

-- Don't touch
Config.Status = {}

-- Create a manual hierarchy for effects, this way we can choose the strongest effect, the strongest being the one at the top
-- If you are experiencing 3 screen effects, we want to map these effects in here to find out which one is the strongest to show it
-- A little tedious, but it allows us to have an accurate effect
-- If your effects are not in here, it will just choose the first one in your active queue list
-- To clarify: You don't need to manage this list, but it is recommended
Config.EffectHierarchy = {
    ["screenEffect"] = {
        "DaxTrip03", -- https://forge.plebmasters.de/timecyclemods/DaxTrip03 (High contrast and warm/bright colors, film, acid-trip-like)
        "MP_Arena_theme_storm", -- https://forge.plebmasters.de/timecyclemods/MP_Arena_theme_storm (Blue fog effect, HEAVILY limits visuals, might remove)
        "BarryFadeOut", -- https://forge.plebmasters.de/timecycleMods/BarryFadeOut (White & bright effect, blurry, HEAVILY limits visuals, might remove)
        "BikerFilter", -- https://forge.plebmasters.de/timecyclemods/BikerFilter (Drunk effect)
        "NG_filmnoir_BW01", -- https://forge.plebmasters.de/timecycleMods/NG_filmnoir_BW01 (Black and white, darker)
        "NG_filmic11", -- https://forge.plebmasters.de/timecyclemods/NG_filmic11 (Black and white, with some bright on white)
        "ArenaEMP_Blend", -- https://forge.plebmasters.de/timecyclemods/ArenaEMP_Blend (Green/blue tint flickering glass)
        "phone_cam11", -- https://forge.plebmasters.de/timecycleMods/phone_cam11 (Less colors, darker, less constrast, film)
        "DanceIntensity02", -- https://forge.plebmasters.de/timecycleMods/DanceIntensity02 (Intrense red-orangeish color, lower contrast)
        "WeaponUpgrade", -- https://forge.plebmasters.de/timecycleMods/WeaponUpgrade (Heavy blue tint, darker)
        "InchPurple02", -- https://forge.plebmasters.de/timecyclemods/InchPurple02 (Slightly darker, purple tint)
        "BeastLaunch01", -- https://forge.plebmasters.de/timecyclemods/BeastLaunch01 (Slightly darker & red-ish)
        "BeastLaunch02", -- https://forge.plebmasters.de/timecyclemods/BeastLaunch02 (Slightly darker on corners, slightly brighter & white-ish)
        "NG_filmic15", -- https://forge.plebmasters.de/timecyclemods/NG_filmic15 (Low contrast, orange-redish)
        "glasses_yellow", -- https://forge.plebmasters.de/timecyclemods/glasses_yellow (Basic yellow, slightly green on screen bottom)
        "Dax_TripBlend01", -- https://forge.plebmasters.de/timecycleMods/Dax_TripBlend01 (Very subtle blue tint, slightly less contrast)
    },
    ["walkingStyle"] = {
        "move_m@drunk@verydrunk",
        "move_m@drunk@a",
        "move_m@drunk@slightlydrunk",
        "move_m@buzzed",
    }

    -- Add other effects that could be recognized
}