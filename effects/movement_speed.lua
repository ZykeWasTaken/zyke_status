RegisterQueueKey("movementSpeed", function(val)
    -- print("movementSpeed", json.encode(val))
    -- local ply = PlayerPedId()
    -- print("currSpeed", GetPedCurrentMovementSpeed(ply))

    -- SetPedMoveRateOverride(PlayerId(), 10.0)
    SetRunSprintMultiplierForPlayer(PlayerId(), val)
end,
function()
    -- if (currScreenEffect ~= nil) then
    --     ClearTimecycleModifier()
    -- end
end, function()
    print("Resetting movementSpeed")
    SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
end)