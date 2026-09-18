--[[
    ██╗     ██╗  ██╗██████╗       ██╗      █████╗ ██╗    ██╗███╗   ███╗ █████╗ ███╗   ██╗
    ██║     ╚██╗██╔╝██╔══██╗      ██║     ██╔══██╗██║    ██║████╗ ████║██╔══██╗████╗  ██║
    ██║      ╚███╔╝ ██████╔╝█████╗██║     ███████║██║ █╗ ██║██╔████╔██║███████║██╔██╗ ██║
    ██║      ██╔██╗ ██╔══██╗╚════╝██║     ██╔══██║██║███╗██║██║╚██╔╝██║██╔══██║██║╚██╗██║
    ███████╗██╔╝ ██╗██║  ██║      ███████╗██║  ██║╚███╔███╔╝██║ ╚═╝ ██║██║  ██║██║ ╚████║
    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝      ╚══════╝╚═╝  ╚═╝ ╚══╝╚══╝ ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝

    LXR Core - Lawman

    The law of every town, on one resource. Any job of type `leo` or
    `federal` in the core registry is a law job here: duty at the station,
    cuffs and escort, search and seizure, fines that land in the society
    book, jail on the island with a sentence that counts down, bounties
    posted on the board and paid to whoever brings the name in. Nothing is
    decided on the client.

    Brand:       LXRCore — Lux Empire eXperience RedM Core
    Product:     wolves.land / The Land of Wolves
    Developer:   iBoss21 / LXRCore
    Website:     https://www.lxrcore.com
    Discord:     https://discord.gg/ZHMKVYyhBa (development)
    GitHub:      https://github.com/LXRCore

    Version: 3.0.0
    Performance Target: 0.00 ms idle (interact targets; per-frame only while cuffed)

    © 2026 iBoss21 / LXRCore | lxrcore.com | All Rights Reserved
]]

Config = Config or {}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ LANGUAGE ██████████████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████
Config.Lang = 'en'

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ WHO IS THE LAW ════════════════════════════════════════
-- ████████████████████████████████████████████████████████████████████████████████
Config.Law = {
    jobTypes = { 'leo', 'federal' },   -- from the core registry
    onDutyOnly = true,                 -- powers need duty
    cuffItem = 'handcuffs',            -- nil: no item needed
    seizeIllegal = true,               -- "Seize" takes every item with legal = false into the evidence stash
    disarmOnCuff = true,               -- guns leave the hands through lxr-weapons
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ STATIONS ══════════════════════════════════════════════
-- ████████████████████████████████████████████████████████████████████████████████
-- jobs: which law jobs use this station (duty, armoury, evidence, desk).
Config.Stations = {
    { id = 'valentine',  label = "Valentine Sheriff's Office", jobs = { 'vallaw' }, desk = vector3(-275.89, 809.44, 119.38), armoury = vector3(-272.70, 806.60, 119.38), evidence = vector3(-278.10, 807.90, 119.38), blip = true },
    { id = 'rhodes',     label = "Rhodes Sheriff's Office",    jobs = { 'rholaw' }, desk = vector3(1360.88, -1301.53, 77.77), armoury = vector3(1362.05, -1301.83, 77.77), evidence = vector3(1361.39, -1303.77, 77.77), blip = true },
    { id = 'saintdenis', label = 'Saint Denis Police Department', jobs = { 'sdlaw', 'pinkerton' }, desk = vector3(2501.83, -1309.04, 48.95), armoury = vector3(2507.53, -1301.41, 48.95), evidence = vector3(2494.44, -1313.39, 48.95), blip = true },
    { id = 'blackwater', label = "Blackwater Marshal's Office", jobs = { 'blklaw', 'usmarshal' }, desk = vector3(-760.47, -1269.14, 44.04), armoury = vector3(-768.03, -1266.37, 44.05), evidence = vector3(-761.98, -1272.62, 44.05), blip = true },
    { id = 'strawberry', label = "Strawberry Sheriff's Office", jobs = { 'strlaw' }, desk = vector3(-1810.57, -350.91, 164.66), armoury = vector3(-1812.03, -354.09, 164.65), evidence = vector3(-1807.17, -348.29, 164.66), blip = true },
}

-- the armoury is an lxr-inventory stash per job (stash_job_<job>_armoury); evidence per station
Config.Stash = { armouryPrefix = 'stash_job_', evidencePrefix = 'stash_evidence_' }

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ CUFFS, ESCORT, SEARCH ═════════════════════════════════
-- ████████████████████████████████████████████████████████████████████████████████
Config.Cuffs = {
    distance = 2.5,
    anim = { dict = 'script_re@bear_trap@version_3', name = 'trapper_cutfree', flag = 49 },   -- hands held together (loops)
    cuffedControls = { 0x07CE1E61, 0xF84FA74F, 0xD9D0E1C0, 0x8FFC75D6, 0xD8F73058 }, -- attack, aim, jump, sprint, weapon wheel
    escortOffset = vector3(0.35, 0.85, 0.0),
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ FINES & JAIL ══════════════════════════════════════════
-- ████████████████████████████████████████████████████████████████████████████████
-- 1899: a Valentine justice fined drunkenness $5, assault $10–25, horse theft was prison.
Config.Fines = { min = 0.25, max = 250, account = 'cash', fallbackAccount = 'bank', toSociety = true }

Config.Jail = {
    place = { coords = vector4(3369.56, -723.59, 44.31, 180.0), label = 'Sisika Penitentiary' },   -- the yard
    release = vector4(3331.85, -700.07, 43.09, 0.0),
    minMinutes = 1, maxMinutes = 120,
    workReduces = false,           -- a work loop could shorten sentences (hook: lxr:lawman:jail:tick)
    keepInside = 120.0,            -- metres from the yard before the inmate is walked back
    stripWeapons = true,
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ BOUNTIES ══════════════════════════════════════════════
-- ████████████████████████████████████████████████████████████████████████████████
Config.Bounties = {
    enabled = true,
    min = 5, max = 500,            -- 1899 county rewards ran $25–$500
    payOn = 'jail',                -- paid to the arresting officer / hunter when the name is jailed
    hunterJob = 'bountyhunter',    -- may read the board and claim
    boardAtStations = true,
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ SECURITY ══════════════════════════════════════════════
-- ████████████████████████████████████████████████████████████████████████████████
Config.Security = { rateLimit = { windowMs = 2000, burst = 8 }, maxDistance = 4.0, promptDistance = 2.0 }

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ DEBUG ═════════════════════════════════════════════════
-- ████████████████████████████████████████████████████████████████████████████████
Config.Debug = { printBanner = true, log = true }
