---@type ClientCache
Cache = {
    statuses = nil
}

-- List of functions for effects
-- Indexed by primary.secondary
EffectFunctions = {}

Cache.statuses = Z.callback.await("zyke_status:GetPlayerStatus")

AddEventHandler("zyke_lib:OnCharacterSelect", function()
    Cache.statuses = Z.callback.await("zyke_status:GetPlayerStatus")
end)

-- Dev
CreateThread(function()
    while (1) do
        local sleep = Cache.statuses and 1 or 3000

        if (Cache.statuses) then
            local offset = 0.0
            for baseStatus, statusData in pairs(Cache.statuses) do
                for status, subData in pairs(statusData.values) do
                    for valueKey, value in pairs(subData) do
                        local base = baseStatus ~= status and (baseStatus .. "." .. status) or (status)

                        Z.drawText(base .. "." .. valueKey .. ": " .. value, 0.5, 0.01 + offset)
                        offset += 0.025
                    end
                end
            end
        end

        Wait(sleep)
    end
end)

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

-- Tick to handle effects
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
        end

        Wait(sleep)
    end
end)

RegisterCommand("pluhh", function()
    print("?")
    TriggerEvent('esx_status:getStatus', 'thirst', function(status)

        print(json.encode(status, {indent = true}))
        -- if status then
        --     data.drunk = ESX.Math.Round(status.percent)
        -- end
    end)

    -- TriggerEvent('esx_status:getStatus', target, 'drunk', function(status)

    --     print(json.encode(status))
    --     -- if status then
    --     --     data.drunk = ESX.Math.Round(status.percent)
    --     -- end
    -- end)
end, false)