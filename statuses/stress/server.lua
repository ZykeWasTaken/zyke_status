local primary = "stress"
RegisterStatusType(primary, false, {value = 0.0},
{
    -- onTick = function()

    -- end,
    onAdd = function(plyId, primary, secondary, amount)
        local data = GetPlayerBaseStatusTable(plyId, primary)
        if (not data) then return end

        -- Add onto the stress value
        data.values[secondary].value = Z.numbers.round(data.values[secondary].value + amount, Config.Settings.decimalAccuracy)
        if (data.values[secondary].value > 100.0) then
            data.values[secondary].value = 100.0
        end

        return true
    end,
    onRemove = function(plyId, primary, secondary, amount)
        local data = GetPlayerBaseStatusTable(plyId, primary)
        if (not data) then return end

        -- Remopve from the stress value
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

        return true
    end,
    onReset = function(plyId, primary, secondary)
        local data = GetPlayerBaseStatusTable(plyId, primary)
        if (not data) then return end

        data.values[secondary].value = 0.0

        return true
    end
})