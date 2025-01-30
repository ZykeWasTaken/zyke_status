local primary = "high"
RegisterStatusType(primary, true, {value = 0.0},
{
    onTick = function(players)
        for plyId, status in pairs(players) do
            for subName, values in pairs(status.values) do
                local fullName = primary .. "." .. subName
                local statusSettings = GetStatusSettings(fullName)

                RemoveFromStatus(plyId, fullName, statusSettings?.value?.drain or 0)
            end
        end
    end,
    onAdd = function(plyId, name, amount)
        local isValid, data, primary, secondary = ValidateStatusModification(plyId, name)
        if (not isValid or not data) then return end

        -- Add onto the high value
        data.values[secondary].value = Z.numbers.round(data.values[secondary].value + amount, Config.Settings.decimalAccuracy)
        if (data.values[secondary].value > 100.0) then
            data.values[secondary].value = 100.0
        end

        return true
    end,
    onRemove = function(plyId, name, amount)
        local isValid, data, primary, secondary = ValidateStatusModification(plyId, name)
        if (not isValid or not data) then return end

        -- Remove from the high value
        data.values[secondary].value = Z.numbers.round(data.values[secondary].value - amount, Config.Settings.decimalAccuracy)
        if (data.values[secondary].value < 0.0) then
            data.values[secondary].value = 0.0
        end

        return true
    end,
    onReset = function(plyId, name)
        local isValid, data, primary, secondary = ValidateStatusModification(plyId, name)
        if (not isValid or not data) then return end

        data.values[secondary].value = 0.0

        return true
    end
})