RegisterStatusType("stress", false, {value = 0.0},
{
    onTick = function()

    end,
    onAdd = function(plyId, name, amount)
        local isValid, data, primary, secondary = ValidateStatusModification(plyId, name)
        if (not isValid or not data) then return end

        -- Add onto the stress value
        data.values[secondary].value = Z.numbers.round(data.values[secondary].value + amount, Config.Settings.decimalAccuracy)
        if (data.values[secondary].value > 100.0) then
            data.values[secondary].value = 100.0
        end

        return true
    end,
    onRemove = function(plyId, name, amount)
        local isValid, data, primary, secondary = ValidateStatusModification(plyId, name)
        if (not isValid or not data) then return end

        -- Remopve from the stress value
        data.values[secondary].value = Z.numbers.round(data.values[secondary].value - amount, Config.Settings.decimalAccuracy)
        if (data.values[secondary].value < 0.0) then
            data.values[secondary].value = 0.0
        end

        return true
    end,
    onReset = function(plyId, name)
        local isValid, data, primary, secondary = ValidateStatusModification(plyId, name)
        if (not isValid or not data) then return end

        data.values[secondary].value = 100.0
    end
})