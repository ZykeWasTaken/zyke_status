-- TODO: Redo the registering, to avoid registering multiple effects that is the same base effects

---@param name StatusName
function RegisterEffectFunctions(name)
    local statusSettings = GetStatusSettings(name)

    EffectFunctions[name] = {
        onStart = function(val)
            print(name, "onStart", val)
            if (statusSettings.effect.screenEffect) then
                AddToQueue("screenEffect", name)
            end

            if (statusSettings.effect.movementSpeed) then
                AddToQueue("movementSpeed", name)
            end
        end,
        onTick = function(val)
            -- print(fullName, "onTick", val)
        end,
        onStop = function(val)
            print(name, "onStop", val)
            if (statusSettings.effect.screenEffect) then
                RemoveFromQueue("screenEffect", name)
            end

            if (statusSettings.effect.movementSpeed) then
                RemoveFromQueue("movementSpeed", name)
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