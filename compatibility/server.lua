if (Config.Settings.backwardsCompatibility ~= true) then return end

-- esx_status
-- Default max is 1000000, we use 100.0
RegisterNetEvent("zyke_consumables:compatibility:SetStatus", function(name, value)
    -- TODO: Add a set function
    -- Perhaps also just take a set as a sort of reset, some stuff like addiction will otherwise have issues, unless we only use hunger/thirst/stress from the default systems, bnecause then the addition of setting a value is pretty easy
end)

RegisterNetEvent("zyke_consumables:compatibility:AddStatus", function(name, value)
    if (Config.Settings.debug) then
        Z.debug(("%s added %s to status and gained %s via compatibility."):format(source, name, value / 10000))
    end

    if (name == "hunger") then
        AddToStatus(source, "hunger", value / 10000)
    elseif (name == "thirst") then
        AddToStatus(source, "thirst", value / 10000)
    else
        print("Attempting to add to invalid status:", name)
    end
end)

RegisterNetEvent("zyke_consumables:compatibility:RemoveStatus", function(name, value)
    if (Config.Settings.debug) then
        Z.debug(("%s removed %s from status and gained %s via compatibility."):format(source, name, value / 10000))
    end

    if (name == "hunger") then
        RemoveFromStatus(source, "hunger", value / 10000)
    elseif (name == "thirst") then
        RemoveFromStatus(source, "thirst", value / 10000)
    else
        print("Attempting to remove from invalid status:", name)
    end
end)