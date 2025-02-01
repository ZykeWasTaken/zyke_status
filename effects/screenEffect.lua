-- We utilize timecyclemods since it offers the best variety of screen effects

local currScreenEffect = nil

-- Ensures that the correct screen effect is being played
---@param name string
local function ensureScreenEffect(name)
    if (not name) then return end

    if (currScreenEffect ~= name or GetTimecycleModifierIndex() == -1) then
        if (currScreenEffect ~= nil) then
            ClearTimecycleModifier()
        end

        Z.debug(("Now playing timecycle (screen) effect %s."):format(name))
        SetTimecycleModifier(name)
        SetTransitionTimecycleModifier(name, 4.0)
        currScreenEffect = name
    end
end

local function clearScreenEffect()
    currScreenEffect = nil
    ClearTimecycleModifier()
    Z.debug("Clearing timcycle (screen) effect.")
end

RegisterQueueKey("screenEffect", {
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