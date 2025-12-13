-- Registering all the base effects that will occur on the client side
-- Note that if you add an effect to be queued in here, you will need to add the actual effect in it's own file

-- TODO: Redo the registering, to avoid registering multiple effects that is the same base effects

-- Cache the previous threshold indexes so that we know what to queue and remove to prevent unpredictible behaviour
---@type table<StatusName, integer>
local prevThresholdIdxs = {}

-- We register and cache the effects, this way we can override and run custom functionality for specific drugs easily
---@param name StatusName
function RegisterEffectFunctions(name)
    local primary, secondary = SeparateStatusName(name)
    local statusSettings = GetStatusSettings(primary, secondary)
    if (not statusSettings) then return end

    local queueIdPrefix = name

    local function getQueueId(thresholdIdx)
        return queueIdPrefix .. ";" .. thresholdIdx
    end

    EffectFunctions[name] = {
        onStart = function(val, thresholdIdx, _, highestThresholdIdx, effectMultiplier)
            -- print("onStart", name, thresholdIdx, highestThresholdIdx)

            -- Loops all of the existing queue keys, so that we can run all of the effects and queue them
            -- So for the thresholdIdxs, simply send in what thresholdIdx to run, and it will add all of them to the queue
            local keys = GetExistingQueueKeys()
            for i = 1, #keys do
                if (statusSettings.effect[thresholdIdx][keys[i]]) then
                    AddToQueue(keys[i], getQueueId(thresholdIdx), thresholdIdx)
                end
            end

            -- Notifications
            -- These are not reliant on the queue system & will play once a threshold has been reached

            local notif = statusSettings.effect[thresholdIdx].notification
            if (notif) then
                -- Avoid a spam of notifications if you surpass multiple trehsholds at once
                -- This ensures only the highest threshold notification is played
                -- You can use the `force` option to force the notification to play regardless of the last threshold hit
                --- ex. You fly past 5 different threholds, only the last threshold will actually play a notification,
                --- but if you add the `force` option, it will play the last notification along with each notification that has the force option that you surpass
                if (highestThresholdIdx == thresholdIdx or notif?.force) then
                    if (notif.play == "start") then
                        -- We check to see if a translations exists, and if so, use it
                        -- We also allow direct notification messages without any translations for easy of configuration
                        local translation = Translations[notif.value]
                        if (not translation) then
                            Z.notify(notif.value, nil, nil, true, notif.type)
                        else
                            Z.notify(notif.value, notif.type)
                        end
                    end
                end
            end
        end,
        onTick = function(val, thresholdIdx, _, highestThresholdIdx, effectMultiplier)
            -- print("onTick", name, thresholdIdx, highestThresholdIdx)

            if (statusSettings.effect[thresholdIdx].damage) then
                local amount = statusSettings.effect[thresholdIdx].damage * effectMultiplier
                AddToStat("health", -amount)
            end
        end,
        onStop = function(_, thresholdIdx, effectMultiplier)
            local keys = GetExistingQueueKeys()

            for i = 1, #keys do
                local value = statusSettings.effect[thresholdIdx][keys[i]]

                if (value) then
                    RemoveFromQueue(keys[i], getQueueId(thresholdIdx), value)
                end
            end
        end
    }
end

-- Registering base effects
for statusType, statusSettings in pairs(Config.Status) do
    for subName in pairs(statusSettings) do
        RegisterEffectFunctions(statusType .. "." .. subName)
    end
end

---@param name StatusName
---@param fn function
function RegisterStatusEffect(name, fn)
    local _, _, full = SeparateStatusName(name)

    EffectFunctions[full] = fn
end

---@param name StatusName
---@param fnType "onStart" | "onTick" | "onStop"
---@param val number
---@param thresholdIdx integer
---@param highestThresholdIdx integer
---@param effectMultiplier number
function ExecuteStatusEffect(name, fnType, val, thresholdIdx, highestThresholdIdx, effectMultiplier)
    local _, _, full = SeparateStatusName(name)

    -- Temp to ensure the effects exist
    if (not EffectFunctions[full] or not EffectFunctions[full][fnType]) then
        RegisterEffectFunctions(name)
    end

    EffectFunctions[full][fnType](val, thresholdIdx, prevThresholdIdxs[full], highestThresholdIdx, effectMultiplier)
    prevThresholdIdxs[full] = thresholdIdx
end

-- Tick to handle effects, typically either queues or removes queues, or runs the onTick effect
-- The queued effects are then managed by the queue thread
-- Some effects are not queued, because we are not looking for a dominant value, we need to execute all of them, such as damage
--- For example, if you are poisoned and have a broken leg, you should receive damage from both of them
-- We run this in a character select to instantly run the previous session

---@type table<StatusName, {value: number, thresholdIdx: integer}>
local prevEffects = {} -- Keep track of previous effects

---@type number | nil
local lastProcessedStatuses = nil
local loopId = nil -- Current loop id that should remain active
local processingStatuses = false -- Flag to check if we're currently processing the statuses, avoids timing issues when switching between loop ids

local useDebug = Config.Settings.debug
AddEventHandler("zyke_status:OnStatusFetched", function()
    -- Catches edge cases with milliseconds of difference when iterating the loop & when we want to launch a new loop
    while (processingStatuses) do Wait(1) Z.debug("Waiting for statuses to finish processing...") end

    loopId = Z.createUniqueId(10, nil, true)

    local threadLoopId = loopId
    local firstIteration = true
    while (true) do
        if (useDebug == true) then
            Z.debug(("In loop | loopId: %s | threadLoopId: %s"):format(loopId, threadLoopId))
        end

        local sleep = firstIteration and 0 or 1000
        firstIteration = false
        Wait(sleep)

        if (loopId ~= threadLoopId) then break end

        processingStatuses = true

        if (not lastProcessedStatuses) then
            lastProcessedStatuses = GetGameTimer() - sleep
        end

        local effectMultiplier = (GetGameTimer() - lastProcessedStatuses) / 1000

        if (useDebug == true) then
            Z.debug(("Effect multiplier: %s"):format(effectMultiplier))
        end

        if (Cache.statuses) then
            ---@type table<StatusName, {value: number, thresholdIdx: integer}>
            local availableEffects = {}

            -- Loop and check our value to the config required value to perform an effect
            for statusType, statusTypeData in pairs(Cache.statuses) do
                for statusName, statusData in pairs(statusTypeData.values) do
                    local thresholdIdx = GetEffectThreshold(statusType .. "." .. statusName, statusData)

                    if (thresholdIdx ~= -1) then
                        availableEffects[statusType .. "." .. statusName] = {
                            value = statusData.value,
                            thresholdIdx = thresholdIdx
                        }
                    end
                end
            end

            -- Trigger onStop

            -- We have to check if the effect is not available, or if the thresholdIdx has been changed, which means that the effects we would be executing would be incorrect
            for statusName, values in pairs(prevEffects) do
                -- If the effect is not registered at all, run onStop for all of the existing thresholds that were previously ran
                if (availableEffects[statusName] == nil) then
                    for i = values.thresholdIdx, 1, -1 do
                        ExecuteStatusEffect(statusName, "onStop", values.value, i, values.thresholdIdx, effectMultiplier)
                    end

                    prevThresholdIdxs[statusName] = nil
                elseif (availableEffects[statusName].thresholdIdx < values.thresholdIdx) then
                    -- If the threshold is less than previously, run the onStop for all of the thresholds that stopped running
                    for i = values.thresholdIdx, availableEffects[statusName].thresholdIdx + 1, -1 do
                        ExecuteStatusEffect(statusName, "onStop", values.value, i, values.thresholdIdx, effectMultiplier)
                    end
                end
            end

            -- Trigger onStart / onTick

            -- Trigger on start, note that we skip onTick if we hit onStart
            for statusName, values in pairs(availableEffects) do
                -- Offsetting either starts from the cached value + 1, or from 1 if there is nothing cached
                -- This concise approach allows us to have one loop for running onStart from nothing, and from a specific offset already
                -- Note that we have to add 1 to the previous threshold, to avoid triggering onStart for the current max

                for i = (prevEffects[statusName]?.thresholdIdx or 0) + 1, values.thresholdIdx do
                    ExecuteStatusEffect(statusName, "onStart", values.value, i, values.thresholdIdx, effectMultiplier)
                end

                -- We loop from the start, up to the end, to run onTick for those effects
                -- However, we have to skip the effects that were recently ran onStart for, so we have to set the max as the previous thresholdIdx, or 0
                -- This means that if there was no previous threshold set, it won't run an onTick for them, and ensures we are not triggering an onTick instantly after an onStart
                for i = 1, (prevEffects[statusName]?.thresholdIdx or 0) do
                    ExecuteStatusEffect(statusName, "onTick", values.value, i, values.thresholdIdx, effectMultiplier)
                end
            end

            prevEffects = availableEffects
        end

        processingStatuses = false

        if (loopId == threadLoopId) then
            lastProcessedStatuses = GetGameTimer()
        end
    end

    if (loopId == nil) then
        lastProcessedStatuses = nil
    end
end)

AddEventHandler("zyke_lib:OnCharacterLogout", function()
    loopId = nil
end)

AddEventHandler("zyke_status:OnPlayerStatusFrozen", function()
    loopId = nil
end)