---@param plyId PlayerId
local function isAllowed(plyId)
    return Z.hasPermission(plyId, "command")
end

Z.registerCommand({"status", "stat"}, function(plyId, args)
    local name, action, amount = args[1], args[2], tostring(args[3])

    if (action == "add") then
        AddToStatus(plyId, name, amount)
    elseif (action == "remove") then
        RemoveFromStatus(plyId, name, amount)
    else
        print("Incorrect action input")
    end

    print(name, action, amount)
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