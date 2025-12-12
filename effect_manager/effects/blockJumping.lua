-- Blocks the jump key

---@class BlockJumpingValue
---@field value boolean

local active = false
local jumpButton = Z.keys.get("SPACE")

RegisterQueueKey("blockJumping", {
    ---@param val BlockJumpingValue | boolean
    ---@return BlockJumpingValue
    normalize = function(val)
        local _type = type(val)

        if (_type == "boolean") then
            return {value = val}
        elseif (_type == "table") then
            return {value = val.value}
            ---@diagnostic disable-next-line: missing-return @ table or boolean, always returns something
        end
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