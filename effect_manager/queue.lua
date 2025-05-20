-- Handles value queueing
-- Primarily meant to handle effects

---@alias QueueKey
---| "blockJumping"
---| "blockSprinting"
---| "blurryVision"
---| "cameraShaking"
---| "movementSpeed"
---| "screenEffect"
---| "strength"
---| "walkingStyle"

---@alias QueueData {value: string, keys: table<string, integer>}

---@type table<QueueKey, QueueData[]>
local queues = {}

-- Array of the keys in queues
---@type QueueKey[]
local queueKeys = {}

-- Cache the previously ran effects, so we know when to run the reset function
---@type table<QueueKey, string | number | integer> @Caches the effect value, to check start/reset
local prevEffects = {}

-- onResourceStop runs when the resource stops
-- onTick runs every script tick, which is set at 1000ms
-- reset runs when the queue key is not running at all, to reset all effects around it, it does not get ran when the effect value changes
-- onStart runs when an effect has been started
-- onStop runs when a specific effect value has stopped, for example, switching between two different screenEffects, it will be ran once for the effect that was stopped, not that this will also run when reset runs, if the effect is ran

---@class EffectFunctions
---@field onResourceStop fun()?
---@field onTick fun(value: string | number | integer)?
---@field reset fun()?
---@field onStart fun(value: string | number | integer)?
---@field onStop fun(value: string | number | integer)?

---@type table<QueueKey, EffectFunctions>
local funcs = {}

---@param key QueueKey
---@param functions EffectFunctions
function RegisterQueueKey(key, functions)
    if (not Z.table.contains(queueKeys, key)) then
        queueKeys[#queueKeys+1] = key
    end

    funcs[key] = {
        onResourceStop = functions.onResourceStop,
        onTick = functions.onTick,
        reset = functions.reset,
        onStart = functions.onStart
    }
end

AddEventHandler("onResourceStop", function(resName)
    if (GetCurrentResourceName() ~= resName) then return end

    for  _, func in pairs(funcs) do
        if (func.onResourceStop) then func.onResourceStop() end
    end
end)

---@param queueKey QueueKey
---@param key string
---@param thresholdIdx? integer @Required if there is no value
---@param value? integer | number | string | boolean
function AddToQueue(queueKey, key, thresholdIdx, value)
    Z.debug("Attempting to queue...", queueKey, key, value)

    if (not value) then
        -- If we don't provide a value, that means we are using a static effect registered
        if (thresholdIdx) then
            local primary, secondary = SeparateStatusName(key)
            local statusSettings = GetStatusSettings({primary, secondary})
            if (not statusSettings) then return end

            value = statusSettings.effect[thresholdIdx][queueKey]
        else
            Z.debug("No effect value provided and no valid status name.")
            return false
        end
    end

    if (not value) then Z.debug("No value found...") return false end

    local queue = queues[queueKey]
    if (not queue) then
        queue = {}
        queues[queueKey] = queue
    end

    local idx
    for i = 1, #queue do
        if (queue[i].value == value) then
            idx = i
            break
        end
    end

    -- If the index can be found, insert your key into that list of keys
    if (idx ~= nil) then
        -- Append key or add to counter
        if (queue[idx].keys[key]) then
            queue[idx].keys[key] += 1
        else
            queue[idx].keys[key] = 1
        end
    else
        -- If the index could not be found, insert
        table.insert(queue, #queue+1, {
            value = value, keys = {[key] = 1}
        })
    end

    TriggerEvent("zyke_status:OnQueueUpdated")
end

local function shouldQueueRemainActive()
    return Z.table.doesTableHaveEntries(queues) == true or Z.table.doesTableHaveEntries(prevEffects) == true
end

-- Checks if the key exists in the queueKey data
---@param queueKey QueueKey
---@param key string
function DoseKeyExistsInQueueKey(queueKey, key)
    if (not queues[queueKey]) then return false end

    for i = 1, #queues[queueKey] do
        if (queues[queueKey][i].keys[key]) then
            return true
        end
    end

    return false
end

---@param queueKey QueueKey
---@param key string
---@param value? string @You only need to provide this if you are using the same key for two different effects under the same queueKey, otherwise it will pick the first one it finds
function RemoveFromQueue(queueKey, key, value)
    local queue = queues[queueKey]
    if (not queue) then return false end

    for i = 1, #queue do
        if (value == nil or queue[i].value == value) then
            if (queue[i].keys[key]) then
                queue[i].keys[key] -= 1

                -- If the counter hit 0, check if any other keys exist, otherwise remove the effect
                if (queue[i].keys[key] == 0) then
                    queue[i].keys[key] = nil
                    if (Z.table.count(queue[i].keys) == 0) then
                        table.remove(queue, i)
                    end
                end

                if (#queue == 0) then
                    queues[queueKey] = nil
                end

                return
            end
        end
    end
end

---@param toRemove {[1]: string, [2]: string}[]
function RemoveFromQueueBulk(toRemove)
    for i = 1, #toRemove do
        RemoveFromQueue(toRemove[i][1], toRemove[i][2])
    end
end

exports("RemoveFromQueueBulk", RemoveFromQueueBulk)

-- Key, index pairs for effect hierarchies, for performance
-- We want to maintain an array where each effect has it's queue position in the config to avoid confusion
-- We process it here on start to get a quicker solution when we are managing effects
---@type table<string, table<string, integer>>
local effectHierarchy = {}
for category, values in pairs(Config.EffectHierarchy) do
    effectHierarchy[category] = {}

    for i = 1, #values do
        effectHierarchy[category][values[i]] = i
    end
end

-- Grabs the index, or returns the length + 1 for an effect in the hierarchy
---@param category string
---@param value string
local function getHierarchyIndex(category, value)
    if (not effectHierarchy[category]) then return 1 end

    return effectHierarchy[category][value] or #Config.EffectHierarchy[category]
end

-- Gets the effect that should be played this tick
-- Prioritizes order in queue, if effects have the same key count, it will use the earliest one
-- The queue order does not matter if the effect has the most keys, it will be chosen as it is the most relevant one to use
---@param queueKey QueueKey
---@return integer | nil @key
local function getDominantValue(queueKey)
    local queue = queues[queueKey]
    if (not queue) then return nil end

    local queueCount = #queue
    if (queueCount == 0) then return nil end
    if (queueCount == 1) then return 1 end

    -- If value is a number, find the highest value and use that
    if (type(queue[1].value) == "number") then
        local highestVal = 1 -- idx
        for i = 2, #queue do
            if (queue[i].value > queue[highestVal].value) then
                highestVal = i
            end
        end

        return highestVal
    end

    local queueIdx, effectIdx = 1, getHierarchyIndex(queueKey, queue[1].value)
    for i = 2, #queue do
        local newIdx = getHierarchyIndex(queueKey, queue[i].value)

        if (newIdx < effectIdx) then
            queueIdx = i
            effectIdx = newIdx
        end
    end

    return queueIdx
end

-- We use events to catch queue updated and then run a thread
-- This is to eliminate background threads when nothing is happening, and instantly executing the effecst once they are queued
-- This thread runs the queued effects

local queueActive = false -- Cheap flag instead of checking table population
RegisterNetEvent("zyke_status:OnQueueUpdated", function()
    if (queueActive) then return end

    local newEffects = {}

    queueActive = true
    while (queueActive) do
        local sleep = 1000

        ---@type table<QueueKey, string | number | integer> 
        newEffects = {}

        for queueKey, queueData in pairs(queues) do
            if (#queueData == 0) then goto continue end

            local val = getDominantValue(queueKey)

            if (val) then
                if (prevEffects[queueKey] ~= queues[queueKey][val].value) then
                    if (funcs[queueKey].onStart) then
                        funcs[queueKey].onStart(queueData[val].value)
                    end
                end

                if (funcs[queueKey].onTick) then
                    funcs[queueKey].onTick(queueData[val].value)
                end

                newEffects[queueKey] = queues[queueKey][val].value
            end

            ::continue::
        end

        for queueKey in pairs(prevEffects) do
            if (not newEffects[queueKey]) then
                if (funcs[queueKey].reset) then funcs[queueKey].reset() end
            end

            if (prevEffects[queueKey] ~= newEffects[queueKey]) then
                if (funcs[queueKey].onStop) then
                    funcs[queueKey].onStop(prevEffects[queueKey])
                end
            end
        end

        prevEffects = newEffects

        if (not shouldQueueRemainActive()) then
            queueActive = false
        end

        Wait(sleep)
    end
end)

---@param queueKey string
function ClearEffectQueueKey(queueKey)
    queues[queueKey] = nil
end

-- Completely clears the queue effect, which will then also run the reset for all effects
-- If you wish to clear all of it really quickly, such as when switching characters
function ClearEffectQueue()
    for key in pairs(queues) do
        queues[key] = nil
    end

    for queueKey in pairs(prevEffects) do
        if (funcs[queueKey].reset) then funcs[queueKey].reset() end
    end

    -- Reset the cached effects, to avoid timing issues
    prevEffects = {}
end

---@return string[]
function GetExistingQueueKeys()
    return queueKeys
end

exports("GetExistingQueueKeys", GetExistingQueueKeys)
exports("AddToQueue", AddToQueue)
exports("ClearEffectQueueKey", ClearEffectQueueKey)
exports("RemoveFromQueue", RemoveFromQueue)