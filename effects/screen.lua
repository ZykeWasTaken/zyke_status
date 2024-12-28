-- TODO: Change keys from array to key-value for better performance, probably

-- We utilize timecyclemods since it offers the best variety of screen effects

-- We have a queue system in place, prioritizing the most requests and the place in the queue
-- Using this method, we can queue multiple different effects from different statuses without having weird flickering issues, and it prioritizes the most relevant one

---@type {screenEffect: string, keys: string[]}[]
ScreenEffectQueue = {
    -- {screenEffect = "effect1", keys = {"key1"}},
    -- {screenEffect = "effect2", keys = {"key1", "key2"}},
    -- {screenEffect = "effect3", keys = {"key1", "key2"}}
}

-- Queue a screen effect to take place
---@param key string | StatusName @If status name, you can fetch the base screen effect if one is not provided
---@param screenEffect? string @Provide one, or one will be fetched based on the key provided
function QueueScreenEffect(key, screenEffect)
    if (not screenEffect) then
        if (IsStatusNameValid(key)) then
            local statusSettings = GetStatusSettings(key)
            screenEffect = statusSettings.effect.screenEffect
        else
            print("No screen effect provided and no valid status name")
        end
    end

    if (not screenEffect) then return end

    local idx
    for i = 1, #ScreenEffectQueue do
        if (ScreenEffectQueue[i].screenEffect == screenEffect) then
            idx = i
            break
        end
    end

    -- If the index can be found, insert your key into that list of keys
    if (idx ~= nil) then
        -- Append key
        ScreenEffectQueue[idx].keys[#ScreenEffectQueue[idx].keys+1] = key
    else
        -- If the index could not be found, insert
        table.insert(ScreenEffectQueue, #ScreenEffectQueue+1, {
            screenEffect = screenEffect, keys = {key}
        })
    end

end

exports("QueueScreenEffect", QueueScreenEffect)

-- Removes a specific key from the queue
---@param key string
---@param screenEffect? string @You only need to provide this if you are using the same key for two different screen effects, otherwise it will pick the first one it finds
function RemoveScreenEffectFromQueue(key, screenEffect)
    for i = 1, #ScreenEffectQueue do
        if (screenEffect == nil or ScreenEffectQueue[i].screenEffect == screenEffect) then
            for j = 1, #ScreenEffectQueue[i].keys do
                if (ScreenEffectQueue[i].keys[j] == key) then

                    -- If this is the last key, remove the screen effect
                    if (#ScreenEffectQueue[i].keys == 1) then
                        table.remove(ScreenEffectQueue, i)
                    else
                        -- If this is not the last key remove that one only
                        table.remove(ScreenEffectQueue[i].keys, j)
                    end

                    return
                end
            end
        end
    end
end

-- Completely clears the queue
function ClearScreenEffectQueue()
    ScreenEffectQueue = {}
end

exports("ClearScreenEffectQueue", ClearScreenEffectQueue)

exports("RemoveScreenEffectFromQueue", RemoveScreenEffectFromQueue)

-- Gets the effect that should be played this tick
-- Prioritizes order in queue, if effects have the same key count, it will use the earliest one
-- The queue order does not matter if the effect has the most keys, it will be chosen as it is the most relevant one to use
---@return integer | nil @idx
local function getEffectToPlay()
    if (#ScreenEffectQueue == 0) then return nil end
    if (#ScreenEffectQueue == 1) then return 1 end

    local idx, keyCount = 1, #ScreenEffectQueue[1].keys
    for i = 2, #ScreenEffectQueue do
        if (#ScreenEffectQueue[i].keys > keyCount) then
            idx = i
            keyCount = #ScreenEffectQueue[i].keys
        end
    end

    return idx
end

CreateThread(function()
    while (1) do
        local effectIdx = getEffectToPlay()
        if (effectIdx) then
            local queueTbl = ScreenEffectQueue[effectIdx]
            local screenEffect = queueTbl.screenEffect

            print("Screen effect", screenEffect)
        end

        Wait(1000)
    end
end)