if (Config.Settings.backwardsCompatibility ~= true) then return end

CompatibilityFuncs = {}

-- esx_status
-- Default max is 1000000, we use 100.0
RegisterNetEvent("zyke_status:compatibility:SetStatus", function(name, value)
    -- TODO: Add a set function
    -- Perhaps also just take a set as a sort of reset, some stuff like addiction will otherwise have issues, unless we only use hunger/thirst/stress from the default systems, bnecause then the addition of setting a value is pretty easy
end)

RegisterNetEvent("zyke_status:compatibility:AddStatus", function(name, value)
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

RegisterNetEvent("zyke_status:compatibility:RemoveStatus", function(name, value)
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

-- This will fetch the base status for your framework
-- This needs to be converted to work with our structure from all different frameworks
---@param player table
---@return table
function CompatibilityFuncs.GetBasePlayerStatus(player)
    if (Framework == "ESX") then
        local status = {}

        return status
    elseif (Framework == "QB") then
        local status = {}

        return status
    end

    error("MISSING SUPPORTED FRAMEWORK!")

    return {}
end

-- Same as the fetching, we need to make sure the resource is backwards compatible with other systems
-- We take our data and translate it to the base of the framework
---@param plyId PlayerId
---@return table
function CompatibilityFuncs.CreateBasePlayerStatus(plyId)
    local data = Cache.statuses[plyId]
    if (not data) then error("Attempting to create a player base status, but the player is not cached, critical!") return {} end

    if (Framework == "ESX") then
        local hunger = data.hunger.values.hunger.value
        local thirst = data.thirst.values.thirst.value

        local baseStatus = {
            {name = "hunger", val = math.floor(hunger * 10000), percent = hunger},
            {name = "thirst", val = math.floor(thirst * 10000), percent = thirst},
            {name = "drunk", val = 0, percent = 0.0}, -- TODO
        }

        return baseStatus
    elseif (Framework == "QB") then
        local baseStatus = {}

        return baseStatus
    end

    error("MISSING SUPPORTED FRAMEWORK!")

    return {}
end

---@param plyId PlayerId
function CompatibilityFuncs.SetStatus(plyId)
    local status = CompatibilityFuncs.CreateBasePlayerStatus(plyId)

    if (Framework == "ESX") then
        local player = Z.getPlayerData(plyId)
        if (not player) then return end

        print("Setting status", status, player)
        player.set("status", status)
        TriggerClientEvent("zyke_status:compatibility:onTick", plyId, status)
    elseif (Framework == "QB") then

    end
end

---@param plyId PlayerId
function CompatibilityFuncs.SaveStatus(plyId)
    local status = CompatibilityFuncs.CreateBasePlayerStatus(plyId)
    local identifier = Z.getIdentifier(plyId)
    print("SaveStatus", plyId, identifier)
    if (not identifier) then return end

    if (Framework == "ESX") then
        MySQL.update.await("UPDATE users SET status = ? WHERE identifier = ?", {json.encode(status), identifier})
    elseif (Framework == "QB") then
    end
end

---@param plyId PlayerId
AddEventHandler("zyke_lib:OnCharacterLogout", function(plyId)
    CompatibilityFuncs.SaveStatus(plyId)
end)