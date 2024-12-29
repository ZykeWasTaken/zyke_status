-- You can run any custom effect in here
-- If you want to run one of our built-in ones, you can ignore this
-- Usually, these effects need queueing to prevent interference

-- Registering base effects
for subName, statusSettings in pairs(Config.Status.high) do
    local fullName = "high." .. subName

    EffectFunctions[fullName] = {
        onStart = function(val)
            print(fullName, "onStart", val)
            if (statusSettings.effect.screenEffect) then
                -- QueueScreenEffect(fullName)
                AddToQueue("screenEffect", fullName)
            end

            if (statusSettings.effect.movementSpeed) then
                AddToQueue("movementSpeed", fullName)
            end
        end,
        onTick = function(val)
            -- print(fullName, "onTick", val)
        end,
        onStop = function(val)
            print(fullName, "onStop", val)
            if (statusSettings.effect.screenEffect) then
                RemoveFromQueue("screenEffect", fullName)
            end

            if (statusSettings.effect.movementSpeed) then
                RemoveFromQueue("movementSpeed", fullName)
            end
        end
    }
end