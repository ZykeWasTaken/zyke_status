Z.callback.register("zyke_status:GetPlayerStatus", function(plyId) return GetAllRawStatuses(plyId) end)

if (Config.Settings.stressEvents.gainStress == true) then
    RegisterNetEvent("hud:server:RelieveStress", function(amount)
        if (amount <= 0) then return end

        local prev = GetStatus(source, "stress", "stress")
        local newVal = prev - amount
        if (newVal < 0) then newVal = 0 end

        SetStatusValue(source, "stress", "stress", newVal)
    end)
end

if (Config.Settings.stressEvents.relieveStress) then
    RegisterNetEvent("hud:server:GainStress", function(amount)
        if (amount < 0) then return end

        local prev = GetStatus(source, "stress", "stress")
        local newVal = prev + amount
        if (newVal > 100) then newVal = 100 end

        SetStatusValue(source, "stress", "stress", newVal)
    end)
end