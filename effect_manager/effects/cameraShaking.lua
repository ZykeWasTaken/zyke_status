-- Shakes the camera
--- Different intensity is to be added in the future, based on your effect status

-- Possible issues
-- If someone else is using the shaking, it may be overriden, perhaps check and make sure it is still played, possible suspects are recoil systems

---@class CameraShakingValue
---@field value string
---@field intensity number

local currShakeType = nil
local currShakeIntensity = nil

RegisterQueueKey("cameraShaking", {
    ---@param val CameraShakingValue | string
    ---@return CameraShakingValue
    normalize = function(val)
        return {
            value = val.value or "DRUNK_SHAKE",
            intensity = val.intensity or 1.0
        }
    end,
    ---@param val1 CameraShakingValue
    ---@param val2 CameraShakingValue
    ---@param thresholdIdx1 integer
    ---@param thresholdIdx2 integer
    ---@return integer
    compare = function(val1, val2, thresholdIdx1, thresholdIdx2)
        -- If same shake type, compare intensity
        if (val1.value == val2.value) then
            if (val1.intensity > val2.intensity) then return -1
            elseif (val1.intensity < val2.intensity) then return 1
            else return 0 end
        end

        -- Different shake types - use threshold
        if (thresholdIdx1 > thresholdIdx2) then return -1
        elseif (thresholdIdx1 < thresholdIdx2) then return 1
        else return 0 end
    end,
    ---@param val CameraShakingValue
    onStart = function(val)
        currShakeType = val.value
        currShakeIntensity = val.intensity

        ShakeGameplayCam(currShakeType, currShakeIntensity)
    end,
    ---@param val CameraShakingValue
    onTick = function(val)
        -- Re-apply if intensity changed
        if (currShakeType ~= val.value or currShakeIntensity ~= val.intensity) then
            ShakeGameplayCam(val.value, val.intensity)
            currShakeType = val.value
            currShakeIntensity = val.intensity
        end
    end,
    reset = function()
        StopGameplayCamShaking(false)
        currShakeType = nil
        currShakeIntensity = nil
    end,
    onResourceStop = function()
        StopGameplayCamShaking(false)
        currShakeType = nil
        currShakeIntensity = nil
    end
})