-- We first check if you are registering this command already to avoid overwriting it
-- Do note that if you register this command after it, it will overwrite us
-- We do catch all the standard events to make sure that it works with most servers

local overwrite = Config.Settings.commands.freezeStatus.overwrite
local cmdArray = Config.Settings.commands.freezeStatus.command
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

		if (not targetId) then return end

		if (targetId == 0) then
			if (isInvokerServer) then
				print(T("noServerFreeze"))
			else
				Z.notify(plyId, "noServerFreeze")
			end

			return
		end

		-- Check if player is already frozen, toggle accordingly
		local isFrozen = IsPlayerFrozen(targetId)

		if (isFrozen) then
			UnfreezeStatus(targetId)

			if (isInvokerServer) then
				print("Player's status has been unfrozen.")
			else
				Z.notify(plyId, "playerStatusUnfrozen")
			end
		else
			FreezeStatus(targetId)

			if (isInvokerServer) then
				print("Player's status has been frozen.")
			else
				Z.notify(plyId, "playerStatusFrozen")
			end
		end
	end, "Freeze/unfreeze a target's status updates", {
		{"target", "Target id, me or empty for self"},
	}, {
		permission = Config.Settings.commands.freezeStatus.permission,
		errorMsg = "noPermission"
	})
end
