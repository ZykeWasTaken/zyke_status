-- Registers it as a status type, which will allow a status object for this type to be created
---@param name StatusName
function RegisterStatusType(name)
    Cache.existingStatuses[name] = true
end

-- Loop through all directories inside of statuses, to find the names