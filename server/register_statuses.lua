-- Registers it as a status type, which will allow a status object for this type to be created
---@param name StatusName
---@param multi? boolean
---@param baseValues table @Values the state will be required to have
---@param tickFn? function
---@param onAdd function
---@param onRemove function
function RegisterStatusType(name, multi, baseValues, tickFn, onAdd, onRemove)
    Z.debug("Registering", name, multi)

    Cache.existingStatuses[name] = {
        multi = multi and true or false,
        baseValues = baseValues,
        tickFn = tickFn,
        onAdd = onAdd,
        onRemove = onRemove
    }
end