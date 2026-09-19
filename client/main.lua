--[[ ═══════════════════════════════════════════════════════════════════════════
     LXR-LAWMAN — Client: the officer's options, the prisoner's state
     ═══════════════════════════════════════════════════════════════════════════
     Every action is an lxr-interact option on a player or a station point;
     the server answers. This file only mirrors state on the local ped:
     cuffed (animation + blocked controls), escorted (attached), jailed
     (teleported and kept inside).
     ═══════════════════════════════════════════════════════════════════════════
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

local LXRCore = exports['lxr-core']:GetCoreObject()
local LXR = exports['lxr-core']:GetLXR()
local L = LXRLawman
local N = Citizen.InvokeNative
local cuffed, escortedBy, jailLeft = false, nil, 0
local session = nil
local blips = {}

local function me() return LXRCore.PlayerData or {} end
local function isLaw() return L.IsLaw(me().job) end
local function toast(key, kind, vars) LXRCore.Notify(Lang:t(key, vars), kind or 'info') end
local function serverIdOf(ped) return GetPlayerServerId(NetworkGetPlayerIndexFromPed(ped)) end

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🔗 CUFFED / ESCORTED / JAILED (my own ped)
-- ═══════════════════════════════════════════════════════════════════════════════
local function playCuff()
    local a = Config.Cuffs.anim
    RequestAnimDict(a.dict)
    local t = GetGameTimer() + 3000
    while not HasAnimDictLoaded(a.dict) and GetGameTimer() < t do Wait(10) end
    TaskPlayAnim(PlayerPedId(), a.dict, a.name, 8.0, -8.0, -1, a.flag or 49, 0, false, false, false)
end

RegisterNetEvent('lxr-lawman:client:cuffed', function(on)
    cuffed = on == true
    local ped = PlayerPedId()
    if cuffed then
        playCuff()
        CreateThread(function()
            while cuffed do
                for _, c in ipairs(Config.Cuffs.cuffedControls) do DisableControlAction(0, c, true) end
                if not IsEntityPlayingAnim(ped, Config.Cuffs.anim.dict, Config.Cuffs.anim.name, 3) and not escortedBy then playCuff() end
                Wait(0)
            end
        end)
    else
        ClearPedTasks(ped)
    end
end)

RegisterNetEvent('lxr-lawman:client:escort', function(officerId)
    local ped = PlayerPedId()
    if officerId then
        local idx = GetPlayerFromServerId(officerId)
        local officer = idx ~= -1 and GetPlayerPed(idx) or 0
        if officer == 0 then return end
        escortedBy = officerId
        local o = Config.Cuffs.escortOffset
        AttachEntityToEntity(ped, officer, 0, o.x, o.y, o.z, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
    else
        escortedBy = nil
        DetachEntity(ped, true, false)
        if cuffed then playCuff() end
    end
end)

local function toJail()
    local p = Config.Jail.place.coords
    DoScreenFadeOut(500) Wait(600)
    SetEntityCoords(PlayerPedId(), p.x, p.y, p.z, false, false, false, false)
    SetEntityHeading(PlayerPedId(), p.w)
    Wait(300) DoScreenFadeIn(500)
end

RegisterNetEvent('lxr-lawman:client:jail', function(minutes)
    minutes = tonumber(minutes) or 0
    local was = jailLeft
    jailLeft = minutes
    if minutes > 0 then
        if was <= 0 then
            toJail()
            CreateThread(function()
                while jailLeft > 0 do
                    Wait(5000)
                    local p = Config.Jail.place.coords
                    if #(GetEntityCoords(PlayerPedId()) - vector3(p.x, p.y, p.z)) > Config.Jail.keepInside then toJail() toast('info.walked_back', 'warning') end
                end
            end)
        end
    elseif was > 0 then
        local r = Config.Jail.release
        DoScreenFadeOut(500) Wait(600)
        SetEntityCoords(PlayerPedId(), r.x, r.y, r.z, false, false, false, false) SetEntityHeading(PlayerPedId(), r.w)
        Wait(300) DoScreenFadeIn(500)
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- 👮 OPTIONS ON PEOPLE
-- ═══════════════════════════════════════════════════════════════════════════════
local function ask(title, fields, cb)
    if GetResourceState('lxr-nui') ~= 'started' then return end
    exports['lxr-nui']:Input({ title = title, fields = fields }, function(v) if v then cb(v) end end)
end

CreateThread(function()
    while GetResourceState('lxr-interact') ~= 'started' do Wait(1000) end
    local I = exports['lxr-interact']
    local function target(d) return d.entity and serverIdOf(d.entity) end
    I:AddGlobal('lxr-lawman:player', 'player', { label = Lang:t('ui.citizen'), distance = Config.Cuffs.distance, options = {
        { label = Lang:t('ui.cuff'), key = 'G', canInteract = function(e) return isLaw() and e and Player(serverIdOf(e)).state.cuffed ~= true end, onSelect = function(d) TriggerServerEvent('lxr-lawman:server:cuff', target(d)) end },
        { label = Lang:t('ui.uncuff'), key = 'G', canInteract = function(e) return isLaw() and e and Player(serverIdOf(e)).state.cuffed == true end, onSelect = function(d) TriggerServerEvent('lxr-lawman:server:cuff', target(d)) end },
        { label = Lang:t('ui.escort'), key = 'E', canInteract = function(e) return isLaw() and e and Player(serverIdOf(e)).state.cuffed == true end, onSelect = function(d) TriggerServerEvent('lxr-lawman:server:escort', target(d)) end },
        { label = Lang:t('ui.search'), key = 'R', canInteract = isLaw, onSelect = function(d) TriggerServerEvent('lxr-lawman:server:search', target(d)) end },
        { label = Lang:t('ui.seize'), key = 'X', canInteract = function(e) return isLaw() and Config.Law.seizeIllegal and e and Player(serverIdOf(e)).state.cuffed == true end, onSelect = function(d) TriggerServerEvent('lxr-lawman:server:seize', target(d)) end },
        { label = Lang:t('ui.fine'), key = 'B', canInteract = isLaw, onSelect = function(d)
            local id = target(d)
            ask(Lang:t('ui.fine'), { { id = 'amount', label = Lang:t('ui.amount'), type = 'number', min = Config.Fines.min, step = 0.25 }, { id = 'reason', label = Lang:t('ui.reason'), max = 120 } }, function(v) TriggerServerEvent('lxr-lawman:server:fine', id, v.amount, v.reason) end)
        end },
        { label = Lang:t('ui.jail'), key = 'H', canInteract = function(e) return isLaw() and e and Player(serverIdOf(e)).state.cuffed == true end, onSelect = function(d)
            local id = target(d)
            ask(Lang:t('ui.jail'), { { id = 'minutes', label = Lang:t('ui.minutes'), type = 'number', min = Config.Jail.minMinutes, max = Config.Jail.maxMinutes, step = 1 }, { id = 'reason', label = Lang:t('ui.reason'), max = 120 } }, function(v) TriggerServerEvent('lxr-lawman:server:jail', id, v.minutes, v.reason) end)
        end },
        { label = Lang:t('ui.release'), key = 'H', canInteract = function(e) return isLaw() and e and (tonumber(Player(serverIdOf(e)).state.jailed) or 0) > 0 end, onSelect = function(d) TriggerServerEvent('lxr-lawman:server:release', target(d)) end },
    }})

    -- stations
    for _, s in ipairs(Config.Stations) do
        I:AddPoint('lxr-lawman:desk:' .. s.id, s.desk, { label = s.label, distance = Config.Security.promptDistance, options = {
            { label = Lang:t('ui.desk'), key = 'J', canInteract = function() return L.IsLaw(me().job, true) or L.IsHunter(me().job) end, onSelect = function() openDesk(s) end },
            { label = Lang:t('ui.turnin'), key = 'E', canInteract = function() return L.IsHunter(me().job) or L.IsLaw(me().job) end, onSelect = function()
                -- the nearest cuffed player is the one being brought in
                local best, bd
                for _, pid in ipairs(GetActivePlayers()) do
                    local ped = GetPlayerPed(pid)
                    if ped ~= PlayerPedId() and Player(GetPlayerServerId(pid)).state.cuffed == true then
                        local d = #(GetEntityCoords(ped) - GetEntityCoords(PlayerPedId()))
                        if not bd or d < bd then best, bd = GetPlayerServerId(pid), d end
                    end
                end
                if not best then return toast('error.nobody_cuffed', 'error') end
                local ok, res = LXR.RPC.Server('lxr-lawman:turnin', s.id, best)
                if not ok then toast('error.' .. tostring(res), 'error') end
            end },
        }})
        I:AddPoint('lxr-lawman:armoury:' .. s.id, s.armoury, { label = Lang:t('ui.armoury'), distance = Config.Security.promptDistance, options = {
            { label = Lang:t('ui.open'), key = 'J', canInteract = isLaw, onSelect = function() local ok, res = LXR.RPC.Server('lxr-lawman:armoury', s.id) if not ok then toast('error.' .. tostring(res), 'error') end end },
        }})
        I:AddPoint('lxr-lawman:evidence:' .. s.id, s.evidence, { label = Lang:t('ui.evidence'), distance = Config.Security.promptDistance, options = {
            { label = Lang:t('ui.open'), key = 'J', canInteract = isLaw, onSelect = function() local ok, res = LXR.RPC.Server('lxr-lawman:evidence', s.id) if not ok then toast('error.' .. tostring(res), 'error') end end },
        }})
        if s.blip then
            local blip = N(0x554D9D53F696D002, 1664425300, s.desk.x, s.desk.y, s.desk.z)
            if blip and blip ~= 0 then
                N(0x74F74D3207ED525C, blip, joaat('blip_ambient_sheriff'), true)
                N(0x9CB1A1623062F402, blip, s.label)
                if GetResourceState('lxr-mapcolor') == 'started' then pcall(function() N(0x662D364ABF16DE2F, blip, exports['lxr-mapcolor']:modifier('law')) end) end
                blips[#blips + 1] = blip
            end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🗂️ THE DESK (NUI)
-- ═══════════════════════════════════════════════════════════════════════════════
local function closeDesk()
    if not session then return end
    session = nil
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
end

function openDesk(station)
    if session then return end
    local ok, data, bundle, brand = LXR.RPC.Server('lxr-lawman:desk', station.id)
    if not ok then return toast('error.' .. tostring(data), 'error') end
    session = { station = station }
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'open', data = data, locale = bundle, brand = brand or LXRCore.Brand, lang = Config.Lang })
end

local function rpc(name, ...)
    if not session then return { ok = false } end
    local ok, res = LXR.RPC.Server('lxr-lawman:' .. name, session.station.id, ...)
    if not ok then toast('error.' .. tostring(res), 'error') return { ok = false, why = res } end
    return { ok = true, data = res }
end
RegisterNUICallback('close', function(_, cb) closeDesk() cb({ ok = true }) end)
RegisterNUICallback('duty', function(_, cb) cb(rpc('duty')) end)
RegisterNUICallback('post', function(d, cb) cb(rpc('bounty:post', d.citizenid, d.amount, d.reason)) end)
RegisterNUICallback('pull', function(d, cb) cb(rpc('bounty:pull', d.id)) end)
RegisterNUICallback('sound', function(d, cb) PlaySoundFrontend(d.name or 'NAV_UP', d.set or 'HUD_SHOP_SOUNDSET', true, 0) cb({}) end)

RegisterCommand('backup', function() if isLaw() then TriggerServerEvent('lxr-lawman:server:backup') end end, false)

RegisterNetEvent('lxr:client:loaded', function() Wait(1500) TriggerServerEvent('lxr-lawman:server:ready') end)
AddEventHandler('onResourceStart', function(res) if res == GetCurrentResourceName() and LocalPlayer.state.isLoggedIn then TriggerServerEvent('lxr-lawman:server:ready') end end)
AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end
    closeDesk()
    for _, b in ipairs(blips) do RemoveBlip(b) end
    if escortedBy then DetachEntity(PlayerPedId(), true, false) end
end)

exports('IsCuffed', function() return cuffed end)
exports('JailLeft', function() return jailLeft end)
exports('IsLaw', isLaw)
