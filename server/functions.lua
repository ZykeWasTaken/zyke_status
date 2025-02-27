---@param plyId PlayerId
function GetAllRawStatuses(plyId)
    return Cache.statuses[plyId] or {}
end

-- Cache when you last had an update, so that we can attempt to keep the data up to date smoother
-- Utilizing a 25ms threshold we can catch everything that wants to update and perform it instantly
-- All requests within a second of the first update will be queued and executed once the timeout is done
-- This approach keeps the data up to date, without spamming spamming just in case there's tons requests to update every second.
-- This is different from clientSyncQueue, as that just collects what has to be synced
---@type table<PlayerId, OsTime>
local clientLastUpdated = {}

-- Create a queue, to prevent multiple events being sent
---@type table<PlayerId, {toSync: table<StatusName, true>}>
local clientSyncQueue = {}

-- Cache for better performance
local framework, backwardsCompatibility = Framework, Config.Settings.backwardsCompatibility

local esxSetMethodUpdateInterval = {}

---@type table<PlayerId, OsTime>
local qbSetMethodUpdateInterval = {}

---@param plyId PlayerId
RegisterNetEvent("zyke_lib:OnCharacterLogout", function(plyId)
    esxSetMethodUpdateInterval[plyId] = nil
    qbSetMethodUpdateInterval[plyId] = nil
    clientSyncQueue[plyId] = nil
    clientLastUpdated[plyId] = nil
end)

-- To preverse performance, we rarely update the framework data because it uses a lot of performance as is not needed during slow thread updating
-- However, when using an item directly, the update is very sluggish because of the wait, and in some cases may break altogether
-- To combat this, on use, we force a framework update, along with skipping any extended waiting period
-- There is still a 100ms threshold to catch everything to bundle the update, but that is negligable
---@param plyId PlayerId
---@param primary StatusName | StatusName[]
function SyncPlayerStatus(plyId, primary)
    local createdQueue = false
    if (not clientSyncQueue[plyId]) then
        clientSyncQueue[plyId] = {toSync = {}}
        createdQueue = true
    end

    if (type(primary) ~= "table") then
        clientSyncQueue[plyId].toSync[primary] = true
    else
        for _ = 1, #primary do
            clientSyncQueue[plyId].toSync[primary] = true
        end
    end

    if (not createdQueue) then return end

    CreateThread(function()
        if (os.time() - (clientLastUpdated[plyId] or 0) < 1) then
            -- If the last request was made in the span of a second, wait to sync
            while (clientLastUpdated[plyId] ~= nil and os.time() - clientLastUpdated[plyId] < 1) do Wait(100) end -- 1s limit before sending event
        else
            -- Wait a small bit to catch multiple requests to bundle them
            Wait(25)
        end

        -- Make sure the player is still active
        if (not Cache.statuses[plyId]) then
            clientSyncQueue[plyId] = nil
            return
        end

        local statuses = {}
        for key in pairs(clientSyncQueue[plyId].toSync) do
            ---@type table | "nil"
            local val = Cache.statuses[plyId][key]
            if (val == nil) then
                val = "nil" -- Set to nil, to recognize it being removed on the client
            end

            statuses[key] = val
        end

        clientSyncQueue[plyId] = nil
        clientLastUpdated[plyId] = os.time()

        -- FRAMEWORK COMPATIBILITY STUFF
        -- The code below looks a little messy, basically:
        -- We trigger the events & methods the framework does by default, so we can remain fully backwards compatible
        -- Since we don't want to trigger duplicate events, we provide our data in their events, and catch their events on our client side under their name to apply
        -- If you don't have it enabled, we will just send it via our own events
        -- This method is sloppy, but allows us slightly better performance since there is one less event to send and intercept

        if (backwardsCompatibility.enabled == true) then
            local compatStatus = CompatibilityFuncs.CreateBasePlayerStatus(plyId)
            if (framework == "ESX") then
                -- Updated every minute by default in ESX
                if (os.time() - (esxSetMethodUpdateInterval[plyId] or 0) >= 60) then
                    esxSetMethodUpdateInterval[plyId] = os.time()

                    local player = Z.getPlayerData(plyId)
                    if (not player) then return end

                    player.set("status", compatStatus)
                end

                TriggerClientEvent("zyke_status:compatibility:onTick", plyId, compatStatus, statuses)
            elseif (Framework == "QB") then
                -- Updated every 5 minutes by default in QB, or once at the end when food is consumed
                -- TODO: Create some function for zyke_consumables to trigger, onFinished or something, so that we can track when we should perform a manual save
                if (os.time() - (qbSetMethodUpdateInterval[plyId] or 0) >= 300) then
                    qbSetMethodUpdateInterval[plyId] = os.time()

                    local ply = Z.getPlayerData(plyId)
                    if (not ply) then return end

                    ply.Functions.SetMetaData("hunger", compatStatus.hunger)
                    ply.Functions.SetMetaData("thirst", compatStatus.thirst)
                    ply.Functions.SetMetaData("stress", compatStatus.stress)
                end

                TriggerClientEvent("hud:client:UpdateNeeds", plyId, compatStatus.hunger, compatStatus.thirst, statuses)
                TriggerClientEvent("hud:client:UpdateStress", plyId, compatStatus.stress)
            end
        else
            TriggerClientEvent("zyke_status:SyncStatus", plyId, statuses)
        end
    end)
end

-- Returns the entire table to modify
-- This will always go through, since every player is initialized
-- The only exception is if the player has not yet selected a character
-- The secondary, if using multi, is not always guaranteed to exist
---@param plyId PlayerId
---@param primary PrimaryName
---@return PlayerStatuses | nil
function GetPlayerBaseStatusTable(plyId, primary)
    return Cache.statuses[plyId] and Cache.statuses[plyId][primary] or nil
end

---@param plyId PlayerId
---@param primary PrimaryName
---@param secondary SecondaryName
---@return number
function GetStatus(plyId, primary, secondary)
    if (not Cache.statuses[plyId]) then return 0.0 end
    if (not Cache.statuses[plyId][primary]) then return 0.0 end

    local value = GetPlayerBaseStatusTable(plyId, primary)
    return value and value.values?[secondary]?.value or 0.0
end

exports("GetStatus", GetStatus)

---@param plyId PlayerId
---@param primary PrimaryName
---@param secondary SecondaryName
---@param amount number
---@param skipEnsuring? boolean @Only use if you have a pool with ensured players
function RemoveFromStatus(plyId, primary, secondary, amount, skipEnsuring)
    local isValid = IsValidStatus(primary, secondary)
    if (not isValid) then print(("Invalid status has attempted to be removed: %s %s"):format(tostring(primary), tostring(secondary))) return end

    if (not skipEnsuring) then
        EnsurePlayerSubStatus(plyId, primary, secondary)
    end

    local hasRemoved = Cache.existingStatuses[primary].onRemove(plyId, primary, secondary, amount)

    if (hasRemoved) then
        SyncPlayerStatus(plyId, primary)
    end
end

exports("RemoveFromStatus", RemoveFromStatus)

local qbActions = Framework == "QB" and {["stress"] = true, ["hunger"] = true, ["thirst"] = true} or nil

---@param plyId PlayerId
---@param primary PrimaryName
---@param secondary SecondaryName
---@param amount number
---@param skipEnsuring? boolean @Only use if you have a pool with ensured players
function SetStatusValue(plyId, primary, secondary, amount, skipEnsuring)
    local isValid = IsValidStatus(primary, secondary)
    if (not isValid) then print(("Invalid status has attempted to be set: %s %s"):format(tostring(primary), tostring(secondary))) return end

    if (Cache.existingStatuses[primary].onSet) then
        if (not skipEnsuring) then
            EnsurePlayerSubStatus(plyId, primary, secondary)
        end

        local hasRemoved, newVal = Cache.existingStatuses[primary].onSet(plyId, primary, secondary, amount)

        -- All QB status actions are set, which they update instantly, so we'll mimic this
        if (qbActions and qbActions[primary]) then
            local ply = Z.getPlayerData(plyId)
            if (ply) then
                ply.Functions.SetMetaData(primary, newVal)
            end
        end

        if (hasRemoved) then
            SyncPlayerStatus(plyId, primary)
        end
    end
end

exports("SetStatusValue", SetStatusValue)

-- We ensure that the statuses added will be handled in some way, otherwise they will indefinently just stay on our characters unless manually removed
---@param primary PrimaryName
---@param secondary SecondaryName
---@return boolean
function IsValidStatus(primary, secondary)
    if (not Config.Status[primary]) then return false end

    local existingStatus = Cache.existingStatuses[primary]
    if (not existingStatus) then return false end

    -- Verify if the status is allowed to have a substatus
    if (existingStatus.multi == false and secondary ~= primary) then return false end

    return true
end

-- Add value to the status
---@param plyId PlayerId
---@param primary PrimaryName
---@param secondary SecondaryName
---@param amount number
---@param skipEnsuring? boolean @Only use if you have a pool with ensured players
function AddToStatus(plyId, primary, secondary, amount, skipEnsuring)
    if (not skipEnsuring) then
        EnsurePlayerSubStatus(plyId, primary, secondary)
    end

    local isValid = IsValidStatus(primary, secondary)
    if (not isValid) then print(("Invalid status has attempted to be added: %s %s"):format(tostring(primary), tostring(secondary))) return end

    local hasAdded = Cache.existingStatuses[primary].onAdd(plyId, primary, secondary, amount)

    if (hasAdded) then
        SyncPlayerStatus(plyId, primary)
    end
end

exports("AddToStatus", AddToStatus)

---@param plyId PlayerId
function SavePlayerToDatabase(plyId)
    local statuses = Cache.statuses[plyId]
    if (not statuses) then return end

    local plyIdentifier = Z.getIdentifier(plyId)
    if (not plyIdentifier) then return end

    local data = json.encode(statuses)

    Z.debug("Saving status for", plyIdentifier, "to database.")
    MySQL.query.await("INSERT INTO zyke_status (identifier, data) VALUES (?, ?) ON DUPLICATE KEY UPDATE data = ?", {plyIdentifier, data, data})
end

-- Runs onReset for all statuses the player has registered
---@param plyId PlayerId
function ResetStatuses(plyId)
    for primary, statusValues in pairs(Cache.statuses[plyId]) do
        for statusName in pairs(statusValues.values) do
            Z.debug("[ResetStauses] Resetting", primary .. "." .. statusName, "for", plyId)
            Cache.existingStatuses[primary].onReset(plyId, primary, statusName)
        end

        SyncPlayerStatus(plyId, primary)
    end
end

-- Runs onSoftReset and falls back to onReset for all statuses the player has registered
---@param plyId PlayerId
function SoftResetStatuses(plyId)
    for primary, statusValues in pairs(Cache.statuses[plyId]) do
        for statusName in pairs(statusValues.values) do
            Z.debug("[SoftResetStatuses] Resetting", primary .. "." .. statusName, "for", plyId)

            if (Cache.existingStatuses[primary].onSoftReset) then
                Cache.existingStatuses[primary].onSoftReset(plyId, primary, statusName)
            else
                Cache.existingStatuses[primary].onReset(plyId, primary, statusName)
            end
        end
    end

end

local playerHealAuth = {}

-- Function to heal a player, and reset their stats
-- It uses softReset if it exists, falls back to the onReset function
---@param plyId PlayerId
function HealPlayer(plyId)
    Z.debug(("[HEALING] Healing %s"):format(plyId))

    SoftResetStatuses(plyId)

    -- Slightly unsafe event due to FiveM limitations, however, we do warn about heals that are not properly ran
    playerHealAuth[plyId] = true
    TriggerClientEvent("zyke_status:OnHealPlayer", plyId)
end

RegisterNetEvent("zyke_status:OnHealPlayer", function()
    if (not playerHealAuth[source]) then
        print(("^1[WARNING] Player %s has ran the healing event without being authorized to do so. Possible exploit attempt. ^7"):format(source))
    end

    playerHealAuth[source] = nil
end)

exports("HealPlayer", HealPlayer)