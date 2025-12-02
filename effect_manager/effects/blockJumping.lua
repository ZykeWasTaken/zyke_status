-- Blocks the jump key

---@class BlockJumpingValue
---@field value boolean

local active = false
local jumpButton = Z.keys.get("SPACE")

RegisterQueueKey("blockJumping", {
    ---@param val BlockJumpingValue | true
    ---@return BlockJumpingValue
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
				DisableControlAction(0, jumpButton.keyCode, true)

				Wait(1)
            end
        end)
    end,
    reset = function()
        active = false
    end,
})