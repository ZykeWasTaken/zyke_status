-- You can run any custom effect in here
-- If you want to run one of our built-in ones, you can ignore this
-- Usually, these effects need queueing to prevent interference

EffectFunctions["addiction.nicotine"] = {
    onStart = function(val)
        print("addiction.nicotine onStart", val)
        -- QueueScreenEffect("addiction.nicotine")
        AddToQueue("screenEffect", "addiction.nicotine")
    end,
    onTick = function(val)
        print("addiction.nicotine onTick", val)
    end,
    onStop = function(val)
        print("addiction.nicotine onStop", val)
        -- RemoveScreenEffectFromQueue("addiction.nicotine")
        RemoveFromQueue("screenEffect", "addiction.nicotine")
    end
}