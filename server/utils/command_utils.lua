-- Utility functions for command handling

-- Parse and validate target id from command args
---@param invokerId PlayerId -- Invoker, either player id or server (0)
---@param args string[] -- Command args
---@return PlayerId | 0 | nil, FailReason?
function ParseCommandTarget(invokerId, args)
	local defaultTarget = invokerId
	local targetId = nil

	local targetArg = args[1]

	-- If we don't provide anything, or we provide aliases, target self
	if (
		not targetArg or
		#targetArg == 0 or
		targetArg == "me" or
		targetArg == "self"
	) then
		targetId = defaultTarget
	end

	targetId = math.tointeger(targetId or targetArg)
	if (targetId == nil) then
		return nil, "invalidTargetId"
	end

	local isTargetServer = targetId == 0
	if (isTargetServer) then
		return 0, nil
	end

	if (not Z.isPlayerIdValid(targetId)) then
		return targetId, "invalidTargetId"
	end

	return targetId, nil
end