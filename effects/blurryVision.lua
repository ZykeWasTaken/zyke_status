-- Fades a blurry overlay every now and then

local active = false

RegisterQueueKey("blurryVision", {
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