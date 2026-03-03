--[[
    ██╗     ██╗  ██╗██████╗        ██████╗ ██████╗ ██████╗ ███████╗
    ██║     ╚██╗██╔╝██╔══██╗      ██╔════╝██╔═══██╗██╔══██╗██╔════╝
    ██║      ╚███╔╝ ██████╔╝█████╗██║     ██║   ██║██████╔╝█████╗  
    ██║      ██╔██╗ ██╔══██╗╚════╝██║     ██║   ██║██╔══██╗██╔══╝  
    ███████╗██╔╝ ██╗██║  ██║      ╚██████╗╚██████╔╝██║  ██║███████╗
    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝       ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝

    🐺 LXR Police Job - Configuration

    This configuration file controls the full police job system for RedM.
    Officers can go on/off duty, access the armory, manage evidence, handcuff
    suspects, escort players, and respond to alerts across the map.

    ═══════════════════════════════════════════════════════════════════════════════
    SERVER INFORMATION
    ═══════════════════════════════════════════════════════════════════════════════

    Server:      The Land of Wolves 🐺
    Tagline:     Georgian RP 🇬🇪 | მგლების მიწა - რჩეულთა ადგილი!
    Description: ისტორია ცოცხლდება აქ! (History Lives Here!)
    Type:        Serious Hardcore Roleplay
    Access:      Discord & Whitelisted

    Developer:   iBoss21 / The Lux Empire
    Website:     https://www.wolves.land
    Discord:     https://discord.gg/CrKcWdfd3A
    GitHub:      https://github.com/iBoss21
    Store:       https://theluxempire.tebex.io
    Server:      https://servers.redm.net/servers/detail/8gj7eb

    ═══════════════════════════════════════════════════════════════════════════════

    Version: 1.0.0
    Performance Target: Optimized for minimal server overhead and client FPS impact

    Tags: RedM, Georgian, SeriousRP, Whitelist, PoliceJob, Law, Evidence

    Framework Support:
    - LXR Core (Primary)
    - RSG Core (Compatible)
    - VORP Core (Compatible)
    - RedEM:RP (Compatible)
    - QBR Core (Compatible)
    - QR Core (Compatible)
    - Standalone (Compatible)

    ═══════════════════════════════════════════════════════════════════════════════
    CREDITS
    ═══════════════════════════════════════════════════════════════════════════════

    Script Author: iBoss21 / The Lux Empire for The Land of Wolves

    © 2026 iBoss21 / The Lux Empire | wolves.land | All Rights Reserved
]]

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🐺 RESOURCE NAME PROTECTION - RUNTIME CHECK
-- ═══════════════════════════════════════════════════════════════════════════════

local REQUIRED_RESOURCE_NAME = "lxr-policejob"
local currentResourceName = GetCurrentResourceName()

if currentResourceName ~= REQUIRED_RESOURCE_NAME then
    error(string.format([[

        ═══════════════════════════════════════════════════════════════════════════════
        ❌ CRITICAL ERROR: RESOURCE NAME MISMATCH ❌
        ═══════════════════════════════════════════════════════════════════════════════

        Expected: %s
        Got: %s

        This resource is branded and must maintain the correct name.
        Rename the folder to "%s" to continue.

        🐺 wolves.land - The Land of Wolves

        ═══════════════════════════════════════════════════════════════════════════════

    ]], REQUIRED_RESOURCE_NAME, currentResourceName, REQUIRED_RESOURCE_NAME))
end

Config = {}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ SERVER BRANDING & INFO ████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

Config.ServerInfo = {
    name = 'The Land of Wolves 🐺',
    tagline = 'Georgian RP 🇬🇪 | მგლების მიწა - რჩეულთა ადგილი!',
    description = 'ისტორია ცოცხლდება აქ!', -- History Lives Here!
    type = 'Serious Hardcore Roleplay',
    access = 'Discord & Whitelisted',

    -- Contact & Links
    website = 'https://www.wolves.land',
    discord = 'https://discord.gg/CrKcWdfd3A',
    github = 'https://github.com/iBoss21',
    store = 'https://theluxempire.tebex.io',
    serverListing = 'https://servers.redm.net/servers/detail/8gj7eb',

    -- Developer Info
    developer = 'iBoss21 / The Lux Empire',

    -- Tags
    tags = {'RedM', 'Georgian', 'SeriousRP', 'Whitelist', 'PoliceJob', 'Law', 'Evidence'}
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ FRAMEWORK CONFIGURATION ███████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

--[[
    Framework Priority (in order):
    1. LXR-Core (Primary)
    2. RSG-Core (Primary)
    3. VORP Core (Supported)
    4. RedEM:RP (Optional - if detected)
    5. QBR-Core (Optional - if detected)
    6. QR-Core (Optional - if detected)
    7. Standalone (Fallback)
]]

Config.Framework = 'auto' -- 'auto' or manual: 'lxr-core', 'rsg-core', 'vorp_core', 'redem_roleplay', 'qbr-core', 'qr-core', 'standalone'

-- Framework-specific settings
Config.FrameworkSettings = {
    ['lxr-core'] = {
        resource = 'lxr-core',
        notifications = 'ox_lib',
        inventory = 'lxr-inventory',
        target = 'ox_target',
        events = {
            server = 'lxr-core:server:%s',
            client = 'lxr-core:client:%s',
            callback = 'lxr-core:callback:%s'
        }
    },
    ['rsg-core'] = {
        resource = 'rsg-core',
        notifications = 'ox_lib',
        inventory = 'rsg-inventory',
        target = 'ox_target',
        events = {
            server = 'RSGCore:Server:%s',
            client = 'RSGCore:Client:%s',
            callback = 'RSGCore:Callback:%s'
        }
    },
    ['vorp_core'] = {
        resource = 'vorp_core',
        notifications = 'vorp',
        inventory = 'vorp_inventory',
        target = 'vorp_core',
        events = {
            server = 'vorp:server:%s',
            client = 'vorp:client:%s'
        }
    },
    ['redem_roleplay'] = {
        resource = 'redem_roleplay',
        notifications = 'redem',
        inventory = 'redem_inventory',
        target = 'redem_target',
        events = {
            server = 'redem:%s:server',
            client = 'redem:%s:client'
        }
    },
    ['qbr-core'] = {
        resource = 'qbr-core',
        notifications = 'ox_lib',
        inventory = 'qbr-inventory',
        target = 'ox_target',
        events = {
            server = 'QBR:Server:%s',
            client = 'QBR:Client:%s'
        }
    },
    ['qr-core'] = {
        resource = 'qr-core',
        notifications = 'ox_lib',
        inventory = 'qr-inventory',
        target = 'ox_target',
        events = {
            server = 'QR:Server:%s',
            client = 'QR:Client:%s'
        }
    },
    ['standalone'] = {
        notifications = 'print',
        inventory = 'none',
        target = 'none'
    }
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ BLIP & JOB CONFIGURATION ████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

-- Blip and Job Configuration
Config.ShowBlips = true

-- Job Roles and Permissions
Config.EvidenceJobs = {
    police = true
}
Config.BlipsJobs = {
    police = true,
    ambulance = true
}
Config.Law = {
    police = true,
    sheriff = true
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ EVIDENCE SYSTEM ███████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

-- Evidence System
Config.EvidenceRange = 2.5

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ OBJECT PROPS █████████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

-- Object Props Configuration
Config.Objects = {
    cone      = { model = "prop_roadcone02a",        freeze = false },
    barrier   = { model = "prop_barrier_work06a",    freeze = true  },
    roadsign  = { model = "prop_snow_sign_road_06g", freeze = true  },
    tent      = { model = "prop_gazebo_03",          freeze = true  },
    light     = { model = "prop_worklight_03b",      freeze = true  }
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ HANDCUFFS ████████████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

-- Handcuff Item Definition
Config.HandCuffItem = 'handcuffs'

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ LICENSE SYSTEM ███████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

-- Rank required for License Access
Config.LicenseRank = 2

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ LOCATION DATA ████████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

-- Location Data for Police Activities
Config.Locations = {
    duty = {
        vector3(1362.05, -1301.83, 77.77),  -- Valentine
        vector3(2507.53, -1301.41, 48.95),  -- Saint Denis
        vector3(-768.03, -1266.37, 44.05),  -- Blackwater
        vector3(-1812.03, -354.09, 164.65)  -- Strawberry
    },
    stash = {
        vector3(1359.24, -1299.65, 77.76),
        vector3(2497.01, -1301.2,  48.96),
        vector3(-766.55, -1271.61, 44.05),
        vector3(-1812.43, -355.87, 164.65)
    },
    armory = {
        vector3(1361.16, -1305.7,  77.76),
        vector3(2494.53, -1304.32, 48.95),
        vector3(-764.86, -1272.43, 44.04),
        vector3(-1813.93, -354.78, 164.65)
    },
    evidence = {
        vector3(1361.39, -1303.77, 77.77),
        vector3(2494.44, -1313.39, 48.95),
        vector3(-761.98, -1272.62, 44.05),
        vector3(-1807.17, -348.29, 164.66)
    },
    stations = {
        { label = "Sheriff",                    coords = vector3(1360.88, -1301.53, 77.77)  },
        { label = "Saint Denis Police Dept. HQ", coords = vector3(2501.83, -1309.04, 48.95)  },
        { label = "Blackwater Police Dept.",    coords = vector3(-760.47, -1269.14, 44.04)  },
        { label = "Strawberry Sheriff",         coords = vector3(-1810.57, -350.91, 164.66) }
    }
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ WEAPON & VEHICLE LISTS ████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

-- Weapon Hashes and Whitelisted Items
Config.WeaponHashes        = {}
Config.ArmoryWhitelist     = {}
Config.WhitelistedVehicles = {}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ ARMORY ITEMS ████████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

-- Armory Items
Config.Items = {
    label = "Police Armory",
    slots = 30,
    items = {
        {
            name                = "weapon_revolver_cattleman",
            price               = 0,
            amount              = 1,
            info                = { serie = "" },
            type                = "weapon",
            slot                = 1,
            authorizedJobGrades = { 0, 1, 2, 3, 4 }
        },
        {
            name                = "weapon_repeater_winchester",
            price               = 0,
            amount              = 1,
            info                = { serie = "" },
            type                = "weapon",
            slot                = 2,
            authorizedJobGrades = { 0, 1, 2, 3, 4 }
        },
        {
            name                = "weapon_melee_lantern",
            price               = 0,
            amount              = 1,
            info                = {},
            type                = "weapon",
            slot                = 3,
            authorizedJobGrades = { 0, 1, 2, 3, 4 }
        },
        {
            name                = "weapon_lasso",
            price               = 0,
            amount              = 1,
            info                = {},
            type                = "item",
            slot                = 4,
            authorizedJobGrades = { 0, 1, 2, 3, 4 }
        },
        {
            name                = "ammo_revolver",
            price               = 0,
            amount              = 5,
            info                = {},
            type                = "item",
            slot                = 5,
            authorizedJobGrades = { 0, 1, 2, 3, 4 }
        },
        {
            name                = "ammo_repeater",
            price               = 0,
            amount              = 5,
            info                = {},
            type                = "item",
            slot                = 6,
            authorizedJobGrades = { 0, 1, 2, 3, 4 }
        }
    }
}
