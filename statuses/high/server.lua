local primary = "high"
local primarySettings = Config.Status[primary]

RegisterStatusType(primary, true, {value = 0.0},
{
    onTick = function(players)
        for i = 1, #players do
            local plyId = players[i][1]
            local statuses = players[i][2]

            for j = 1, #statuses do
                local name, multiplier = statuses[j][1], statuses[j][2]
                local secSettings = primarySettings[name] or primarySettings.base
                local val = (secSettings?.value?.drain or 0) * multiplier

                if (val > 0.0) then
                    RemoveFromStatus(plyId, {primary, name}, val, true)
                end
            end
        end
    end,
    onAdd = function(plyId, statusNames, amount)
        local secondary = statusNames[2] or primary

        local data = GetPlayerBaseStatusTable(plyId, primary)
        if (not data) then return end

        -- Add onto the high value
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

        -- Remove from the high value
        data.values[secondary].value = Z.numbers.round(data.values[secondary].value - amount, Config.Settings.decimalAccuracy)
        if (data.values[secondary].value < 0.0) then
            data.values[secondary].value = 0.0
        end

        return true
    end,
    onReset = function(plyId, statusNames)
        local secondary = statusNames[2] or primary

        local data = GetPlayerBaseStatusTable(plyId, primary)
        if (not data) then return end

        data.values[secondary] = nil

        return true
    end
})