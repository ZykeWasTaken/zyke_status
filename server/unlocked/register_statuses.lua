-- Registers it as a status type, which will allow a status object for this type to be created
---@param name StatusName
---@param multi? boolean
function RegisterStatusType(name, multi)
    Z.debug("Registering", name, multi)

    Cache.existingStatuses[name] = {
        multi = multi and true or false,
    }
end