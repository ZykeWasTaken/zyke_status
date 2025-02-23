if (Config.Settings.backwardsCompatibility.enabled ~= true) then return end

CompatibilityFuncs = {}

-- esx_status
-- Default max is 1000000, we use 100.0
RegisterNetEvent("zyke_status:compatibility:SetStatus", function(name, value)
    -- Perhaps also just take a set as a sort of reset, some stuff like addiction will otherwise have issues, unless we only use hunger/thirst/stress from the default systems, bnecause then the addition of setting a value is pretty easy
    if (name == "hunger") then
        SetStatusValue(source, "hunger", "hunger", value / 10000)
    elseif (name == "thirst") then
        SetStatusValue(source, "thirst", "thirst", value / 10000)
    else
        print("Attempting to add to invalid status:", name)
    end
end)

RegisterNetEvent("zyke_status:compatibility:AddStatus", function(name, value)
    if (Config.Settings.debug) then
        Z.debug(("%s added %s to status and gained %s via compatibility."):format(source, name, value / 10000))
    end

    if (name == "hunger") then
        AddToStatus(source, "hunger", "hunger", value / 10000)
    elseif (name == "thirst") then
        AddToStatus(source, "thirst", "thirst", value / 10000)
    else
        print("Attempting to add to invalid status:", name)
    end
end)

RegisterNetEvent("zyke_status:compatibility:RemoveStatus", function(name, value)
    if (Config.Settings.debug) then
        Z.debug(("%s removed %s from status and gained %s via compatibility."):format(source, name, value / 10000))
    end

    if (name == "hunger") then
        RemoveFromStatus(source, "hunger", "hunger", value / 10000)
    elseif (name == "thirst") then
        RemoveFromStatus(source, "thirst", "hunger", value / 10000)
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
---@diagnostic disable-next-line: duplicate-set-field
local function convertStatus(plyId, name)
    local data = Cache.statuses[plyId]
    if (not data) then error("Attempting to create a player base status, but the player is not cached, critical!") return {} end

    if (Framework == "ESX") then
        if (not data[name]) then return nil end

        local val = data[name].values[name].value
        return {name = name, val = math.floor(val * 10000), percent = val}
    elseif (Framework == "QB") then
        return data[name].values[name].value
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

-- TODO: Clear on leave
---@type table<PlayerId, OsTime>
local esxSetMethodUpdateInterval = {}

---@type table<PlayerId, OsTime>
local qbSetMethodUpdateInterval = {}

---@param plyId PlayerId
RegisterNetEvent("zyke_lib:OnCharacterLogout", function(plyId)
    esxSetMethodUpdateInterval[plyId] = nil
    qbSetMethodUpdateInterval[plyId] = nil
end)

---@param plyId PlayerId
function CompatibilityFuncs.SetStatus(plyId)
    local status = CompatibilityFuncs.CreateBasePlayerStatus(plyId)

    if (Framework == "ESX") then
        -- Updated every minute by default in ESX
        if (os.time() - (esxSetMethodUpdateInterval[plyId] or 0) >= 60) then
            esxSetMethodUpdateInterval[plyId] = os.time()

            local player = Z.getPlayerData(plyId)
            if (not player) then return end

            player.set("status", status)
        end

        TriggerClientEvent("zyke_status:compatibility:onTick", plyId, status)
    elseif (Framework == "QB") then
        -- Updated every 5 minutes by default in QB, or once at the end when food is consumed
        -- TODO: Create some function for zyke_consumables to trigger, onFinished or something, so that we can track when we should perform a manual save
        if (os.time() - (qbSetMethodUpdateInterval[plyId] or 0) >= 300) then
            qbSetMethodUpdateInterval[plyId] = os.time()

            local ply = Z.getPlayerData(plyId)
            if (not ply) then return end

            ply.Functions.SetMetaData("hunger", status.hunger)
            ply.Functions.SetMetaData("thirst", status.thirst)
            ply.Functions.SetMetaData("stress", status.stress)
        end

        TriggerClientEvent("hud:client:UpdateNeeds", plyId, status.hunger, status.thirst)
        TriggerClientEvent("hud:client:UpdateStress", plyId, status.stress)
    end
end

-- ---@param plyId PlayerId
-- function CompatibilityFuncs.SaveStatus(plyId)
--     if (not Cache.statuses[plyId]) then return end

--     local status = CompatibilityFuncs.CreateBasePlayerStatus(plyId)
--     local identifier = Z.getIdentifier(plyId)
--     if (not identifier) then return end

--     if (Framework == "ESX") then
--         MySQL.update.await("UPDATE users SET status = ? WHERE identifier = ?", {json.encode(status), identifier})
--     elseif (Framework == "QB") then
--     end
-- end

-- ---@param plyId PlayerId
-- AddEventHandler("zyke_lib:OnCharacterLogout", function(plyId)
--     CompatibilityFuncs.SaveStatus(plyId)
-- end)