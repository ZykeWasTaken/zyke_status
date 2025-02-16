---@param plyId PlayerId
function GetAllRawStatuses(plyId)
    return Cache.statuses[plyId] or {}
end

-- Create a queue, to prevent multiple events being sent
---@type table<PlayerId, {created: OsClock, toSync: table<StatusName, true>}>
local clientSyncQueue = {}

-- Cache for better performance
local framework, backwardsCompatibility = Framework, Config.Settings.backwardsCompatibility

---@param plyId PlayerId
---@param primary StatusName | StatusName[]
function SyncPlayerStatus(plyId, primary)
    local createdQueue = false
    if (not clientSyncQueue[plyId]) then
        clientSyncQueue[plyId] = {created = os.clock(), toSync = {}}
        createdQueue = true
    end

    if (type(primary) ~= "table") then
        primary = {primary}
    end

    for i = 1, #primary do
        clientSyncQueue[plyId].toSync[primary[i]] = true

        -- QBCore compatibility stuff
        if (framework == "QB" and backwardsCompatibility == true) then
            if (primary[i] == "hunger" or primary[i] == "thirst" or primary[i] == "stress") then
                local ply = Z.getPlayerData(plyId)
                if (not ply) then return end

                ply.Functions.SetMetaData(primary[i], Cache.statuses[plyId][primary[i]].values[primary[i]].value)
            end
        end

        -- TODO: Add ESX stuff in here? It goes via onTick, but that system is rather slow compared to how fast we update in consumables
    end

    if (not createdQueue) then return end

    CreateThread(function()
        Wait(25) -- Should sync well even at 1ms for one player, 10ms one a slower machine with a few players, 25ms for a better threshold

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
        TriggerClientEvent("zyke_status:SyncStatus", plyId, statuses)
    end)
end

-- Returns the entire table to modify
-- This will always go through, since every player is initialized
-- The only exception is if the player has not yet selected a character
-- The secondary, if using multi, is not always guaranteed to exist
---@param plyId PlayerId
---@param name StatusName
---@return PlayerStatuses | nil
function GetPlayerBaseStatusTable(plyId, name)
    local primary = SeparateStatusName(name)

    return Cache.statuses[plyId] and Cache.statuses[plyId][primary] or nil
end

---@param plyId PlayerId
---@param name StatusName
---@return number
function GetStatus(plyId, name)
    local primary, secondary = SeparateStatusName(name)

    if (not Cache.statuses[plyId]) then return 0.0 end
    if (not Cache.statuses[plyId][primary]) then return 0.0 end

    local value = GetPlayerBaseStatusTable(plyId, name)
    return value and value.values?[secondary]?.value or 0.0
end

exports("GetStatus", GetStatus)

---@param plyId PlayerId
---@param name StatusName
---@param amount number
function RemoveFromStatus(plyId, name, amount)
    local primary, secondary = SeparateStatusName(name)
    EnsurePlayerSubStatus(plyId, primary, secondary)
    local hasRemoved = Cache.existingStatuses[primary].onRemove(plyId, name, amount)

    if (hasRemoved) then
        SyncPlayerStatus(plyId, primary)
    end
end

exports("RemoveFromStatus", RemoveFromStatus)

function SetStatusValue(plyId, name, amount)
    local primary, secondary = SeparateStatusName(name)
    EnsurePlayerSubStatus(plyId, primary, secondary)

    if (Cache.existingStatuses[primary].onSet) then
        local hasRemoved = Cache.existingStatuses[primary].onSet(plyId, name, amount)
        if (hasRemoved) then
            SyncPlayerStatus(plyId, primary)
        end
    end
end

exports("SetStatusValue", SetStatusValue)

-- Add value to the status
---@param plyId PlayerId
---@param name StatusName
---@param amount number
function AddToStatus(plyId, name, amount)
    local primary, secondary = SeparateStatusName(name)
    EnsurePlayerSubStatus(plyId, primary, secondary)
    local hasAdded = Cache.existingStatuses[primary].onAdd(plyId, name, amount)

    if (hasAdded) then
        SyncPlayerStatus(plyId, primary)
    end
end

exports("AddToStatus", AddToStatus)

RegisterCommand("get_status", function(source, args, raw)
    local status = args[1]
    local amount = GetStatus(source, status)

    print(amount)
end, false)

RegisterCommand("add_to_status", function(source, args)
    local status, amount = args[1], tonumber(args[2])

    AddToStatus(source, status, amount or 1.0)
end, false)

-- Validates the request, and returns the player's status table so that it can be modified
-- Since these two functionalities almost always have to be bundled together, we use this function
---@param plyId PlayerId
---@param name StatusName
function ValidateStatusModification(plyId, name)
    local primary, secondary = SeparateStatusName(name)

    local value = GetPlayerBaseStatusTable(plyId, name)
    if (not value) then return false, nil end

    EnsurePlayerSubStatus(plyId, primary, secondary)

    return true, value, primary, secondary
end

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
            Cache.existingStatuses[primary].onReset(plyId, statusName)
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
                Cache.existingStatuses[primary].onSoftReset(plyId, statusName)
            else
                Cache.existingStatuses[primary].onReset(plyId, statusName)
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