local hudState = GetResourceKvpInt("zyke_status:dev_hud_enabled") or 0
local function devHud()
    while (hudState == 1) do
        local sleep = Cache.statuses and 1 or 3000

        if (Cache.statuses) then
            local offset = 0.0
            for baseStatus, statusData in pairs(Cache.statuses) do
                for status, subData in pairs(statusData.values) do
                    for valueKey, value in pairs(subData) do
                        local base = baseStatus ~= status and (baseStatus .. "." .. status) or (status)

                        Z.drawText(base .. "." .. valueKey .. ": " .. value, 0.5, 0.01 + offset)
                        offset += 0.025
                    end
                end
            end
        end

        Wait(sleep)
    end
end

RegisterCommand("status:dev_hud", function()
    local state = GetResourceKvpInt("zyke_status:dev_hud_enabled") or 0
    local newVal = state == 0 and 1 or 0
    SetResourceKvpInt("zyke_status:dev_hud_enabled", newVal)

    hudState = newVal
    if (not hudState) then return end

    devHud()
end, false)

devHud()