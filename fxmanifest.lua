--[[
    ██╗     ██╗  ██╗██████╗        ██████╗ ██████╗ ██████╗ ███████╗
    ██║     ╚██╗██╔╝██╔══██╗      ██╔════╝██╔═══██╗██╔══██╗██╔════╝
    ██║      ╚███╔╝ ██████╔╝█████╗██║     ██║   ██║██████╔╝█████╗  
    ██║      ██╔██╗ ██╔══██╗╚════╝██║     ██║   ██║██╔══██╗██╔══╝  
    ███████╗██╔╝ ██╗██║  ██║      ╚██████╗╚██████╔╝██║  ██║███████╗
    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝       ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝

    🐺 LXR Police Job - FXManifest

    ═══════════════════════════════════════════════════════════════════════════════
    RESOURCE INFORMATION
    ═══════════════════════════════════════════════════════════════════════════════

    Resource Name:  lxr-policejob
    Version:        1.0.0
    Author:         iBoss21 / The Lux Empire
    Description:    Full-featured police job system for RedM with evidence, armory,
                    handcuffs, escort, duty management, and more.

    Server:         The Land of Wolves 🐺
    Website:        https://www.wolves.land
    Discord:        https://discord.gg/CrKcWdfd3A

    ═══════════════════════════════════════════════════════════════════════════════
    FRAMEWORK SUPPORT
    ═══════════════════════════════════════════════════════════════════════════════

    Primary:
    - LXR Core (lxr-core)
    - RSG Core (rsg-core)

    Supported:
    - VORP Core (vorp_core)

    Optional (if detected):
    - RedEM:RP (redem_roleplay)
    - QBR Core (qbr-core)
    - QR Core (qr-core)
    - Standalone (no framework)

    ═══════════════════════════════════════════════════════════════════════════════

    © 2026 iBoss21 / The Lux Empire | wolves.land | All Rights Reserved
]]

fx_version 'cerulean'
game 'rdr3'

rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

-- Resource Metadata
name        'LXR Police Job'
author      'iBoss21 / The Lux Empire'
description 'Full-featured police job system for RedM with evidence, armory, handcuffs, escort, and duty management'
version     '1.0.0'

-- Lua 5.4
lua54 'yes'

shared_scripts {
'@lxr-core/shared/locale.lua',
'locales/en.lua',
'locales/*.lua',
    'config.lua',
}

client_scripts {
'client/main.lua',
--'client/camera.lua',
'client/interactions.lua',
'client/job.lua',
--'client/heli.lua',
--'client/anpr.lua',
'client/evidence.lua',
'client/objects.lua',
--'client/tracker.lua'
}

server_scripts {
'@oxmysql/lib/MySQL.lua',
'server/main.lua'
}
