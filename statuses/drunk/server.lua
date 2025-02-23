local primary = "drunk"
RegisterStatusType(primary, false, {value = 0.0},
{
    onTick = function(players)
        for plyId, status in pairs(players) do
            for subName, values in pairs(status.values) do
                local statusSettings = GetStatusSettings(primary, subName)

                RemoveFromStatus(plyId, primary, subName, statusSettings?.value?.drain or 0, true)
            end
        end
    end,
    onAdd = function(plyId, primary, secondary, amount)
        local data = GetPlayerBaseStatusTable(plyId, primary)
        if (not data) then return end

        -- Add onto the drunk value
        data.values[secondary].value = Z.numbers.round(data.values[secondary].value + amount, Config.Settings.decimalAccuracy)
        if (data.values[secondary].value > 100.0) then
            data.values[secondary].value = 100.0
        end

        return true
    end,
    onRemove = function(plyId, primary, secondary, amount)
        local data = GetPlayerBaseStatusTable(plyId, primary)
        if (not data) then return end

        -- Remopve from the drunk value
        data.values[secondary].value = Z.numbers.round(data.values[secondary].value - amount, Config.Settings.decimalAccuracy)
        if (data.values[secondary].value < 0.0) then
            data.values[secondary].value = 0.0
        end

        return true
    end,
    onReset = function(plyId, primary, secondary)
        local data = GetPlayerBaseStatusTable(plyId, primary)
        if (not data) then return end

        data.values[secondary].value = 0.0

        return true
    end
})