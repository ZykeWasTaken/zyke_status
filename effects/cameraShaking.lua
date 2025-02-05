-- Shakes the camera
--- Different intensity is to be added in the future, based on your effect status

local baseShake = 1.0

RegisterQueueKey("cameraShaking", {
    onStart = function()
        ShakeGameplayCam("DRUNK_SHAKE", baseShake)
    end,
    reset = function()
        StopGameplayCamShaking(false)
    end,
    onResourceStop = function()
        StopGameplayCamShaking(false)
    end
})