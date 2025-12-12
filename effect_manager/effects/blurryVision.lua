-- Fades a blurry overlay every now and then

---@class BlurryVisionValue
---@field value boolean

local active = false

RegisterQueueKey("blurryVision", {
    ---@param val BlurryVisionValue | boolean
    ---@return BlurryVisionValue
    normalize = function(val)
        local _type = type(val)

        if (_type == "boolean") then
            return {value = val}
        elseif (_type == "table") then
            return {value = val.value}
            ---@diagnostic disable-next-line: missing-return @ table or boolean, always returns something
        end
    end,
    ---@param thresholdIdx1 integer
    ---@param thresholdIdx2 integer
    ---@return integer
    compare = function(_, _, thresholdIdx1, thresholdIdx2)
        -- Could support intensity metadata in future
        -- For now, use threshold
        if (thresholdIdx1 > thresholdIdx2) then return -1
        elseif (thresholdIdx1 < thresholdIdx2) then return 1
        else return 0 end
    end,
    onStart = function()
        active = true

        CreateThread(function()
            while (active) do
                local randFadeIn = math.random(500, 1250)
                TriggerScreenblurFadeIn(randFadeIn * 1.0)

                local randWait1 = randFadeIn + math.random(500, 1000)
                Wait(randWait1)

                local randFadeOut = math.random(500, 1250)
                TriggerScreenblurFadeOut(randFadeOut * 1.0)

                local randWait2 = randFadeOut + math.random(5000, 10000)
                Wait(randWait2)
            end
        end)
    end,
    onResourceStop = function()
        TriggerScreenblurFadeOut(0.0)
    end,
    reset = function()
        active = false
    end,
})