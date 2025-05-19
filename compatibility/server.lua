if (Config.Settings.backwardsCompatibility.enabled ~= true) then return end

CompatibilityFuncs = {}

---@type table<PrimaryName, true>
local existingESXStatuses = {
    ["hunger"] = true,
    ["thirst"] = true,
    ["drunk"] = true,
    ["stress"] = true, -- Not really default, but exists frequently in resources and by default within our systems
}

-- esx_status
-- Default max is 1000000, we use 100.0
RegisterNetEvent("zyke_status:compatibility:SetStatus", function(name, value)
    if (Config.Settings.debug) then
        Z.debug(("%s set status %s to %s via compatibility."):format(source, name, value / 10000))
    end

    if (not existingESXStatuses[name]) then print("Attempting to set invalid status:", name) return end

    SetStatusValue(source, {name}, value / 10000)
end)

RegisterNetEvent("zyke_status:compatibility:AddStatus", function(name, value)
    if (Config.Settings.debug) then
        Z.debug(("%s added %s to status and gained %s via compatibility."):format(source, name, value / 10000))
    end

    if (not existingESXStatuses[name]) then print("Attempting to set invalid status:", name) return end

    AddToStatus(source, {name}, value / 10000)
end)

RegisterNetEvent("zyke_status:compatibility:RemoveStatus", function(name, value)
    if (Config.Settings.debug) then
        Z.debug(("%s removed %s from status and gained %s via compatibility."):format(source, name, value / 10000))
    end

    if (not existingESXStatuses[name]) then print("Attempting to set invalid status:", name) return end

    RemoveFromStatus(source, {name}, value / 10000)
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

if (Config.Settings.backwardsCompatibility.addThirstEvent) then
    RegisterNetEvent("consumables:server:addThirst", function(amount)
        SetStatusValue(source, {"thirst"}, amount, false)
    end)
end

if (Config.Settings.backwardsCompatibility.addHungerEvent) then
    RegisterNetEvent("consumables:server:addHunger", function(amount)
        SetStatusValue(source, {"hunger"}, amount, false)
    end)
end