local config = Config.Settings.smallResources.shooting
if (not config.enabled) then return end

local function processBatch(shots)
	-- You can do calculations in here, such as checking for job like police and reducing the gain
	-- We process these every 2000ms in batches, so you can do fairly pricey calculations here

	-- Job checking example, removing 75% of the stress gain for police
	local ply = Z.getJob()
	if (ply.name == "police") then
		shots = shots * 0.25
	end

	local rand = math.random(math.floor(config.gainAmount.min * 10), math.floor(config.gainAmount.max * 10)) / 10
	TriggerServerEvent("hud:server:GainStress", shots * rand)
end

-- Probably don't change these unless you know what you're doing
local timers = {
	processBatch = 2000,
	processShot = 400,
}

CreateThread(function()
	local checkRequirements = GetGameTimer()
	local lastProcessedBatch = GetGameTimer()
	local lastShot = GetGameTimer()

	local hasWeapon = false
	local ped = PlayerPedId()

	-- Cache shots to process batches
	local shots = 0

	while (1) do
		local sleep = 500

		if (GetGameTimer() - checkRequirements > 500) then
			hasWeapon = GetCurrentPedWeapon(ped, false)
			ped = PlayerPedId()
			checkRequirements = GetGameTimer()
		end

		if (hasWeapon) then
			sleep = 1

			local hasShot = IsPedShooting(ped)
			if (hasShot and GetGameTimer() - lastShot > timers.processShot) then
				-- If we just processed a shot, we can wait longer until we perform the next checks
				sleep = timers.processShot

				shots = shots + 1
				lastShot = GetGameTimer()
			end
		end

		if (shots > 0) then
			if (GetGameTimer() - lastProcessedBatch > timers.processBatch) then
				processBatch(shots)
				lastProcessedBatch = GetGameTimer()
				shots = 0
			end
		end

		Wait(sleep)
	end
end)