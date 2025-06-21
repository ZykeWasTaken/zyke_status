-- We first check if you are registering this command already to avoid overwriting it
-- Do note that if you register this command after it, it will overwrite us
-- We do catch all the standard events to make sure that it works with most servers

local overwrite = Config.Settings.commands.heal.overwrite
local cmdArray = Config.Settings.commands.heal.command
if (not overwrite) then
	local registeredCommands = GetRegisteredCommands()

	for i = 1, #registeredCommands do
		for j = #cmdArray, 1, -1 do
			if (registeredCommands[i].name == cmdArray[j]) then
				table.remove(cmdArray, j)
			end
		end
	end
end

if (#cmdArray > 1) then
	---@param plyId PlayerId -- Invoker
	---@param args string[]
	Z.registerCommand(cmdArray, function(plyId, args)
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
	}, {
		permission = Config.Settings.commands.heal.permission,
		errorMsg = "noPermission"
	})
end