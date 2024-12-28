-- Addiction has two values, the satisfaction level `value` and your addiction level `addiction`

-- Addiction `addiction`:
--- A dynamic & static level, moves up and down when adding or removing from the status
--- It will gradually keep moving down, unless it hit the addiciton threshold, at that point it is static and has to be moved manually
--- This allows minor hits, but continuous use will start an addiction

-- Satisfaction `value`
--- A dynamic level, is set at 100 unless you hit the addiction threshold
--- Once you are addicted, thid value will always keep going down, affecting you if your levels are too low
--- To have a high satisfaction value, keep smoking and you can reset it back to 100
--- Depending on the specific addiction settings, this will have different impacts

-- Custom for this type of status
-- Has to remove the satisfaction every tick if you are addicted
---@param plyId PlayerId
---@param name StatusName
local function removeSatisfaction(plyId, name, amount)
    local isValid, data, primary, secondary = ValidateStatusModification(plyId, name)
    if (not isValid or not data) then return end

    if (data.values[secondary].value == 0.0) then return end

    data.values[secondary].value = Z.numbers.round(data.values[secondary].value - amount, Config.Settings.decimalAccuracy)
    if (data.values[secondary].value < 0.0) then
        data.values[secondary].value = 0.0
    end

    SyncPlayerStatus(plyId, primary)
end

-- TODO: Some addSatisfaction
-- Also, reset satisfaction or something when addiction is draining

RegisterStatusType("addiction", true, {
    value = 100.0,
    addiction = 0.0,
}, function()
    for plyId, statuses in pairs(Cache.statuses) do
        if (statuses["addiction"]) then
            for subName, values in pairs(statuses["addiction"].values) do
                -- print("Handling", "addiction" .. "." .. subName, "for", plyId)

                -- print(json.encode(Config.Status))
                local statusSettings = GetStatusSettings("addiction." .. subName)

                -- If below the addiction threshold
                if (values.addiction < statusSettings.addiction.threshold) then
                    -- Not addicted, remove from the addicted status
                    -- print("Not addicted", "addiction." .. subName)
                    RemoveFromStatus(plyId, "addiction." .. subName, statusSettings.addiction.drain)
                else
                    -- Addicted, slowly remove satisfaction
                    removeSatisfaction(plyId, "addiction." .. subName, statusSettings.value.drain)
                end
            end

            -- AddToStatus(plyId, "stress", 0.01)
            -- RemoveFromStatus(plyId, "stress", 0.05)
        end
    end
end, function(plyId, name, amount) -- On add
    local isValid, data, primary, secondary = ValidateStatusModification(plyId, name)
    if (not isValid or not data) then return end

    -- TODO: Ensure value is above minimum decimal accuracy

    -- Add onto the addiction value (smaller value, static change for now, TODO: update it exponentially or something)

    local addToAddiction = data.values[secondary].addiction + amount
    data.values[secondary].addiction = Z.numbers.round(addToAddiction, Config.Settings.decimalAccuracy)
    if (data.values[secondary].addiction > 100.0) then
        data.values[secondary].addiction = 100.0
    end

    -- Add onto the satisfaction value
    data.values[secondary].value = Z.numbers.round(data.values[secondary].value + amount, Config.Settings.decimalAccuracy)
    if (data.values[secondary].value > 100.0) then
        data.values[secondary].value = 100.0
    end

    return true
end, function(plyId, name, amount) -- On remove
    local isValid, data, primary, secondary = ValidateStatusModification(plyId, name)
    if (not isValid or not data) then return end

    -- Remove from the addiciton value
    data.values[secondary].addiction = Z.numbers.round(data.values[secondary].addiction - amount, Config.Settings.decimalAccuracy)
    if (data.values[secondary].addiction < 0.0) then
        data.values[secondary].addiction = 0.0
    end

    -- Don't touch the satisfaction value for now

    return true
end)

RegisterCommand("addiction_add", function(source, args)
    exports["zyke_status"]:AddToStatus(source, args[1] and "addiction." .. args[1] or "addiction.nicotine", tonumber(args[2]) or 1.0)
end, false)