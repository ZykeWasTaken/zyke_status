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
---@param statusNames StatusNames
---@param amount number
local function removeSatisfaction(plyId, statusNames, amount)
    local primary, secondary = statusNames[1], statusNames[2]

    local data = GetPlayerBaseStatusTable(plyId, primary)
    if (not data) then return end

    if (data.values[secondary].value == 0.0) then return end

    data.values[secondary].value = Z.numbers.round(data.values[secondary].value - amount, Config.Settings.decimalAccuracy)
    if (data.values[secondary].value < 0.0) then
        data.values[secondary].value = 0.0
    end

    SyncPlayerStatus(plyId, primary)
end

-- TODO: Some addSatisfaction
-- Also, reset satisfaction or something when addiction is draining

local primary = "addiction"
RegisterStatusType(primary, true, {value = 100.0, addiction = 0.0},
{
    onTick = function(players, multiplier)
        for plyId, status in pairs(players) do
            for subName, values in pairs(status.values) do
                local statusSettings = GetStatusSettings({primary, subName})
                if (not statusSettings) then return end

                -- If below the addiction threshold
                if (values.addiction < statusSettings.addiction.threshold) then
                    -- Not addicted, remove from the addicted status
                    local val = (statusSettings?.addiction?.drain or 0) * multiplier

                    if (val > 0) then
                        RemoveFromStatus(plyId, {primary, subName}, val, true)
                    end
                else
                    -- Addicted, slowly remove satisfaction
                    local val = (statusSettings?.value?.drain or 0) * multiplier

                    if (val > 0) then
                        removeSatisfaction(plyId, {primary, subName}, val)
                    end
                end
            end
        end
    end,
    onAdd = function(plyId, statusNames, amount)
        local secondary = statusNames[2] or primary

        local data = GetPlayerBaseStatusTable(plyId, primary)
        if (not data) then return end

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
    end,
    onRemove = function(plyId, statusNames, amount)
        local secondary = statusNames[2] or primary

        local data = GetPlayerBaseStatusTable(plyId, primary)
        if (not data) then return end

        -- Remove from the addiction value
        data.values[secondary].addiction = Z.numbers.round(data.values[secondary].addiction - amount, Config.Settings.decimalAccuracy)
        if (data.values[secondary].addiction < 0.0) then
            data.values[secondary].addiction = 0.0
        end

        -- Don't touch the satisfaction value for now

        return true
    end,
    onReset = function(plyId, statusNames)
        local secondary = statusNames[2] or primary

        local data = GetPlayerBaseStatusTable(plyId, primary)
        if (not data) then return end

        data.values[secondary].addiction = 0.0
        data.values[secondary].value = 100.0

        return true
    end,
    onSoftReset = function(plyId, statusNames)
        local secondary = statusNames[2] or primary

        local data = GetPlayerBaseStatusTable(plyId, primary)
        if (not data) then return end

        data.values[secondary].value = 100.0

        return true
    end
})