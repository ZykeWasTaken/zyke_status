---@class WalkingStyleValue
---@field value string

-- A list of movement styles we won't override
-- For example, crouching counts as a movement style which we don't want to override
-- Don't forget to hash it
local ignoreOverriding = {
    [`move_ped_crouched`] = true
}

-- Ensures that the correct walking style (movement clip) is being used
---@param name string
local function ensureWalkingStyle(name)
    if (not name) then return end

    local ply = PlayerPedId()
    local currWalkingStyle = GetPedMovementClipset(ply)

    if (ignoreOverriding[currWalkingStyle]) then return end
    if (currWalkingStyle == joaat(name)) then return end

    RequestClipSet(name)
    while (not HasClipSetLoaded(name)) do Wait(0) end

    Z.debug(("Now using movement clip (walking styling) type %s."):format(name))
    SetPedMovementClipset(PlayerPedId(), name, 1.0)
end

local function clearWalkingStyle()
    local ply = PlayerPedId()
    local currWalkingStyle = GetPedMovementClipset(ply)
    if (ignoreOverriding[currWalkingStyle]) then return end

    local isMale = IsPedMale(ply)
    local walkStyle = isMale and "move_m@multiplayer" or "move_f@multiplayer"

    Z.debug("Clearing walking style.")
    SetPedMovementClipset(ply, walkStyle, 1.0)
end

RegisterQueueKey("walkingStyle", {
    ---@param val WalkingStyleValue | string
    ---@return WalkingStyleValue
    normalize = function(val)
        return {
            value = val.value
        }
    end,
    ---@param thresholdIdx1 integer
    ---@param thresholdIdx2 integer
    ---@return integer
    compare = function(_, _, thresholdIdx1, thresholdIdx2)
        -- Different walking styles, use threshold
        -- Higher threshold = more severe impairment
        if (thresholdIdx1 > thresholdIdx2) then return -1
        elseif (thresholdIdx1 < thresholdIdx2) then return 1
        else return 0 end
    end,
    ---@param val WalkingStyleValue
    onTick = function(val)
        ensureWalkingStyle(val.value)
    end,
    onResourceStop = function()
        clearWalkingStyle()
    end,
    reset = function()
        clearWalkingStyle()
    end
})