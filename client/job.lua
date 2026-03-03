--[[
    ██╗     ██╗  ██╗██████╗        ██████╗ ██████╗ ██████╗ ███████╗
    ██║     ╚██╗██╔╝██╔══██╗      ██╔════╝██╔═══██╗██╔══██╗██╔════╝
    ██║      ╚███╔╝ ██████╔╝█████╗██║     ██║   ██║██████╔╝█████╗  
    ██║      ██╔██╗ ██╔══██╗╚════╝██║     ██║   ██║██╔══██╗██╔══╝  
    ███████╗██╔╝ ██╗██║  ██║      ╚██████╗╚██████╔╝██║  ██║███████╗
    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝       ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝

    🐺 LXR Police Job - Client: Job

    ═══════════════════════════════════════════════════════════════════════════════
    SERVER INFORMATION
    ═══════════════════════════════════════════════════════════════════════════════

    Server:    The Land of Wolves 🐺
    Developer: iBoss21 / The Lux Empire
    Website:   https://www.wolves.land
    Discord:   https://discord.gg/CrKcWdfd3A
    Store:     https://theluxempire.tebex.io

    © 2026 iBoss21 / The Lux Empire | wolves.land | All Rights Reserved
    ═══════════════════════════════════════════════════════════════════════════════
]]
-- Variables
local currentGarage = 0
local inFingerprint = false
local FingerPrintSessionId = nil

-- Functions
-- local function DrawText3D(x, y, z, text)
--     SetTextScale(0.35, 0.35)
--     SetTextFont(4)
--     SetTextProportional(1)
--     SetTextColour(255, 255, 255, 215)
--     SetTextEntry("STRING")
--     SetTextCentre(true)
--     AddTextComponentString(text)
--     SetDrawOrigin(x,y,z, 0)
--     DrawText(0.0, 0.0)
--     local factor = (string.len(text)) / 370
--     DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
--     ClearDrawOrigin()
-- end

function CreatePrompts()
    for k,v in pairs(Config.Locations['duty']) do
        exports['lxr-core']:createPrompt('duty_prompt_' .. k, v, 0xF3830D8E, Lang:t('prompt.toggle_duty_status'), {
            type = 'client',
            event = 'lxr-policejob:ToggleDuty',
            args = {},
        })
    end

    for k,v in pairs(Config.Locations['evidence']) do
        exports['lxr-core']:createPrompt('evidence_prompt_' .. k, v, 0xF3830D8E, Lang:t('prompt.open_evidence_stash'), {
            type = 'client',
            event = 'police:client:EvidenceStashDrawer',
            args = { k },
        })
    end

    for k,v in pairs(Config.Locations['stash']) do
        exports['lxr-core']:createPrompt('stash_prompt_' .. k, v, 0xF3830D8E, Lang:t('prompt.open_personal_stash'), {
            type = 'client',
            event = 'police:client:OpenPersonalStash',
            args = {},
        })
    end

    for k,v in pairs(Config.Locations['armory']) do
        exports['lxr-core']:createPrompt('armory_prompt_' .. k, v, 0xF3830D8E, Lang:t('prompt.open_armory'), {
            type = 'client',
            event = 'police:client:OpenArmory',
            args = {},
        })
    end
end

local function loadAnimDict(dict) -- interactions, job,
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Wait(10)
    end
end

local function GetClosestPlayer() -- interactions, job, tracker
    local closestPlayers = exports['lxr-core']:GetPlayersFromCoords()
    local closestDistance = -1
    local closestPlayer = -1
    local coords = GetEntityCoords(PlayerPedId())

    for i = 1, #closestPlayers, 1 do
        if closestPlayers[i] ~= PlayerId() then
            local pos = GetEntityCoords(GetPlayerPed(closestPlayers[i]))
            local distance = #(pos - coords)

            if closestDistance == -1 or closestDistance > distance then
                closestPlayer = closestPlayers[i]
                closestDistance = distance
            end
        end
    end

    return closestPlayer, closestDistance
end

local function IsArmoryWhitelist() -- being removed
    local retval = false

    if exports['lxr-core']:GetPlayerData().job.name == 'police' then
        retval = true
    end
    return retval
end

local function SetWeaponSeries()
    for k, v in ipairs(Config.Items.items) do
        if k < 6 then
            local randomInt = exports['lxr-core']:RandomInt
            local randomStr = exports['lxr-core']:RandomStr

            local serie = tostring(randomInt(2) .. randomStr(3) .. randomInt(1) .. randomStr(2) .. randomInt(3) .. randomStr(4))
            Config.Items.items[k].info.serie = serie
        end
    end
end


RegisterNetEvent('police:client:ImpoundVehicle', function(fullImpound, price)
    local vehicle = exports['lxr-core']:GetClosestVehicle()
    local bodyDamage = math.ceil(GetVehicleBodyHealth(vehicle))
    local engineDamage = math.ceil(GetVehicleEngineHealth(vehicle))
    local totalFuel = exports['LegacyFuel']:GetFuel(vehicle)
    if vehicle ~= 0 and vehicle then
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        local vehpos = GetEntityCoords(vehicle)
        if #(pos - vehpos) < 5.0 and not IsPedInAnyVehicle(ped) then
            local plate = exports['lxr-core']:GetPlate(vehicle)
            TriggerServerEvent("police:server:Impound", plate, fullImpound, price, bodyDamage, engineDamage, totalFuel)
            exports['lxr-core']:DeleteVehicle(vehicle)
        end
    end
end)

RegisterNetEvent('police:client:CheckStatus', function()
    exports['lxr-core']:GetPlayerData(function(PlayerData)
        if PlayerData.job.name == "police" then
            local player, distance = GetClosestPlayer()
            if player ~= -1 and distance < 5.0 then
                local playerId = GetPlayerServerId(player)
                exports['lxr-core']:TriggerCallback('police:GetPlayerStatus', function(result)
                    if result then
                        for k, v in pairs(result) do
                            exports['lxr-core']:Notify(9, ''..v..'')
                        end
                    end
                end, playerId)
            else
                exports['lxr-core']:Notify(9, Lang:t("error.none_nearby"), 5000, 0, 'mp_lobby_textures', 'cross', 'COLOR_WHITE')
            end
        end
    end)
end)

RegisterNetEvent('police:client:EvidenceStashDrawer', function(k)
    local currentEvidence = k
    local pos = GetEntityCoords(PlayerPedId())
    local takeLoc = Config.Locations["evidence"][currentEvidence]

    if not takeLoc then return end

    if #(pos - takeLoc) <= 1.0 then
        local drawer = LocalInput(Lang:t('info.slot'), 11)
        if tonumber(drawer) then
            TriggerServerEvent("inventory:server:OpenInventory", "stash", Lang:t('info.current_evidence', {value = currentEvidence, value2 = drawer}), {
                maxweight = 4000000,
                slots = 500,
            })
            TriggerEvent("inventory:client:SetCurrentStash", Lang:t('info.current_evidence', {value = currentEvidence, value2 = drawer}))
        end
    end
end)

-- Toggle Duty in an event.
RegisterNetEvent('lxr-policejob:ToggleDuty', function()
    onDuty = not onDuty
    TriggerServerEvent("police:server:UpdateCurrentCops")
    TriggerServerEvent("police:server:UpdateBlips")
    TriggerServerEvent("LXRCore:ToggleDuty")
end)

RegisterNetEvent('police:client:OpenPersonalStash', function()
    TriggerServerEvent("inventory:server:OpenInventory", "stash", "policestash_"..exports['lxr-core']:GetPlayerData().citizenid)
    TriggerEvent("inventory:client:SetCurrentStash", "policestash_"..exports['lxr-core']:GetPlayerData().citizenid)
end)

RegisterNetEvent('police:client:OpenPersonalTrash', function()
    TriggerServerEvent("inventory:server:OpenInventory", "stash", "policetrash", {
        maxweight = 4000000,
        slots = 300,
    })
    TriggerEvent("inventory:client:SetCurrentStash", "policetrash")
end)

RegisterNetEvent('police:client:OpenArmory', function()
    local authorizedItems = {
        label = Lang:t('menu.pol_armory'),
        slots = 30,
        items = {}
    }

    for index, armoryItem in ipairs(Config.Items.items) do
        for _, authorizedJobGrade in ipairs(armoryItem.authorizedJobGrades) do
            if authorizedJobGrade == PlayerJob.grade.level then
                armoryItem.slot = index
                table.insert(authorizedItems.items, armoryItem)
                break  -- Exit the loop after finding a match
            end
        end
    end

    SetWeaponSeries()
    TriggerServerEvent("inventory:server:OpenInventory", "shop", "police", authorizedItems)
end)


-- Threads

-- Toggle Duty
CreateThread(function()
    if LocalPlayer.state.isLoggedIn and PlayerJob.name == 'police' then
        CreatePrompts()
    end

    for k, v in pairs(Config.Locations["stations"]) do
        local StationBlip = N_0x554d9d53f696d002(1664425300, v.coords)
        SetBlipSprite(StationBlip, -693644997, 52)
        SetBlipScale(StationBlip, 0.7)
        Citizen.InvokeNative(0x9CB1A1623062F402, StationBlip, v.label)
        -- Citizen.ReturnResultAnyway()
    end
    local sharedItems = exports['lxr-core']:GetItems()
    local sharedWeapons = exports['lxr-core']:GetWeapons()
    for k,v in pairs(sharedWeapons) do
        local weaponName = v.name
        local weaponLabel = v.label
        local weaponHash = GetHashKey(v.name)
        local weaponAmmo, weaponAmmoLabel = nil, 'unknown'
        if v.ammotype then
            weaponAmmo = v.ammotype:lower()
            weaponAmmoLabel = sharedItems[weaponAmmo].label
        end

        Config.WeaponHashes[weaponHash] = {
            weaponName = weaponName,
            weaponLabel = weaponLabel,
            weaponAmmo = weaponAmmo,
            weaponAmmoLabel = weaponAmmoLabel
        }
    end
end)
