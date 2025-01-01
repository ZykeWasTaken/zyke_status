-- Registering all the base effects that will occur on the client side
-- Note that if you add an effect to be queued in here, you will need to add the actual effect in it's own file

-- TODO: Redo the registering, to avoid registering multiple effects that is the same base effects

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
        end,
        onTick = function(val)
            if (statusSettings.effect.damage) then
                val = statusSettings.effect.damage
                SetEntityHealth(PlayerPedId(), GetEntityHealth(PlayerPedId()) - math.floor(val))
            end
        end,
        onStop = function(val)
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