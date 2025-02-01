-- Registering all the base effects that will occur on the client side
-- Note that if you add an effect to be queued in here, you will need to add the actual effect in it's own file

-- TODO: Redo the registering, to avoid registering multiple effects that is the same base effects

-- We register and cache the effects, this way we can override and run custom functionality for specific drugs easily
---@param name StatusName
function RegisterEffectFunctions(name)
    local statusSettings = GetStatusSettings(name)

    EffectFunctions[name] = {
        onStart = function(val)
            if (statusSettings.effect.screenEffect) then
                AddToQueue("screenEffect", name)
            end

            if (statusSettings.effect.movementSpeed) then
                AddToQueue("movementSpeed", name)
            end

            if (statusSettings.effect.walkingStyle) then
                AddToQueue("walkingStyle", name)
            end
        end,
        onTick = function(val)
            if (statusSettings.effect.damage) then
                SetEntityHealth(PlayerPedId(), GetEntityHealth(PlayerPedId()) - math.floor(statusSettings.effect.damage))
            end
        end,
        onStop = function(val)
            if (statusSettings.effect.screenEffect) then
                RemoveFromQueue("screenEffect", name)
            end

            if (statusSettings.effect.movementSpeed) then
                RemoveFromQueue("movementSpeed", name)
            end

            if (statusSettings.effect.walkingStyle) then
                RemoveFromQueue("walkingStyle", name)
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
function ExecuteStatusEffect(name, fnType, val)
    local _, _, full = SeparateStatusName(name)

    -- Temp to ensure the effects exist
    if (not EffectFunctions[full] or not EffectFunctions[full][fnType]) then
        RegisterEffectFunctions(name)
    end

    EffectFunctions[full][fnType](val)

    -- if (EffectFunctions[full] and EffectFunctions[full][fnType]) then EffectFunctions[full][fnType](val) end
end

-- Tick to handle effects, typically either queues or removes queues, or runs the onTick effect
-- The queued effects are then managed by the queue thread
-- Some effects are not queued, because we are not looking for a dominant value, we need to execute all of them, such as damage
--- For example, if you are poisoned and have a broken leg, you should receive damage from both of them
CreateThread(function()
    ---@type table<StatusName, number>
    local prevEffects = {} -- Keep track of previous effects

    while (1) do
        local sleep = Cache.statuses and 1000 or 3000

        if (Cache.statuses) then
            ---@type table<StatusName, number>
            local availableEffects = {}

            -- Loop and check our value to the config required value to perform an effect
            for statusType, statusTypeData in pairs(Cache.statuses) do
                for statusName, statusData in pairs(statusTypeData.values) do
                    if (IsWithinEffectThreshold(statusType .. "." .. statusName, statusData)) then
                        availableEffects[statusType .. "." .. statusName] = statusData.value
                    end
                end
            end

            -- Trigger on start, note that we skip onTick if we hit onStart
            for statusName, val in pairs(availableEffects) do
                ExecuteStatusEffect(statusName, prevEffects[statusName] ~= nil and "onTick" or "onStart", val)
            end

            -- Trigger on stop
            for statusName, val in pairs(prevEffects) do
                if (availableEffects[statusName] == nil) then
                    ExecuteStatusEffect(statusName, "onStop", val)
                end
            end

            prevEffects = availableEffects
        else
            prevEffects = {}
        end

        Wait(sleep)
    end
end)