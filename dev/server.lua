---@param plyId PlayerId
local function isAllowed(plyId)
    return Z.hasPermission(plyId, "command")
end

Z.registerCommand({"status", "stat"}, function(plyId, args)
    if (not isAllowed(plyId)) then Z.notify(plyId, "noPermission") return end

    local name, action, amount = args[1], args[2], tonumber(args[3])
    if (not amount or type(amount) ~= "number" or amount <= 0.0) then Z.notify(plyId, "invalidAmount") return end

    if (action == "add") then
        AddToStatus(plyId, name, amount)
    elseif (action == "remove") then
        RemoveFromStatus(plyId, name, amount)
    else
        Z.notify(plyId, "incorrectAction")
    end
end, "Add/Remove from player status", {
    {"name", "Full status name (ex. high.coke)"},
    {"action", "add/remove"},
    {"amount", "0-100"},
})

Z.registerCommand({"status_clear", "sclear", "status_reset", "sreset"}, function(plyId, args)
    -- Cache.status
end, "Reset Player Status", {
    {"Player Id", "Player Id, or empty to use yourself"}
})