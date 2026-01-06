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
---@return table | nil
---@diagnostic disable-next-line: duplicate-set-field
local function convertStatus(name)
    local useDummyReturn = Config.Settings.backwardsCompatibility.dummyReturn
    local dummyReturnVal = GetReversedStatuses()[name] == true and 100.0 or 0.0
    local defaultReturn = useDummyReturn and {name = name, val = dummyReturnVal * 10000, percent = dummyReturnVal, getPercent = function() return dummyReturnVal end} or nil

    local data = Cache.statuses
    if (not data) then
        if (useDummyReturn) then
            if (Config.Settings.debug) then
                Z.debug("Attempting to create a player base status, but the player is not cached, could be critical!")
            end
        else
            print("^1[WARNING] Attempting to create a player base status, but the player is not cached, could be critical! Enable dummy returns or fix the code grabbing this data.^7")
        end

        return defaultReturn
    end

    if (Framework == "ESX") then
        if (not data[name]) then return defaultReturn end

        -- Grab the status from our cache, but also check if it was initialized
        -- If the status was not initialized, we mimick the default esx_status behaviour of not callbacking anything
        -- If you enable `dummyReturn`, you will always get a value back, so this behaviour would depend on each server's needs
        local rawStatus, wasInitialized = GetRawStatus({name, name})
        if (not wasInitialized) then return defaultReturn end

        local val = rawStatus?.value

        return val ~= nil and {name = name, val = math.floor(val * 10000), percent = val, getPercent = function() return val end} or defaultReturn
    elseif (Framework == "QB") then
        -- Unused for now
    end
end

-- Same as the fetching, we need to make sure the resource is backwards compatible with other systems
-- We take our data and translate it to the base of the framework
---@return table
---@diagnostic disable-next-line: duplicate-set-field
function CompatibilityFuncs.CreateBasePlayerStatus(plyId)
    if (Framework == "ESX") then
        local statuses = {}
        statuses[#statuses+1] = convertStatus("hunger")
        statuses[#statuses+1] = convertStatus("thirst")
        statuses[#statuses+1] = convertStatus("stress")
        statuses[#statuses+1] = convertStatus("drunk")

        return statuses
    elseif (Framework == "QB") then
        local baseStatus = {}

        return baseStatus
    end

    error("MISSING SUPPORTED FRAMEWORK!")

    return {}
end

---@param name StatusName
---@param cb function
RegisterNetEvent("esx_status:getStatus", function(name, cb)
    local status = convertStatus(name)

    -- Mimick what the default esx_status event does, it doesn't cb anything unless you have cached values
    if (not status) then return end

    cb(status)
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

-- Since all of their healing is done in their ambulance resource, we will just soft reset afterwards
RegisterNetEvent("hospital:client:Revive", function()
    TriggerServerEvent("zyke_status:compatibility:SoftResetStatuses")
end)

-- Since all of their healing is done in their ambulance resource, we will just soft reset afterwards
RegisterNetEvent("hospital:client:TreatWounds", function()
    TriggerServerEvent("zyke_status:compatibility:SoftResetStatuses")
end)

-- wasabi_ambulance events that are triggered when you run their reviving / healing
-- It is triggered from their server command -> client, so we catch these events & dispatch it to our server-event to handle it properly
-- If you know what you are doing, you can disable these & add in your own custom implementation to never leave the server for this, but that is not possible by default
RegisterNetEvent("wasabi_ambulance:revive", function()
    TriggerServerEvent("zyke_status:compatibility:HealPlayer")
end)

RegisterNetEvent("wasabi_ambulance:heal", function()
    TriggerServerEvent("zyke_status:compatibility:HealPlayer")
end)