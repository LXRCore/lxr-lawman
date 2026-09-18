--[[ ═══════════════════════════════════════════════════════════════════════════
     LXR-LAWMAN — Server: duty, cuffs, search, fines, jail, bounties
     ═══════════════════════════════════════════════════════════════════════════
     Every power is checked here: the officer is the law and on duty, the
     target is within reach, the amount is lawful. State lives in the core's
     metadata (ishandcuffed, injail) so it survives relogs; bounties in
     lxr_bounties; money moves through the core and lxr-bank.
     ═══════════════════════════════════════════════════════════════════════════
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

local LXRCore = exports['lxr-core']:GetCoreObject()
local LXR = exports['lxr-core']:GetLXR()
local L = LXRLawman
local Inventory = LXRCore.Inventory
local RES = GetCurrentResourceName()
local buckets = {}
local escorts = {}     -- target src → officer src

local function limited(src)
    local b = buckets[src]
    local now = GetGameTimer()
    if not b or now - b.at > Config.Security.rateLimit.windowMs then b = { at = now, n = 0 } buckets[src] = b end
    b.n = b.n + 1
    return b.n > Config.Security.rateLimit.burst
end
local function player(src) return LXRCore.Functions.GetPlayer(src) end
local function notify(src, key, kind, vars) LXRCore.Notify(src, Lang:t(key, vars), kind or 'info') end
local function near(a, b, dist)
    local pa, pb = GetPlayerPed(a), GetPlayerPed(b)
    if pa == 0 or pb == 0 then return false end
    return #(GetEntityCoords(pa) - GetEntityCoords(pb)) <= (dist or Config.Security.maxDistance)
end
local function nearCoords(src, coords, dist)
    local ped = GetPlayerPed(src)
    return ped ~= 0 and #(GetEntityCoords(ped) - vector3(coords.x, coords.y, coords.z)) <= (dist or Config.Security.maxDistance)
end
local function nameOf(P) local ci = P.PlayerData.charinfo return ci.firstname .. ' ' .. ci.lastname end
local function log(msg, data) if Config.Debug.log then LXRCore.Log.info('lawman', msg, data) end end

---Officer + target gate.
local function pair(src, targetId, dist)
    if limited(src) then return nil, nil, 'rate' end
    local O = player(src)
    if not O or not L.IsLaw(O.PlayerData.job) then return nil, nil, 'not_law' end
    local T = player(tonumber(targetId) or -1)
    if not T or T.PlayerData.source == src then return nil, nil, 'invalid' end
    if not near(src, T.PlayerData.source, dist) then return nil, nil, 'too_far' end
    return O, T
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- 💾 BOUNTIES
-- ═══════════════════════════════════════════════════════════════════════════════
LXRCore.DB.RegisterMigration(RES, '0001_bounties', [[
CREATE TABLE IF NOT EXISTS `lxr_bounties` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `citizenid` VARCHAR(50) NOT NULL,
  `name` VARCHAR(100) NOT NULL,
  `amount` DECIMAL(10,2) NOT NULL,
  `reason` VARCHAR(255) DEFAULT NULL,
  `posted_by` VARCHAR(100) DEFAULT NULL,
  `station` VARCHAR(32) DEFAULT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`), KEY `cid` (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
]])

local function board()
    return LXRCore.DB.Query('SELECT id, citizenid, name, amount, reason, posted_by, station, created_at FROM lxr_bounties ORDER BY amount DESC, id DESC LIMIT 50') or {}
end

local function payBounty(T, hunterSrc)
    local rows = LXRCore.DB.Query('SELECT id, amount FROM lxr_bounties WHERE citizenid = ?', { T.PlayerData.citizenid }) or {}
    local total = 0
    for _, r in ipairs(rows) do total = total + (tonumber(r.amount) or 0) end
    if total <= 0 then return 0 end
    LXRCore.DB.Update('DELETE FROM lxr_bounties WHERE citizenid = ?', { T.PlayerData.citizenid })
    local H = player(hunterSrc)
    if H then H.Functions.AddMoney('cash', total, 'bounty:' .. T.PlayerData.citizenid) notify(hunterSrc, 'info.bounty_paid', 'success', { amount = ('%.2f'):format(total) }) end
    LXRCore.Emit('lxr:lawman:bounty:paid', nil, T.PlayerData.citizenid, total, hunterSrc)
    return total
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🏛️ STATION: duty, armoury, evidence, desk
-- ═══════════════════════════════════════════════════════════════════════════════
local function desk(src)
    local P = player(src)
    local job = P.PlayerData.job
    local station = L.StationFor(job.name)
    local onDuty = {}
    for _, s in ipairs(Config.Stations) do
        for _, j in ipairs(s.jobs) do
            for _, o in ipairs(LXR.Players.OnDuty(j)) do onDuty[#onDuty + 1] = { name = nameOf(o._r), job = j, grade = o._r.PlayerData.job.grade.name } end
        end
    end
    return { station = station and { id = station.id, label = station.label }, job = { name = job.name, label = LXRShared.Jobs[job.name] and LXRShared.Jobs[job.name].label or job.name, grade = job.grade.name, onduty = job.onduty },
             onDuty = onDuty, bounties = Config.Bounties.enabled and board() or {}, canPost = L.IsLaw(job), limits = { bountyMin = Config.Bounties.min, bountyMax = Config.Bounties.max, fineMin = Config.Fines.min, fineMax = Config.Fines.max, jailMax = Config.Jail.maxMinutes } }
end

LXR.RPC.Register('lxr-lawman:desk', function(src, stationId)
    if limited(src) then return false, 'rate' end
    local P, st = player(src), L.Station(stationId)
    if not P or not st then return false, 'invalid' end
    local job = P.PlayerData.job
    if not (L.IsLaw(job, true) or L.IsHunter(job)) then return false, 'not_law' end
    if not nearCoords(src, st.desk) then return false, 'too_far' end
    return true, desk(src), Lang.bundle(), LXRCore.Brand
end)

LXR.RPC.Register('lxr-lawman:duty', function(src, stationId)
    if limited(src) then return false, 'rate' end
    local P, st = player(src), L.Station(stationId)
    if not P or not st or not L.IsLaw(P.PlayerData.job, true) then return false, 'not_law' end
    if not nearCoords(src, st.desk) then return false, 'too_far' end
    P.Functions.SetJobDuty(not P.PlayerData.job.onduty)
    notify(src, P.PlayerData.job.onduty and 'info.on_duty' or 'info.off_duty', 'inform')
    return true, desk(src)
end)

LXR.RPC.Register('lxr-lawman:armoury', function(src, stationId)
    if limited(src) then return false, 'rate' end
    local P, st = player(src), L.Station(stationId)
    if not P or not st or not L.IsLaw(P.PlayerData.job) then return false, 'not_law' end
    if not LXRShared.JobHasPerm(P.PlayerData.job, 'armory') then return false, 'no_armoury' end
    if not nearCoords(src, st.armoury) then return false, 'too_far' end
    exports['lxr-inventory']:OpenInventory(src, 'stash', L.ArmouryStash(P.PlayerData.job.name), { label = Lang:t('ui.armoury') })
    return true
end)

LXR.RPC.Register('lxr-lawman:evidence', function(src, stationId)
    if limited(src) then return false, 'rate' end
    local P, st = player(src), L.Station(stationId)
    if not P or not st or not L.IsLaw(P.PlayerData.job) then return false, 'not_law' end
    if not nearCoords(src, st.evidence) then return false, 'too_far' end
    exports['lxr-inventory']:OpenInventory(src, 'stash', L.EvidenceStash(st.id), { label = Lang:t('ui.evidence') })
    return true
end)

LXR.RPC.Register('lxr-lawman:bounty:post', function(src, stationId, citizenid, amount, reason)
    if limited(src) then return false, 'rate' end
    local P, st = player(src), L.Station(stationId)
    if not P or not st or not L.IsLaw(P.PlayerData.job) or not Config.Bounties.enabled then return false, 'not_law' end
    amount = L.Bounty(amount)
    if not amount then return false, 'bad_amount' end
    local T = LXRCore.Functions.GetPlayerByCitizenId(citizenid) or LXRCore.Functions.GetOfflinePlayerByCitizenId(citizenid)
    if not T then return false, 'no_such_name' end
    reason = tostring(reason or ''):gsub('[%c<>]', ''):sub(1, 120)
    LXRCore.DB.Insert('INSERT INTO lxr_bounties (citizenid, name, amount, reason, posted_by, station) VALUES (?, ?, ?, ?, ?, ?)', { citizenid, nameOf(T), amount, reason, nameOf(P), st.id })
    LXRCore.Emit('lxr:lawman:bounty:posted', nil, citizenid, amount, src)
    log('bounty posted', { source = src, target = citizenid, amount = amount })
    return true, desk(src)
end)

LXR.RPC.Register('lxr-lawman:bounty:pull', function(src, stationId, id)
    if limited(src) then return false, 'rate' end
    local P, st = player(src), L.Station(stationId)
    if not P or not st or not L.IsLaw(P.PlayerData.job) then return false, 'not_law' end
    LXRCore.DB.Update('DELETE FROM lxr_bounties WHERE id = ?', { tonumber(id) or -1 })
    return true, desk(src)
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🔗 CUFFS & ESCORT
-- ═══════════════════════════════════════════════════════════════════════════════
local function setCuffed(T, on, by)
    T.Functions.SetMetaData('ishandcuffed', on == true)
    Player(T.PlayerData.source).state:set('cuffed', on == true, true)
    TriggerClientEvent('lxr-lawman:client:cuffed', T.PlayerData.source, on == true)
    if on and Config.Law.disarmOnCuff and GetResourceState('lxr-weapons') == 'started' then exports['lxr-weapons']:Disarm(T.PlayerData.source, 'cuffed') end
    LXRCore.Emit('lxr:lawman:cuffed', nil, T.PlayerData.source, on == true, by)
end

RegisterNetEvent('lxr-lawman:server:cuff', function(targetId)
    local src = source
    local O, T, why = pair(src, targetId, Config.Cuffs.distance)
    if not O then return notify(src, 'error.' .. why, 'error') end
    local cuffed = T.PlayerData.metadata.ishandcuffed == true
    if not cuffed and Config.Law.cuffItem and not Inventory.HasItem(src, Config.Law.cuffItem) then return notify(src, 'error.no_cuffs', 'error') end
    setCuffed(T, not cuffed, src)
    if cuffed and escorts[T.PlayerData.source] then escorts[T.PlayerData.source] = nil TriggerClientEvent('lxr-lawman:client:escort', T.PlayerData.source, nil) end
    notify(src, cuffed and 'info.uncuffed' or 'info.cuffed', 'success', { name = nameOf(T) })
    notify(T.PlayerData.source, cuffed and 'info.you_uncuffed' or 'info.you_cuffed', 'inform')
    log(cuffed and 'uncuffed' or 'cuffed', { source = src, target = T.PlayerData.source })
end)

RegisterNetEvent('lxr-lawman:server:escort', function(targetId)
    local src = source
    local O, T, why = pair(src, targetId, Config.Cuffs.distance)
    if not O then return notify(src, 'error.' .. why, 'error') end
    if T.PlayerData.metadata.ishandcuffed ~= true then return notify(src, 'error.not_cuffed', 'error') end
    local t = T.PlayerData.source
    if escorts[t] == src then escorts[t] = nil TriggerClientEvent('lxr-lawman:client:escort', t, nil)
    else escorts[t] = src TriggerClientEvent('lxr-lawman:client:escort', t, src) end
end)

RegisterNetEvent('lxr-lawman:server:search', function(targetId)
    local src = source
    local O, T, why = pair(src, targetId)
    if not O then return notify(src, 'error.' .. why, 'error') end
    exports['lxr-inventory']:OpenInventory(src, 'otherplayer', T.PlayerData.source)
    LXRCore.Emit('lxr:lawman:searched', nil, T.PlayerData.source, src)
end)

RegisterNetEvent('lxr-lawman:server:seize', function(targetId)
    local src = source
    local O, T, why = pair(src, targetId)
    if not O then return notify(src, 'error.' .. why, 'error') end
    if not Config.Law.seizeIllegal then return end
    local st = L.StationFor(O.PlayerData.job.name)
    local n = 0
    for _, it in ipairs(L.Seizable(T.PlayerData.items)) do
        if T.Functions.RemoveItem(it.name, it.amount, it.slot, 'seized') then
            n = n + it.amount
            if st then exports['lxr-inventory']:AddStashItem(L.EvidenceStash(st.id), it.name, it.amount, it.info) end
        end
    end
    if GetResourceState('lxr-weapons') == 'started' then exports['lxr-weapons']:Disarm(T.PlayerData.source, 'seized') end
    notify(src, 'info.seized', 'success', { n = n })
    LXRCore.Emit('lxr:lawman:seized', nil, T.PlayerData.source, src, n)
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- 💸 FINES
-- ═══════════════════════════════════════════════════════════════════════════════
RegisterNetEvent('lxr-lawman:server:fine', function(targetId, amount, reason)
    local src = source
    local O, T, why = pair(src, targetId)
    if not O then return notify(src, 'error.' .. why, 'error') end
    amount = L.Fine(amount)
    if not amount then return notify(src, 'error.bad_amount', 'error') end
    reason = tostring(reason or ''):gsub('[%c<>]', ''):sub(1, 120)
    local acc = Config.Fines.account
    if not T.Functions.RemoveMoney(acc, amount, 'fine:' .. reason) then
        acc = Config.Fines.fallbackAccount
        if not acc or not T.Functions.RemoveMoney(acc, amount, 'fine:' .. reason) then return notify(src, 'error.cannot_pay', 'error') end
    end
    if Config.Fines.toSociety and GetResourceState('lxr-bank') == 'started' then exports['lxr-bank']:MoveBook('society_' .. O.PlayerData.job.name, amount, O.PlayerData.citizenid, 'fine: ' .. nameOf(T)) end
    notify(src, 'info.fined', 'success', { name = nameOf(T), amount = ('%.2f'):format(amount) })
    notify(T.PlayerData.source, 'info.you_fined', 'inform', { amount = ('%.2f'):format(amount), reason = reason })
    LXRCore.Emit('lxr:lawman:fined', nil, T.PlayerData.source, src, amount, reason)
    log('fine', { source = src, target = T.PlayerData.source, amount = amount, reason = reason })
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- ⛓️ JAIL
-- ═══════════════════════════════════════════════════════════════════════════════
local function jail(T, minutes, by, reason)
    T.Functions.SetMetaData('injail', minutes)
    T.Functions.SetMetaData('jailreason', reason)
    if T.PlayerData.metadata.ishandcuffed then setCuffed(T, false, by) end
    local t = T.PlayerData.source
    escorts[t] = nil
    TriggerClientEvent('lxr-lawman:client:escort', t, nil)
    if Config.Jail.stripWeapons and GetResourceState('lxr-weapons') == 'started' then exports['lxr-weapons']:Disarm(t, 'jailed') end
    Player(t).state:set('jailed', minutes, true)
    TriggerClientEvent('lxr-lawman:client:jail', t, minutes)
    LXRCore.Emit('lxr:lawman:jailed', nil, t, minutes, by, reason)
end

local function release(T, reason)
    T.Functions.SetMetaData('injail', 0)
    local t = T.PlayerData.source
    Player(t).state:set('jailed', 0, true)
    TriggerClientEvent('lxr-lawman:client:jail', t, 0)
    LXRCore.Emit('lxr:lawman:released', nil, t, reason)
end

RegisterNetEvent('lxr-lawman:server:jail', function(targetId, minutes, reason)
    local src = source
    local O, T, why = pair(src, targetId)
    if not O then return notify(src, 'error.' .. why, 'error') end
    minutes = L.Sentence(minutes)
    if not minutes then return notify(src, 'error.bad_sentence', 'error') end
    reason = tostring(reason or ''):gsub('[%c<>]', ''):sub(1, 120)
    jail(T, minutes, src, reason)
    local paid = Config.Bounties.enabled and Config.Bounties.payOn == 'jail' and payBounty(T, src) or 0
    notify(src, 'info.jailed', 'success', { name = nameOf(T), minutes = minutes })
    notify(T.PlayerData.source, 'info.you_jailed', 'inform', { minutes = minutes, reason = reason })
    log('jailed', { source = src, target = T.PlayerData.source, minutes = minutes, bounty = paid })
end)

RegisterNetEvent('lxr-lawman:server:release', function(targetId)
    local src = source
    if limited(src) then return end
    local O = player(src)
    if not O or not L.IsLaw(O.PlayerData.job) then return end
    local T = player(tonumber(targetId) or -1)
    if not T or (tonumber(T.PlayerData.metadata.injail) or 0) <= 0 then return end
    release(T, 'released')
    notify(src, 'info.released', 'success', { name = nameOf(T) })
end)

-- bounty hunters bring a name in alive at a station desk
LXR.RPC.Register('lxr-lawman:turnin', function(src, stationId, targetId)
    if limited(src) then return false, 'rate' end
    local H, st = player(src), L.Station(stationId)
    if not H or not st or not (L.IsHunter(H.PlayerData.job) or L.IsLaw(H.PlayerData.job)) then return false, 'not_law' end
    if not nearCoords(src, st.desk, 6.0) then return false, 'too_far' end
    local T = player(tonumber(targetId) or -1)
    if not T or not near(src, T.PlayerData.source, 6.0) then return false, 'invalid' end
    if T.PlayerData.metadata.ishandcuffed ~= true then return false, 'not_cuffed' end
    local rows = LXRCore.DB.Query('SELECT SUM(amount) AS total FROM lxr_bounties WHERE citizenid = ?', { T.PlayerData.citizenid })
    local total = rows and rows[1] and tonumber(rows[1].total) or 0
    if total <= 0 then return false, 'no_bounty' end
    jail(T, math.min(Config.Jail.maxMinutes, math.max(Config.Jail.minMinutes, math.floor(total / 10))), src, 'bounty')
    payBounty(T, src)
    return true, desk(src)
end)

-- the sentence counts down while the inmate is online
CreateThread(function()
    while true do
        Wait(60000)
        for src, P in pairs(LXRCore.Players) do
            local left = tonumber(P.PlayerData.metadata.injail) or 0
            if left > 0 then
                left = left - 1
                LXRCore.Emit('lxr:lawman:jail:tick', nil, src, left)
                if left <= 0 then release(P, 'served') notify(src, 'info.served', 'success') else P.Functions.SetMetaData('injail', left) Player(src).state:set('jailed', left, true) end
            end
        end
    end
end)

-- relog: put people back where they belong
RegisterNetEvent('lxr-lawman:server:ready', function()
    local src = source
    local P = player(src)
    if not P then return end
    local left = tonumber(P.PlayerData.metadata.injail) or 0
    Player(src).state:set('jailed', left, true)
    Player(src).state:set('cuffed', P.PlayerData.metadata.ishandcuffed == true, true)
    if left > 0 then TriggerClientEvent('lxr-lawman:client:jail', src, left) end
    if P.PlayerData.metadata.ishandcuffed then TriggerClientEvent('lxr-lawman:client:cuffed', src, true) end
end)

-- backup
RegisterNetEvent('lxr-lawman:server:backup', function()
    local src = source
    if limited(src) then return end
    local O = player(src)
    if not O or not L.IsLaw(O.PlayerData.job) or GetResourceState('lxr-dispatch') ~= 'started' then return end
    exports['lxr-dispatch']:Raise({ kind = 'backup', coords = GetEntityCoords(GetPlayerPed(src)), title = Lang:t('call.backup', { name = nameOf(O) }), src = src })
end)

AddEventHandler('playerDropped', function()
    buckets[source] = nil
    for t, o in pairs(escorts) do if o == source or t == source then escorts[t] = nil if t ~= source then TriggerClientEvent('lxr-lawman:client:escort', t, nil) end end end
end)

CreateThread(function()
    if Config.Debug.printBanner then print(('^1[lxr-lawman]^7 v%s — %d stations, jail at %s'):format(GetResourceMetadata(RES, 'version', 0), #Config.Stations, Config.Jail.place.label)) end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- 📤 EXPORTS
-- ═══════════════════════════════════════════════════════════════════════════════
exports('IsLaw', function(src) local P = player(src) return P ~= nil and L.IsLaw(P.PlayerData.job) end)
exports('Cuff', function(src, on) local T = player(src) if T then setCuffed(T, on ~= false, nil) return true end return false end)
exports('Jail', function(src, minutes, reason) local T = player(src) local m = L.Sentence(minutes) if T and m then jail(T, m, nil, reason or 'export') return true end return false end)
exports('Release', function(src) local T = player(src) if T then release(T, 'export') return true end return false end)
exports('Board', board)
exports('PostBounty', function(citizenid, amount, reason, by)
    local a = L.Bounty(amount) if not a then return false end
    local T = LXRCore.Functions.GetPlayerByCitizenId(citizenid) or LXRCore.Functions.GetOfflinePlayerByCitizenId(citizenid)
    if not T then return false end
    LXRCore.DB.Insert('INSERT INTO lxr_bounties (citizenid, name, amount, reason, posted_by) VALUES (?, ?, ?, ?, ?)', { citizenid, nameOf(T), a, reason, by or 'county' })
    return true
end)
