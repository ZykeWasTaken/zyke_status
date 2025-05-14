-- Blocks the sprint key

local active = false
local sprintButton = Z.keys.get("LEFTSHIFT")

RegisterQueueKey("blockSprinting", {
    onStart = function()
        active = true

        CreateThread(function()
            while (active) do
				DisableControlAction(0, sprintButton.keyCode, true)

				Wait(1)
            end
        end)
    end,
    reset = function()
        active = false
    end,
})