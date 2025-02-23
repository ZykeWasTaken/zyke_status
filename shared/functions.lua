-- Separate the name if it has multi
--[[
    By grabbing a single, you can simply do GetStatus("stress")
    If you wish to grab a multi, such as addiction, you have to do GetStatus("addiction.weed")
]]

---@param name StatusName
---@return string, string, string
function SeparateStatusName(name)
    local primary, secondary = name:match("([^%.]+)%.([^%.]+)")
    if (not primary) then return name, name, name .. "." .. name end -- If no primary can be found, there is no dot separator

    return primary, secondary, primary .. "." .. secondary
end

---@param primary PrimaryName
---@param secondary SecondaryName
function GetStatusSettings(primary, secondary)
    return Config.Status[primary][secondary] or Config.Status[secondary].base
end

-- These statuses have reversed values, 100.0 being the starting point
local reversed = Z.table.new({"addiction", "hunger", "thirst"})

-- Checks the threshold and if you should run the effect
-- Some effects may be reversed, so we define it in here
---@param name StatusName
---@param statusData PlayerStatus | AddictionStatus
---@return integer | -1 @Index of effect, -1 if none
function GetEffectThreshold(name, statusData)
    local primary, secondary = SeparateStatusName(name)
    local settings = GetStatusSettings(primary, secondary)

    if (not settings.effect) then return -1 end

    for i = #settings.effect, 1, -1 do
        if (reversed:contains(primary)) then
            if (statusData.value <= settings.effect[i].threshold) then
                return i
            end
        else
            if (statusData.value >= settings.effect[i].threshold) then
                return i
            end
        end
    end

    return -1
end

-- Verifies if the primary exists, because of our dynamic system you can have any substatus, if it is a multi-status
---@param name StatusName
---@return boolean
function IsStatusNameValid(name)
    local prim, sec = SeparateStatusName(name)

    -- TODO: Verify if it is multi-status and if it can be dynamic
    -- If it is not multi, it has to be an exact name match
    -- if it is multi, it just has to match the primary

    return Config.Status[prim] ~= nil
end

-- Goes through all status effects and re-orders them if needed
-- Re-orders based on the threshold value
-- This is to make future development easier and mor performant
function EnsureEffectThresholdOrder()
    for key, subValues in pairs(Config.Status) do
        for subName, values in pairs(subValues) do
            table.sort(values.effect, function(a, b)
                return a.threshold > b.threshold
            end)

            for i = 2, #values.effect do
                if (values.effect[i].threshold == values.effect[i - 1].threshold) then
                    print(("^1[WARNING] ^3You have multiple threshold effects registered at the same threshold. Please adjust the values to avoid issues. Status: %s.%s^7"):format(key, subName))
                end
            end
        end
    end
end

Wait(100)
EnsureEffectThresholdOrder()