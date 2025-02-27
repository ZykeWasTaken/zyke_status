local primary = "thirst"
RegisterStatusType(primary, false, {value = 100.0},
{
    onTick = function(players, multiplier)
        for plyId, status in pairs(players) do
            for subName, values in pairs(status.values) do
                local statusSettings = GetStatusSettings({primary, subName})
                if (not statusSettings) then return end

                local val = (statusSettings?.value?.drain or 0) * multiplier

                if (val > 0) then
                    RemoveFromStatus(plyId, {primary, subName}, val, true)
                end
            end
        end
    end,
    onAdd = function(plyId, statusNames, amount)
        local secondary = statusNames[2] or primary

        local data = GetPlayerBaseStatusTable(plyId, primary)
        if (not data) then return end

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

        data.values[secondary].value = Z.numbers.round(data.values[secondary].value - amount, Config.Settings.decimalAccuracy)
        if (data.values[secondary].value < 0.0) then
            data.values[secondary].value = 0.0
        end

        return true
    end,
    onSet = function(plyId, statusNames, amount)
        local secondary = statusNames[2] or primary

        local data = GetPlayerBaseStatusTable(plyId, primary)
        if (not data) then return end

        local newVal = Z.numbers.round(amount, Config.Settings.decimalAccuracy)
        if (newVal > 100.0) then newVal = 100.0 end

        data.values[secondary].value = newVal

        return true, newVal
    end,
    onReset = function(plyId, statusNames)
        local secondary = statusNames[2] or primary

        local data = GetPlayerBaseStatusTable(plyId, primary)
        if (not data) then return end

        data.values[secondary].value = 100.0

        return true
    end
})