-- Registers it as a status type, which will allow a status object for this type to be created
---@param name StatusName
---@param multi? boolean
---@param baseValues table @Values the state will be required to have
---@param functions {onTick: function?, onAdd: function, onRemove: function, onSet?: function, onReset: function, onSoftReset?: function}
function RegisterStatusType(name, multi, baseValues, functions)
    Z.debug("Registering: " .. name .. ", multi: " .. tostring(multi))

    local subStatuses = {}
    for subName in pairs(Config.Status[name]) do
        subStatuses[subName] = true
    end

    Cache.existingStatuses[name] = {
        multi = multi and true or false,
        baseValues = baseValues,
        onTick = functions.onTick,
        onAdd = functions.onAdd,
        onRemove = functions.onRemove,
        onSet = functions.onSet,
        onReset = functions.onReset,
        onSoftReset = functions.onSoftReset,
        subStatuses = subStatuses
    }

    PopulateStatusTimeout(name)
end

local existingStatuses = Cache.existingStatuses

-- Ensuring all of the substatuses, so that we can track them
-- Executed on fn EnsurePlayerSubStatus, which means it is ensured when a status is being ensured
---@param primary PrimaryName
---@param secondary SecondaryName
function EnsureSubStatus(primary, secondary)
    local _existing = existingStatuses[primary]
    if (_existing == nil) then return end

    local subStatuses = _existing.subStatuses
    if (subStatuses[secondary]) then return end

    subStatuses[secondary] = true
    PopulateStatusTimeout(primary)
end

-- Ensures all of the sub statuses for a player
-- Because of our dynamic approach, your character might have statuses no one else has, and not has not yet cached them
-- So on character load, we cache these existing statuses
---@param plyId PlayerId
function EnsurePlayerSubStatusesCache(plyId)
    local plyStatuses = Cache.statuses[plyId]
    for primary, subStatuses in pairs(plyStatuses) do
        for secondary in pairs(subStatuses.values) do
            EnsureSubStatus(primary, secondary)
        end
    end
end