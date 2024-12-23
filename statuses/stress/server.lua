RegisterStatusType("stress")

-- CreateThread(function()
--     while (1) do
--         for plyId, statuses in pairs(Cache.statuses) do
--             if (statuses["stress"] and statuses["stress"].values["stress"]) then
--                 print("Handling", "stress", "for", plyId)

--                 -- AddToStatus(plyId, "stress", 0.01)
--                 RemoveFromStatus(plyId, "stress", 0.05)
--             end
--         end

--         Wait(1000)
--     end
-- end)