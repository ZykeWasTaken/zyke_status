-- Handles value queueing
-- Primarily meant to handle effects

---@alias QueueData {value: string, keys: table<string, integer>}[]

---@type table<string, QueueData>
local queues = {}

---@type table<string, {onResourceStop: function, onTick: function, reset: function?}>
local funcs = {}

---@param key string
---@param functions {onResourceStop: function, onTick: function, reset: function?}
function RegisterQueueKey(key, functions)
    queues[key] = {}
    funcs[key] = {
        onResourceStop = functions.onResourceStop,
        onTick = functions.onTick,
        reset = functions.reset
    }
end

---@param key string
---@return QueueData
function GetQueue(key)
    return queues[key]
end

AddEventHandler("onResourceStop", function(resName)
    if (GetCurrentResourceName() ~= resName) then return end

    for  _, func in pairs(funcs) do
        if (func.onResourceStop) then func.onResourceStop() end
    end
end)

---@param queueKey string
---@param key string
---@param value? string | number
function AddToQueue(queueKey, key, value)
    Z.debug("Attempting to queue...", queueKey, key, value)

    if (not value) then
        if (IsStatusNameValid(key)) then
            local statusSettings = GetStatusSettings(key)
            value = statusSettings.effect[queueKey]
        else
            Z.debug("No effect value provided and no valid status name.")
        end
    end

    if (not value) then Z.debug("No value found...") return false end

    local queue = GetQueue(queueKey)
    if (not queue) then Z.debug("No queue found for queueKey") return false end

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
end

---@param queueKey string
---@param key string
---@param value? string @You only need to provide this if you are using the same key for two different effects under the same queueKey, otherwise it will pick the first one it finds
function RemoveFromQueue(queueKey, key, value)
    local queue = GetQueue(queueKey)
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

                return
            end
        end
    end
end

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

-- TODO: Cache the previous strength of the value, and don't override based on queuwe idx if it is the same
-- This is to avoid back-and-forths where it is not really needed to switch because the strengths are the same

-- Gets the effect that should be played this tick
-- Prioritizes order in queue, if effects have the same key count, it will use the earliest one
-- The queue order does not matter if the effect has the most keys, it will be chosen as it is the most relevant one to use
---@return integer | nil @key
local function getDominantValue(queueKey)
    local queue = GetQueue(queueKey)
    if (not queue) then return nil end

    -- print("Grabbing dominant values, selection:")
    -- print(json.encode(queue))

    local queueCount = Z.table.count(queue)
    if (queueCount == 0) then return nil end
    if (queueCount == 1) then return 1 end

    -- If value is a number, find the highest value and use that
    if (type(queue[1].value) == "number") then
        local highestVal = 1 -- idx
        for i = 2, #queue do
            if (queue[i].value > highestVal) then
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

-- TODO: Do some tracking to see if a value should reset or something
-- Such as all effects stop playing if there is nothing in screenEffect, and all

-- This thread runs the queued effects
CreateThread(function()
    -- Cache the previously ran effects, so we know when to run the reset function
    ---@type table<string, true>
    local prevEffects = {}
    local newEffects = {}

    while (1) do
        local sleep = 5000

        newEffects = {}

        if (Z.table.doesTableHaveEntries(queues)) then
            sleep = 1000

            for queueKey, queueData in pairs(queues) do
                local val = getDominantValue(queueKey)

                if (val) then
                    -- prevEffects[queueKey] = true
                    newEffects[queueKey] = true

                    -- print("Dominant: " .. tostring(val), json.encode(queueData))
                    if (funcs[queueKey].onTick) then
                        funcs[queueKey].onTick(queueData[val].value)
                    end
                end
            end
        end

        for queueKey in pairs(prevEffects) do
            if (not newEffects[queueKey]) then
                -- print("Should run stop for", queueKey)
                if (funcs[queueKey].reset) then funcs[queueKey].reset() end
            end
        end

        prevEffects = newEffects

        Wait(sleep)
    end
end)

---@param queueKey string
function ClearEffectQueueKey(queueKey)
    queues[queueKey] = {}
end

-- Completely clears the queue effect, which will then also run the reset for all effects
-- If you wish to clear all of it really quickly, such as when switching characters
function ClearEffectQueue()
    for key in pairs(queues) do
        queues[key] = {}
    end
end

exports("AddToQueue", AddToQueue)
exports("ClearEffectQueueKey", ClearEffectQueueKey)