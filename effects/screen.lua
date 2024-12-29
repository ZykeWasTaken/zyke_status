-- We utilize timecyclemods since it offers the best variety of screen effects

local currScreenEffect = nil

-- Ensures that the correct screen effect is being played
---@param name string
local function ensureScreenEffect(name)
    if (not name) then return end

    if (currScreenEffect ~= name) then
        if (currScreenEffect ~= nil) then
            ClearTimecycleModifier()
        end

        Z.debug(("Now playing timecycle (screen) effect %s."):format(name))
        SetTimecycleModifier(name)
        SetTransitionTimecycleModifier(name, 4.0)
        currScreenEffect = name
    end
end

RegisterQueueKey("screenEffect", function(val)
    -- print("screenEffect", val)
    ensureScreenEffect(val)
end, function()
    if (currScreenEffect ~= nil) then
        currScreenEffect = nil
        ClearTimecycleModifier()
    end
end, function()
    print("Resetting screenEffect")
    if (currScreenEffect ~= nil) then
        currScreenEffect = nil
        ClearTimecycleModifier()
    end
end)