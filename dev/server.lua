---@param plyId PlayerId
local function isAllowed(plyId)
    return Z.hasPermission(plyId, "command")
end

Z.registerCommand({"status", "stat"}, function(plyId, args)
    if (not isAllowed(plyId)) then Z.notify(plyId, "noPermission") return end

    local primary, secondary, action, amount = args[1], args[2], args[3], tonumber(args[4])
    if (not amount or type(amount) ~= "number" or amount <= 0.0) then Z.notify(plyId, "invalidAmount") return end

    if (action == "add" or action == "+") then
        AddToStatus(plyId, {primary, secondary}, amount)
    elseif (action == "remove" or action == "-") then
        RemoveFromStatus(plyId, {primary, secondary}, amount)
    else
        Z.notify(plyId, "incorrectAction")
    end
end, "Add/Remove from player status", {
    {"primary", "Primary status name (ex. high)"},
    {"secondary", "Secondary status name (ex. coke)"},
    {"action", "add/remove"},
    {"amount", "0-100"},
})

Z.registerCommand({"status_clear", "sclear", "status_reset", "sreset"}, function(plyId, args)
    if (not isAllowed(plyId)) then Z.notify(plyId, "noPermission") return end

    ResetStatuses(plyId)
end, "Reset Player Status", {
    {"Player Id", "Player Id, or empty to use yourself"}
})

-- QB eating testing
-- RegisterCommand("hunger_test", function(source, args)
--     -- local ply = Z.getPlayerData(source)
--     -- ply.Functions.SetMetaData("hunger", ply.PlayerData.metadata.hunger + tonumber(args[1]))

--     TriggerClientEvent("consumables:client:Eat", source, nil, tonumber(args[1]))
-- end, false)
