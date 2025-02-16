-- ESX.RegisterCommand('heal', 'admin', function(xPlayer, args, showError)
--     args.playerId.triggerEvent('esx_basicneeds:healPlayer')
--     args.playerId.showNotification('You have been healed.')
--     end, true, {help = 'Heal a player, or yourself - restores thirst, hunger and health.', validate = true, arguments = {
--     {name = 'playerId', help = 'the player id', type = 'player'}
--     }})

Z.registerCommand({"heal"}, function(plyId, args)
    local targetId
    if (args[1] == nil or #args[1] == 0) then
        targetId = plyId
    elseif (args[1] == "me" or args[1] == "self") then
        targetId = plyId
    else
        targetId = tonumber(args[1])
    end

    if (not targetId) then
        Z.notify(plyId, "invalidTargetId")
        return
    end

    HealPlayer(plyId)
end, "Heal a target, and restore their statuses", {
    {"target", "Target id, me or empty for self"},
})