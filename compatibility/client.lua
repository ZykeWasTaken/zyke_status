if (Config.Settings.backwardsCompatibility ~= true) then return end

-- esx_status
-- Default max is 1000000, we use 100.0
RegisterNetEvent("esx_status:set", function(name, value)
    TriggerServerEvent("zyke_status:compatibility:SetStatus", name, value)
end)

RegisterNetEvent("esx_status:add", function(name, value)
    TriggerServerEvent("zyke_status:compatibility:AddStatus", name, value)
end)

RegisterNetEvent("esx_status:remove", function(name, value)
    TriggerServerEvent("zyke_status:compatibility:RemoveStatus", name, value)
end)

RegisterNetEvent("zyke_status:compatibility:onTick", function(values)
    TriggerEvent("esx_status:onTick", values)
end)