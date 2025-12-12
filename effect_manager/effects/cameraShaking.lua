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
        local _type = type(val)
        local defaultShakeType = "DRUNK_SHAKE"

        if (_type == "string") then
            return {value = val or defaultShakeType, intensity = 1.0}
        elseif (_type == "table") then
            return {
                value = val.value or defaultShakeType,
                intensity = val.intensity or 1.0
            }
            ---@diagnostic disable-next-line: missing-return @ table or string, always returns something
        end
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
        if (currShakeType == val.value and currShakeIntensity ~= val.intensity) then
            SetGameplayCamShakeAmplitude(val.intensity)
        elseif (currShakeType ~= val.value) then
            ShakeGameplayCam(val.value, val.intensity)
        end

        currShakeType = val.value
        currShakeIntensity = val.intensity
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