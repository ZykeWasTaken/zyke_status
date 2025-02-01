local currWalkingStyle = nil

-- Ensures that the correct walking style (movement clip) is being used
---@param name string
local function ensureWalkingStyle(name)
    if (not name) then return end
    if (currWalkingStyle == name) then return end

    RequestClipSet(name)
    while (not HasClipSetLoaded(name)) do Wait(0) end

    currWalkingStyle = name
    Z.debug(("Now using movement clip (walking styling) type %s."):format(name))
    SetPedMovementClipset(PlayerPedId(), name, 1.0)
end

local function clearWalkingStyle()
    local ply = PlayerPedId()
    local isMale = IsPedMale(ply)
    local walkStyle = isMale and "move_m@multiplayer" or "move_f@multiplayer"

    SetPedMovementClipset(ply, walkStyle, 1.0)
    currWalkingStyle = nil
end

RegisterQueueKey("walkingStyle", {
    onTick = function(val)
        ensureWalkingStyle(val)
    end,
    onResourceStop = function()
        clearWalkingStyle()
    end,
    reset = function()
        clearWalkingStyle()
    end
})