Config = Config or {}

Config.Settings = {
    debug = true,
    decimalAccuracy = 3,
}

-- Don't touch
Config.Status = {}

-- Statuses that are not static
-- These statuses either give some sort of effect, move automatically up or down etc
-- The amount is added every 1 second
-- 0.01 ~= 2.75 hours to max
Config.DynamicStatuses = {
    ["stress"] = {
        type = "gain",
        amount = 0.01,
    }
}