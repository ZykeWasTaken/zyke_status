-- We utilize timecyclemods since it offers the best variety of screen effects

---@class ScreenEffectValue
---@field value string
---@field intensity number

local currScreenEffect = nil
local currIntensity = nil
local transitionStartTime = nil
local TRANSITION_DURATION = 2.0 -- Duration in seconds for the transition (SetTransitionTimecycleModifier uses half-seconds, so 4.0 = 2.0s)
local fadingOut = false

-- Ensures that the correct screen effect is being played
---@param screenEffect ScreenEffectValue
local function ensureScreenEffect(screenEffect)
    local name = screenEffect.value
    local intensity = screenEffect.intensity
    local currentTime = GetGameTimer() / 1000.0

    -- Cancel fade-out if a new effect is requested
    if (fadingOut) then
        fadingOut = false
        Z.debug("Cancelling fade-out, new effect requested.")
    end

    -- Check if we're still in the transition period
    local inTransition = transitionStartTime ~= nil and (currentTime - transitionStartTime) < TRANSITION_DURATION

    -- If we're in a transition
    if (inTransition) then
        -- Allow upgrading to higher intensity of the same effect during transition
        -- This handles the case where multiple thresholds are triggered rapidly
        if (name == currScreenEffect and intensity > currIntensity) then
            Z.debug(("Upgrading timecycle (screen) effect %s from intensity %.2f to %.2f during transition."):format(name, currIntensity, intensity))
            SetTimecycleModifierStrength(intensity)
            currIntensity = intensity
        end

        -- Otherwise, block all changes during transition
        return
    end

    -- Only check GetTimecycleModifierIndex() if we're not in a transition
    -- It detects as -1 even if we're fading into a new effect
    local modifierMissing = GetTimecycleModifierIndex() == -1

    if (currScreenEffect ~= name or currIntensity ~= intensity or modifierMissing) then
        if (currScreenEffect ~= nil) then
            ClearTimecycleModifier()
        end

        Z.debug(("Now playing timecycle (screen) effect %s with intensity %.2f."):format(name, intensity))
        SetTransitionTimecycleModifier(name, TRANSITION_DURATION)
        SetTimecycleModifierStrength(intensity)
        currScreenEffect = name
        currIntensity = intensity
        transitionStartTime = currentTime
    end
end

local function clearScreenEffect()
    if (currScreenEffect ~= nil) then
        Z.debug("Clearing timcycle (screen) effect with transition.")

        local startIntensity = currIntensity
        local fadeStartTime = GetGameTimer() / 1000.0
        fadingOut = true

        -- Gradually fade out over the transition duration
        CreateThread(function()
            while fadingOut do
                local currentTime = GetGameTimer() / 1000.0
                local elapsed = currentTime - fadeStartTime

                if elapsed >= TRANSITION_DURATION then
                    -- Fade complete, clear the modifier
                    ClearTimecycleModifier()
                    fadingOut = false
                    break
                end

                -- Calculate fade progress (1.0 to 0.0)
                local progress = 1.0 - (elapsed / TRANSITION_DURATION)
                local newIntensity = startIntensity * progress
                SetTimecycleModifierStrength(newIntensity)

                Wait(50) -- Update every 50ms for smooth fade
            end
        end)
    end

    currScreenEffect = nil
    currIntensity = nil
    transitionStartTime = nil
end

RegisterQueueKey("screenEffect", {
    ---@param val ScreenEffectValue | string
    ---@return ScreenEffectValue
    normalize = function(val)
        local _type = type(val)

        if (_type == "string") then
            return {value = val, intensity = 1.0}
        elseif (_type == "table") then
            return {value = val.value, intensity = val.intensity or 1.0}
            ---@diagnostic disable-next-line: missing-return @ table or string, always returns something
        end
    end,
    ---@param val1 ScreenEffectValue
    ---@param val2 ScreenEffectValue
    ---@param thresholdIdx1 integer
    ---@param thresholdIdx2 integer
    ---@return integer
    compare = function(val1, val2, thresholdIdx1, thresholdIdx2)
        -- If same effect name, compare intensity (higher intensity wins)
        if (val1.value == val2.value) then
            if (val1.intensity > val2.intensity) then return -1
            elseif (val1.intensity < val2.intensity) then return 1
            else return 0 end
        end

        -- Different effects - use threshold (higher threshold = more severe)
        if (thresholdIdx1 > thresholdIdx2) then return -1
        elseif (thresholdIdx1 < thresholdIdx2) then return 1
        else return 0 end
    end,
    ---@param val ScreenEffectValue
    onTick = function(val)
        ensureScreenEffect(val)
    end,
    onResourceStop = function()
        clearScreenEffect()
    end,
    reset = function()
        clearScreenEffect()
    end
})