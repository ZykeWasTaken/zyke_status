-- We utilize timecyclemods since it offers the best variety of screen effects

---@type {key: string, screenEffect: string}[]
ScreenEffectQueue = {}

-- Queue a screen effect to take place
---@param key string | StatusName @If status name, you can fetch the base screen effect if one is not provided
---@param screenEffect? string @Provide one, or one will be fetched based on the key provided
---@param index? integer @If you wish to push the screen effect to a specific place in the queue, for example prioritize it over all other
function QueueScreenEffect(key, screenEffect, index)
    if (not screenEffect) then
        if (IsStatusNameValid(key)) then
            local statusSettings = GetStatusSettings(key)
            screenEffect = statusSettings.effect.screenEffect
        else
            print("No screen effect provided and no valid status name")
        end
    end

    if (not screenEffect) then return false end

    table.insert(ScreenEffectQueue, index or #ScreenEffectQueue+1, {
        key = key, screenEffect = screenEffect
    })
end

exports("QueueScreenEffect", QueueScreenEffect)

-- Removes a specific key from the queue
function RemoveScreenEffectFromQueue(key)
    for i = 1, #ScreenEffectQueue do
        if (ScreenEffectQueue[i].key == key) then
            table.remove(ScreenEffectQueue, i)
        end
    end
end

-- Completely clears the queue
function ClearScreenEffectQueue()
    ScreenEffectQueue = {}
end

exports("ClearScreenEffectQueue", ClearScreenEffectQueue)

exports("RemoveScreenEffectFromQueue", RemoveScreenEffectFromQueue)

CreateThread(function()
    while (1) do
        -- print("Waiting for screen effect...")
        if (#ScreenEffectQueue > 0) then
            print("Playing screenEffect", ScreenEffectQueue[1])
        end

        Wait(1000)
    end
end)