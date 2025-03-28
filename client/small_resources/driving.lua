-- Adding stress on driving, similar to what qb-hud does

local config = Config.Settings.smallResources.driving
if (not config.enabled) then return end

---@diagnostic disable-next-line: param-type-mismatch
AddStateBagChangeHandler("currentVehicle", nil, function(bagName, key, value)
	if (not value) then return end

	Wait(1)

	while (LocalPlayer.state.currentVehicle) do
		local totalSpeed = 0
		local intervals = 10

		for _ = 1, intervals do
			local started = GetGameTimer()
			while (GetGameTimer() - started < 1000) do
				if (not LocalPlayer.state.currentVehicle) then return end

				Wait(50)
			end

			local speed = GetEntitySpeed(LocalPlayer.state.currentVehicle) * 3.6
			totalSpeed = totalSpeed + speed
		end

		local avgSpeed = totalSpeed / intervals
		if (avgSpeed > config.minSpeed) then
			local val = math.random(math.floor(config.gainAmount.min * 10), math.floor(config.gainAmount.max * 10)) / 10
			print("val", val)

			TriggerServerEvent('hud:server:GainStress', val)
		end
	end
end)