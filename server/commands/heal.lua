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

if (#cmdArray > 0) then
	---@param plyId PlayerId -- Invoker
	---@param args string[]
	Z.registerCommand(cmdArray, function(plyId, args)
		local isInvokerServer = plyId == 0
		local targetId, failReason = ParseCommandTarget(plyId, args)

		if (failReason) then
			if (isInvokerServer) then
				print("Failed to execute command, reason:", T(failReason))
			else
				Z.notify(plyId, failReason)
			end

			return
		end

		if (targetId == 0) then
			if (isInvokerServer) then
				print("You can not heal the server.")
			else
				Z.notify(plyId, "noServerHeal")
			end

			return
		end

		---@diagnostic disable-next-line: param-type-mismatch @Has to be a valid id at this point, can not be a number
		HealPlayer(targetId)

		if (isInvokerServer) then
			print("Player has been healed.")
		else
			Z.notify(plyId, "playerHealed")
		end
	end, "Heal a target, and restore their statuses", {
		{"target", "Target id, me or empty for self"},
	}, {
		permission = Config.Settings.commands.heal.permission,
		errorMsg = "noPermission"
	})
end