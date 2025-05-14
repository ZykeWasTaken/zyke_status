-- Blocks the jump key

local active = false
local jumpButton = Z.keys.get("SPACE")

RegisterQueueKey("blockJumping", {
    onStart = function()
        active = true

        CreateThread(function()
            while (active) do
				DisableControlAction(0, jumpButton.keyCode, true)

				Wait(1)
            end
        end)
    end,
    reset = function()
        active = false
    end,
})