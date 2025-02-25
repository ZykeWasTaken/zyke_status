local primary = "hunger"
RegisterStatusType(primary, false, {value = 100.0},
{
    onTick = function(players, multiplier)
        for plyId, status in pairs(players) do
            for subName, values in pairs(status.values) do
                local statusSettings = GetStatusSettings(primary, subName)
                local val = (statusSettings?.value?.drain or 0) * multiplier

                if (val > 0) then
                    RemoveFromStatus(plyId, primary, subName, val, true)
                end
            end
        end
    end,
    onAdd = function(plyId, primary, secondary, amount)
        local data = GetPlayerBaseStatusTable(plyId, primary)
        if (not data) then return end

        -- Add onto the hunger value
        data.values[secondary].value = Z.numbers.round(data.values[secondary].value + amount, Config.Settings.decimalAccuracy)
        if (data.values[secondary].value > 100.0) then
            data.values[secondary].value = 100.0
        end

        return true
    end,
    onRemove = function(plyId, primary, secondary, amount)
        local data = GetPlayerBaseStatusTable(plyId, primary)
        if (not data) then return end

        -- Remove from the hunger value
        data.values[secondary].value = Z.numbers.round(data.values[secondary].value - amount, Config.Settings.decimalAccuracy)
        if (data.values[secondary].value < 0.0) then
            data.values[secondary].value = 0.0
        end

        return true
    end,
    onSet = function(plyId, primary, secondary, amount)
        local data = GetPlayerBaseStatusTable(plyId, primary)
        if (not data) then return end

        data.values[secondary].value = Z.numbers.round(amount, Config.Settings.decimalAccuracy)

        return true, data.values[secondary].value
    end,
    onReset = function(plyId, primary, secondary)
        local data = GetPlayerBaseStatusTable(plyId, primary)
        if (not data) then return end

        data.values[secondary].value = 100.0

        return true
    end
})