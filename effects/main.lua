-- Registering base effects
for statusType, statusSettings in pairs(Config.Status) do
    for subName, subSettings in pairs(statusSettings) do
        local fullName = statusType .. "." .. subName

        EffectFunctions[fullName] = {
            onStart = function(val)
                print(fullName, "onStart", val)
                if (subSettings.effect.screenEffect) then
                    -- QueueScreenEffect(fullName)
                    AddToQueue("screenEffect", fullName)
                end

                if (subSettings.effect.movementSpeed) then
                    AddToQueue("movementSpeed", fullName)
                end
            end,
            onTick = function(val)
                -- print(fullName, "onTick", val)
            end,
            onStop = function(val)
                print(fullName, "onStop", val)
                if (subSettings.effect.screenEffect) then
                    RemoveFromQueue("screenEffect", fullName)
                end

                if (subSettings.effect.movementSpeed) then
                    RemoveFromQueue("movementSpeed", fullName)
                end
            end
        }
    end
end