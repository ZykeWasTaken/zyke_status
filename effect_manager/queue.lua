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
---| "stumble"

---@alias QueueData {value: RichEffectValue, keys: table<string, integer>}

---@alias RichEffectValue BlockJumpingValue | BlockSprintingValue | BlurryVisionValue | CameraShakingValue | MovementSpeedValue | ScreenEffectValue | StrengthValue | StumbleValue | WalkingStyleValue

---@alias EffectValueInput string | number | boolean | RichEffectValue

---@alias CompareFunction fun(val1: RichEffectValue, val2: RichEffectValue, thresholdIdx1: integer, thresholdIdx2: integer): integer
--- Returns -1 if val1 wins, 1 if val2 wins, 0 to use threshold fallback

---@alias NormalizeFunction fun(value: RichEffectValue): RichEffectValue
--- Adds default values for missing metadata fields and validates required fields

-- Total seconds of all direct effects together before can start actually triggering them
-- This is to prevent effects from only triggering for a few seconds unless we specifically want that
-- If we trigger without a set threshold it will set it to 0
-- Even if we haven't hit a threshold yet, the timer will still be ticking away in the background
-- We only accept lower values for new thresholds, since if there is an active threshold, that means an effect will be active, and we don't want to raise the bar for an existing effect
-- Once all of our effects are done, we will reset the threshold to 0
local thresholdToActivate = 0
local hasActivatedEffects = false

---@type table<QueueKey, QueueData[]>
local queues = {}

-- Array of the keys in queues
---@type QueueKey[]
local queueKeys = {}

-- Cache the previously ran effects, so we know when to run the reset function
---@type table<QueueKey, RichEffectValue> @Caches the effect value, to check start/reset
local prevEffects = {}

-- onResourceStop runs when the resource stops
-- onTick runs every script tick, which is set at 1000ms
-- reset runs when the queue key is not running at all, to reset all effects around it, it does not get ran when the effect value changes
-- onStart runs when an effect has been started (not if it changes value, just if the effect was previously not ran at all)
-- onStop runs when a specific effect value has stopped, for example, switching between two different screenEffects, it will be ran once for the effect that was stopped, not that this will also run when reset runs, if the effect is ran

---@class EffectFunctions
---@field compare CompareFunction Comparison function to determine dominant value
---@field normalize NormalizeFunction Normalization/validation function to add defaults and validate
---@field onResourceStop fun()?
---@field onTick fun(value: RichEffectValue)?
---@field reset fun()?
---@field onStart fun(value: RichEffectValue)?
---@field onStop fun(value: RichEffectValue)?

---@type table<QueueKey, EffectFunctions>
local funcs = {}

-- Deep comparison for rich effect values
-- Returns true if both represent the same effect with same metadata
---@param val1 RichEffectValue
---@param val2 RichEffectValue
---@return boolean
local function richValuesEqual(val1, val2)
    if (val1 == nil and val2 == nil) then return true end
    if (val1 == nil or val2 == nil) then return false end

    -- Compare all fields in val1
    for k, v in pairs(val1) do
        if (val2[k] ~= v) then return false end
    end

    -- Compare all fields in val2 (catch extra fields)
    for k, v in pairs(val2) do
        if (val1[k] ~= v) then return false end
    end

    return true
end

---@param key QueueKey
---@param functions EffectFunctions
function RegisterQueueKey(key, functions)
    if (not Z.table.contains(queueKeys, key)) then
        queueKeys[#queueKeys+1] = key
    end

    funcs[key] = {
        compare = functions.compare,
        normalize = functions.normalize,
        onResourceStop = functions.onResourceStop,
        onTick = functions.onTick,
        reset = functions.reset,
        onStart = functions.onStart,
        onStop = functions.onStop
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
---@param newThresholdToActivate? integer | "prev" @"prev" to keep, nil/0 to restore, integer to set, total seconds of all effects together before can start actually triggering them
function AddToQueue(queueKey, key, thresholdIdx, value, newThresholdToActivate)
    if (Config.Settings.debug == true) then
        Z.debug("Attempting to queue...", json.encode({
            queueKey = queueKey,
            key = key,
            thresholdIdx = thresholdIdx,
            value = value,
            newThresholdToActivate = newThresholdToActivate
        }, {indent = true}))
    end

    -- This threshold part is a little messy and will probably be refactored in the future, but the concept is working

    -- Keep the previous threshold
    if (newThresholdToActivate == "prev") then
        newThresholdToActivate = thresholdToActivate

        -- If the don't specify a threshold, or we set it as 0, we reset it
    elseif (newThresholdToActivate == nil or newThresholdToActivate == 0) then
        thresholdToActivate = 0

        -- If we haven't activated any effects yet, and haven't set a threshold, we set it to whatever the input is
    elseif (
        not hasActivatedEffects
        and thresholdToActivate == 0
    ) then
        ---@diagnostic disable-next-line: cast-local-type
        thresholdToActivate = newThresholdToActivate or 0

        -- If we specify a threshold, we set it if it is lower than the old
    elseif (newThresholdToActivate < thresholdToActivate) then
        ---@diagnostic disable-next-line: cast-local-type
        thresholdToActivate = newThresholdToActivate
    end

    if (not value) then
        -- If we don't provide a value, that means we are using a static effect registered
        if (thresholdIdx) then
            local primary, secondary = SeparateStatusName(key)
            local statusSettings = GetStatusSettings(primary, secondary)
            if (not statusSettings) then return end

            value = statusSettings.effect[thresholdIdx][queueKey]
        else
            Z.debug("No effect value provided and no valid status name.")
            return false
        end
    end

    if (not value) then Z.debug("No value found...") return false end

    -- Normalize
    ---@diagnostic disable-next-line: cast-local-type, param-type-mismatch
    value = funcs[queueKey].normalize(value)

    local queue = queues[queueKey]
    if (not queue) then
        queue = {}
        queues[queueKey] = queue
    end

    local idx
    for i = 1, #queue do
        if (richValuesEqual(queue[i].value, value)) then
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
---@param value? EffectValueInput @You only need to provide this if you are using the same key for two different effects under the same queueKey, otherwise it will pick the first one it finds
function RemoveFromQueue(queueKey, key, value)
    Z.debug("Attempting to remove from queue...", json.encode({
        queueKey = queueKey,
        key = key,
        value = value
    }, {indent = true}))

    local queue = queues[queueKey]
    if (not queue) then
        Z.debug("Queue does not exist for queueKey:", queueKey)
        return false
    end

    -- Convert value to rich format if provided
    if (value ~= nil) then
        -- Must normalize to match what's in the queue
        if (funcs[queueKey]) then
            ---@diagnostic disable-next-line: cast-local-type, param-type-mismatch
            value = funcs[queueKey].normalize(value)
        end
    end

    for i = 1, #queue do
        if (value == nil or richValuesEqual(queue[i].value, value)) then
            if (queue[i].keys[key]) then
                queue[i].keys[key] -= 1

                Z.debug(("Found key '%s' in queue entry %d, decremented to %d"):format(key, i, queue[i].keys[key]))

                -- If the counter hit 0, check if any other keys exist, otherwise remove the effect
                if (queue[i].keys[key] == 0) then
                    queue[i].keys[key] = nil
                    Z.debug(("Key '%s' counter hit 0, removed from entry"):format(key))

                    if (Z.table.count(queue[i].keys) == 0) then
                        Z.debug(("No more keys in entry %d, removing from queue"):format(i))
                        table.remove(queue, i)
                    end
                end

                if (#queue == 0) then
                    Z.debug(("Queue for '%s' is now empty, removing queue"):format(queueKey))
                    queues[queueKey] = nil
                end

                TriggerEvent("zyke_status:OnQueueUpdated")
                return
            end
        end
    end

    Z.debug(("Could not find key '%s' in queue for '%s'"):format(key, queueKey))
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

-- Gets the highest threshold index for a queued effect
-- Looks through all the keys (status names) contributing to this effect
---@param queueData QueueData
---@param queueKey QueueKey
---@return integer
local function getHighestThresholdForValue(queueData, queueKey)
    local highest = 0

    for statusName, count in pairs(queueData.keys) do
        local primary, secondary = SeparateStatusName(statusName)
        local statusSettings = GetStatusSettings(primary, secondary)
        if (statusSettings and statusSettings.effect) then
            -- Find which threshold has this effect
            for thresholdIdx, effects in ipairs(statusSettings.effect) do
                if (effects[queueKey]) then
                    -- Normalize for comparison
                    local configValue = funcs[queueKey].normalize(effects[queueKey])
                    if (richValuesEqual(configValue, queueData.value)) then
                        if (thresholdIdx > highest) then
                            highest = thresholdIdx
                        end
                    end
                end
            end
        end
    end

    return highest
end

-- Gets the effect that should be played this tick
-- Uses the registered compare function to determine dominance
---@param queueKey QueueKey
---@return integer | nil @index of dominant value
local function getDominantValue(queueKey)
    local queue = queues[queueKey]
    if (not queue) then return nil end

    local queueCount = #queue
    if (queueCount == 0) then return nil end
    if (queueCount == 1) then return 1 end

    -- Get the compare function for this effect type
    local compareFunc = funcs[queueKey].compare
    if (not compareFunc) then
        Z.debug(("Warning: No compare function for '%s', using first value"):format(queueKey))
        return 1
    end

    -- Track dominant index and threshold
    local dominantIdx = 1
    local dominantThreshold = getHighestThresholdForValue(queue[1], queueKey)

    for i = 2, #queue do
        local currentThreshold = getHighestThresholdForValue(queue[i], queueKey)

        -- Compare using registered function
        local result = compareFunc(
            queue[i].value,          -- val1 (current)
            queue[dominantIdx].value, -- val2 (dominant)
            currentThreshold,         -- thresholdIdx1
            dominantThreshold         -- thresholdIdx2
        )

        if (result == -1) then
            -- val1 (current) wins
            dominantIdx = i
            dominantThreshold = currentThreshold
        elseif (result == 0) then
            -- Equal - use threshold as tiebreaker
            if (currentThreshold > dominantThreshold) then
                dominantIdx = i
                dominantThreshold = currentThreshold
            end
        end
        -- result == 1 means val2 (dominant) wins, no change needed
    end

    return dominantIdx
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

        ---@type table<QueueKey, RichEffectValue>
        newEffects = {}

        -- This is to manage direct effects:
        -- If we haven't activated any effects yet, we check for a threshold
        -- If we have a threshold at 0, that means there is no active threshold, and we can skip the check if so
        -- if we have a threshold set, we check if our total duration is greater than the threshold
        -- If we run a effect via other means like a status, it will run the AddToQueue function without a threshold, which sets it to 0 and will force-start all effects
        if (
            not hasActivatedEffects
            and thresholdToActivate ~= 0
            and thresholdToActivate > Cache.directEffectsTotalDuration
        ) then goto continue end

        hasActivatedEffects = true
        for queueKey, queueData in pairs(queues) do
            if (#queueData == 0) then goto continue end

            local val = getDominantValue(queueKey)

            if (val) then
                if (
                    -- onStart should only trigger if the previous effect was nil (and we got a new value, which we already checked)
                    -- All other changes should go under onTick
                    prevEffects[queueKey] == nil
                ) then
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

            if (not richValuesEqual(prevEffects[queueKey], newEffects[queueKey])) then
                if (funcs[queueKey].onStop) then
                    funcs[queueKey].onStop(prevEffects[queueKey])
                end
            end
        end

        prevEffects = newEffects

        if (not shouldQueueRemainActive()) then
            queueActive = false
        end

        ::continue::

        Wait(sleep)
    end

    -- We reset the threshold
    thresholdToActivate = 0
    hasActivatedEffects = false
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