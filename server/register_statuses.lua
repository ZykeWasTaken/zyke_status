-- Registers it as a status type, which will allow a status object for this type to be created
---@param name StatusName
---@param multi? boolean
---@param baseValues table @Values the state will be required to have
---@param functions {onTick: function?, onAdd: function, onRemove: function}
function RegisterStatusType(name, multi, baseValues, functions)
    Z.debug("Registering", name, multi)

    Cache.existingStatuses[name] = {
        multi = multi and true or false,
        baseValues = baseValues,
        onTick = functions.onTick,
        onAdd = functions.onAdd,
        onRemove = functions.onRemove
    }
end