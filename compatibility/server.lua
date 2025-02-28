if (Config.Settings.backwardsCompatibility.enabled ~= true) then return end

CompatibilityFuncs = {}

-- esx_status
-- Default max is 1000000, we use 100.0
RegisterNetEvent("zyke_status:compatibility:SetStatus", function(name, value)
    -- Perhaps also just take a set as a sort of reset, some stuff like addiction will otherwise have issues, unless we only use hunger/thirst/stress from the default systems, bnecause then the addition of setting a value is pretty easy
    if (name == "hunger") then
        SetStatusValue(source, {"hunger"}, value / 10000)
    elseif (name == "thirst") then
        SetStatusValue(source, {"thirst"}, value / 10000)
    else
        print("Attempting to add to invalid status:", name)
    end
end)

RegisterNetEvent("zyke_status:compatibility:AddStatus", function(name, value)
    if (Config.Settings.debug) then
        Z.debug(("%s added %s to status and gained %s via compatibility."):format(source, name, value / 10000))
    end

    if (name == "hunger") then
        AddToStatus(source, {"hunger"}, value / 10000)
    elseif (name == "thirst") then
        AddToStatus(source, {"thirst"}, value / 10000)
    else
        print("Attempting to add to invalid status:", name)
    end
end)

RegisterNetEvent("zyke_status:compatibility:RemoveStatus", function(name, value)
    if (Config.Settings.debug) then
        Z.debug(("%s removed %s from status and gained %s via compatibility."):format(source, name, value / 10000))
    end

    if (name == "hunger") then
        RemoveFromStatus(source, {"hunger"}, value / 10000)
    elseif (name == "thirst") then
        RemoveFromStatus(source, {"thirst"}, value / 10000)
    else
        print("Attempting to remove from invalid status:", name)
    end
end)

RegisterNetEvent("zyke_status:compatibility:HealPlayer", function()
    if (Config.Settings.debug) then
        Z.debug(("%s has triggered HealPlayer via compatibility."):format(source))
    end

    HealPlayer(source)
end)

RegisterNetEvent("zyke_status:compatibility:SoftResetStatuses", function()
    if (Config.Settings.debug) then
        Z.debug(("%s has triggered HealPlayer via compatibility."):format(source))
    end

    SoftResetStatuses(source)
end)

AddEventHandler("txAdmin:events:healedPlayer", function(eventData)
    if (GetInvokingResource() ~= "monitor" or type(eventData) ~= "table" or type(eventData.id) ~= "number") then return end

    TriggerClientEvent("esx_basicneeds:healPlayer", eventData.id)
end)

---@param plyId PlayerId
---@param name string
---@return table | number | nil
---@diagnostic disable-next-line: duplicate-set-field
local function convertStatus(plyId, name)
    local defaultESX, defaultQB = {name = name, val = 1000000, percent = 100}, 100
    local defaultReturn = Config.Settings.backwardsCompatibility.dummyReturn and (Framework == "ESX" and defaultESX or defaultQB) or nil

    local data = Cache.statuses[plyId]
    if (not data) then error("Attempting to create a player base status, but the player is not cached, critical!") return defaultReturn end

    if (Framework == "ESX") then
        if (not data[name]) then return defaultReturn end

        local val = data[name].values[name].value

        return val == nil and defaultReturn or {name = name, val = math.floor(val * 10000), percent = val}
    elseif (Framework == "QB") then
        local val = data[name].values[name].value

        return val == nil and defaultReturn or val
    end
end

-- Same as the fetching, we need to make sure the resource is backwards compatible with other systems
-- We take our data and translate it to the base of the framework
---@param plyId PlayerId
---@return table
---@diagnostic disable-next-line: duplicate-set-field
function CompatibilityFuncs.CreateBasePlayerStatus(plyId)
    if (Framework == "ESX") then
        return {
            convertStatus(plyId, "hunger"),
            convertStatus(plyId, "thirst"),
            convertStatus(plyId, "stress"),
            convertStatus(plyId, "drunk"),
        }
    elseif (Framework == "QB") then
        return {
            ["hunger"] = convertStatus(plyId, "hunger"),
            ["thirst"] = convertStatus(plyId, "thirst"),
            ["stress"] = convertStatus(plyId, "stress"),
        }
    end

    error("MISSING SUPPORTED FRAMEWORK!")

    return {}
end

RegisterNetEvent("esx_status:getStatus", function(target, name, cb)
    cb(convertStatus(target, name))
end)

RegisterNetEvent("consumables:server:addThirst", function(amount)
    SetStatusValue(source, {"thirst"}, amount, false)
end)

RegisterNetEvent("consumables:server:addHunger", function(amount)
    SetStatusValue(source, {"hunger"}, amount, false)
end)