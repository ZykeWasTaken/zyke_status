-- Shakes the camera
--- Different intensity is to be added in the future, based on your effect status

-- Possible issues
-- If someone else is using the shaking, it may be overriden, perhaps check and make sure it is still played, possible suspects are recoil systems

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