-- Handles value queueing
-- Primarily meant to handle effects

---@alias QueueData {value: string, keys: table<string, integer>}[]

---@type table<string, QueueData>
local queues = {}

---@type table<string, function>
local onResourceStop = {}

---@param key string
---@param _onResourceStop function
function RegisterQueueKey(key, _onResourceStop)
    queues[key] = {}
    onResourceStop[key] = _onResourceStop
end

---@param key string
---@return QueueData
function GetQueue(key)
    return queues[key]
end

AddEventHandler("onResourceStop", function(resName)
    if (GetCurrentResourceName() ~= resName) then return end

    for _, fn in pairs(onResourceStop) do
        fn()
    end
end)

---@param queueKey string
---@param key string
---@param value? string | number
function AddToQueue(queueKey, key, value)
    Z.debug("Attempting to queue...", queueKey, key, value)

    if (not value) then
        if (IsStatusNameValid(key)) then
            local statusSettings = GetStatusSettings(key)
            value = statusSettings.effect[queueKey]
        else
            print("No effect provided and no valid status name")
            Z.debug("No effect value provided and no valid status name.")
        end
    end

    if (not value) then Z.debug("No value found...") return false end

    local queue = GetQueue(queueKey)
    if (not queue) then Z.debug("No queue found for queueKey") return false end

    local idx
    for i = 1, #queue do
        if (queue[i].value == value) then
            idx = i
            break
        end
    end

    -- If the index can be found, insert your key into that list of keys
    if (idx ~= nil) then
        -- Append key or add to counter
        if (queue[idx].keys[key]) then
            queue[idx].keys[key] += 1
        else
            queue[idx].keys[key] = 1
        end
    else
        -- If the index could not be found, insert
        table.insert(queue, #queue+1, {
            value = value, keys = {[key] = 1}
        })
    end
end

---@param queueKey string
---@param key string
---@param value? string @You only need to provide this if you are using the same key for two different effects under the same queueKey, otherwise it will pick the first one it finds
function RemoveFromQueue(queueKey, key, value)
    local queue = GetQueue(queueKey)
    if (not queue) then return false end

    for i = 1, #queue do
        if (value == nil or queue[i].value == value) then
            if (queue[i].keys[key]) then
                queue[i].keys[key] -= 1

                -- If the counter hit 0, check if any other keys exist, otherwise remove the effect
                if (queue[i].keys[key] == 0) then
                    queue[i].keys[key] = nil
                    if (Z.table.count(queue[i].keys) == 0) then
                        table.remove(queue, i)
                    end
                end

                return
            end
        end
    end
end

-- Gets the effect that should be played this tick
-- Prioritizes order in queue, if effects have the same key count, it will use the earliest one
-- The queue order does not matter if the effect has the most keys, it will be chosen as it is the most relevant one to use
local function getDominantValue(queueKey)
    local queue = GetQueue(queueKey)
    if (not queue) then return nil end

    local queueCount = Z.table.count(queue)
    -- if (queueCount)
end

CreateThread(function()
    while (1) do
        local sleep = 5000

        if (Z.table.doesTableHaveEntries(queues)) then
            sleep = 1000

            for queueKey, queueData in pairs(queues) do
                print(json.encode(queueData))
            end
        end

        Wait(sleep)
    end
end)

---@param queueKey string
function ClearEffectQueue(queueKey)
    queues[queueKey] = {}
end

exports("AddToQueue", AddToQueue)
exports("ClearEffectQueue", ClearEffectQueue)