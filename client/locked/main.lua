Cache = {
    statuses = {}
}

Cache.statuses = Z.callback.await("zyke_status:GetPlayerStatus")