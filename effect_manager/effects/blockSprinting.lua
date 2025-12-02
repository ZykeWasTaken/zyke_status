-- Blocks the sprint key

---@class BlockSprintingValue
---@field value boolean

local active = false
local sprintButton = Z.keys.get("LEFTSHIFT")

RegisterQueueKey("blockSprinting", {
    ---@param val BlockSprintingValue | true
    ---@return BlockSprintingValue
    normalize = function(val)
        return {
            value = val.value or true
        }
    end,
    compare = function()
        return 0
    end,
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