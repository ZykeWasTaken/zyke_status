if (Config.Settings.backwardsCompatibility.enabled ~= true) then return end

CompatibilityFuncs = {}

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

-- Is this event even needed between here to dispatch it further, I remember I did some event weirdly because of net stuff?
RegisterNetEvent("zyke_status:compatibility:onTick", function(values)
    TriggerEvent("esx_status:onTick", values)
end)

---@param name string
local function convertStatus(name)
    local data = Cache.statuses
    if (not data) then error("Attempting to create a player base status, but the player is not cached, critical!") return {} end

    if (Framework == "ESX") then
        if (not data[name]) then return nil end

        local val = data[name].values[name].value
        return {name = name, val = math.floor(val * 10000), percent = val}
    elseif (Framework == "QB") then
    end
end

-- Same as the fetching, we need to make sure the resource is backwards compatible with other systems
-- We take our data and translate it to the base of the framework
---@return table
---@diagnostic disable-next-line: duplicate-set-field
function CompatibilityFuncs.CreateBasePlayerStatus(plyId)
    if (Framework == "ESX") then
        local baseStatus = {
            convertStatus("hunger"),
            convertStatus("thirst"),
            convertStatus("stress"),
            convertStatus("drunk"),
        }

        return baseStatus
    elseif (Framework == "QB") then
        local baseStatus = {}

        return baseStatus
    end

    error("MISSING SUPPORTED FRAMEWORK!")

    return {}
end

RegisterNetEvent("esx_status:getStatus", function(name, cb)
    cb(convertStatus(name))
end)

-- We catch this to heal the player and reset our statuses properly
-- We advise you to disable the esx_basicneeds equivilent if you know what you are doing, but not necessary
RegisterNetEvent("esx_basicneeds:healPlayer", function()
    TriggerServerEvent("zyke_status:compatibility:HealPlayer")
end)

-- We catch this to heal the player and reset our statuses properly
-- We advise you to disable the esx_basicneeds equivilent if you know what you are doing, but not necessary
RegisterNetEvent("esx_basicneeds:resetStatus", function()
    TriggerServerEvent("zyke_status:compatibility:SoftResetStatuses")
end)