if (Config.Settings.backwardsCompatibility ~= true) then return end

CompatibilityFuncs = {}

-- esx_status
-- Default max is 1000000, we use 100.0
RegisterNetEvent("zyke_status:compatibility:SetStatus", function(name, value)
    -- TODO: Add a set function
    -- Perhaps also just take a set as a sort of reset, some stuff like addiction will otherwise have issues, unless we only use hunger/thirst/stress from the default systems, bnecause then the addition of setting a value is pretty easy
    if (name == "hunger") then
        SetStatusValue(source, "hunger", value / 10000)
    elseif (name == "thirst") then
        SetStatusValue(source, "thirst", value / 10000)
    else
        print("Attempting to add to invalid status:", name)
    end
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

---@param plyId PlayerId
---@param name string
---@diagnostic disable-next-line: duplicate-set-field
function CompatibilityFuncs.ConvertStatus(plyId, name)
    local data = Cache.statuses[plyId]
    if (not data) then error("Attempting to create a player base status, but the player is not cached, critical!") return {} end

    if (Framework == "ESX") then
        if (not data[name]) then return nil end

        local val = data[name].values[name].value
        return {name = name, val = math.floor(val * 10000), percent = val}
    elseif (Framework == "QB") then
    end
end

-- {
--     "name": "drunk",
--     "val": 0,
--     "percent": 0.0
-- }

-- Same as the fetching, we need to make sure the resource is backwards compatible with other systems
-- We take our data and translate it to the base of the framework
---@param plyId PlayerId
---@return table
---@diagnostic disable-next-line: duplicate-set-field
function CompatibilityFuncs.CreateBasePlayerStatus(plyId)
    if (Framework == "ESX") then
        local baseStatus = {
            CompatibilityFuncs.ConvertStatus(plyId, "hunger"),
            CompatibilityFuncs.ConvertStatus(plyId, "thirst"),
            CompatibilityFuncs.ConvertStatus(plyId, "stress"),
            CompatibilityFuncs.ConvertStatus(plyId, "drunk"),
        }

        return baseStatus
    elseif (Framework == "QB") then
        local baseStatus = {}

        return baseStatus
    end

    error("MISSING SUPPORTED FRAMEWORK!")

    return {}
end

RegisterNetEvent("esx_status:getStatus", function(target, name, cb)
    cb(CompatibilityFuncs.ConvertStatus(target, name))
end)

---@param plyId PlayerId
function CompatibilityFuncs.SetStatus(plyId)
    local status = CompatibilityFuncs.CreateBasePlayerStatus(plyId)

    if (Framework == "ESX") then
        local player = Z.getPlayerData(plyId)
        if (not player) then return end

        player.set("status", status)
        TriggerClientEvent("zyke_status:compatibility:onTick", plyId, status)
    elseif (Framework == "QB") then

    end
end

---@param plyId PlayerId
function CompatibilityFuncs.SaveStatus(plyId)
    if (not Cache.statuses[plyId]) then return end

    local status = CompatibilityFuncs.CreateBasePlayerStatus(plyId)
    local identifier = Z.getIdentifier(plyId)
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

---@return string[]
local function getSupportedResources()
    local _supported = {}
    local num = GetNumResourceMetadata(ResName, "provide")
    for i = 1, num do
        _supported[#_supported+1] = GetResourceMetadata(ResName, "provide", num - 1)
    end

    return _supported
end

-- Because of the fxmanifest `provides`, there are some weird behaviours of starting and stopping resources
-- Simply check if any of the supported systems are listed to be started and warn the server owner
local supported = Z.table.new(getSupportedResources())

-- Put this in a loop, in case it is somehow missed
-- Having a backwards compatible resource WILL cause MAJOR issues
while (1) do
    local warnings = 0

    for i = 1, #supported do
        local resState = GetResourceState(supported[i])
        if (resState == "started" or resState == "starting") then
            warnings += 1
            print(("^1[IMPORTANT] A backwards compatible resource has been detected (%s). If this resource is started, it will cause issues."):format(supported[i]))
            print("[IMPORTANT] Please remove the backward compatible resource from your server!^7")
        end
    end

    if (warnings == 0) then break end

    Wait(3000)
end