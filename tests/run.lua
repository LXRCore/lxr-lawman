--[[ ═══════════════════════════════════════════════════════════════════════════
     LXR-LAWMAN — Offline tests: who is the law, stations, amounts, locale parity
     Requires a sibling checkout of lxr-core (../lxr-core).
     Usage (from the lxr-lawman folder):  lua tests/run.lua [--mock out.js en|ka]
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

local CORE = os.getenv('LXR_CORE_PATH') or '../lxr-core'
package.path = CORE .. '/?.lua;' .. package.path
local ok = pcall(function() require('tests.lib.fxshim') end)
if not ok then print('lxr-core shim not found at ' .. CORE .. ' (set LXR_CORE_PATH)') os.exit(2) end
local Shim = require('tests.lib.fxshim')

for _, f in ipairs({ 'shared/main.lua', 'shared/locale.lua', 'locales/en.lua', 'config.lua', 'shared/catalog.lua', 'shared/items.lua', 'shared/prices.lua', 'shared/jobs.lua' }) do Shim.load(CORE .. '/' .. f) end
Config = nil
Locale = nil
Shim.load('shared/locale.lua')
Shim.load('locales/en.lua')
Shim.load('locales/ka.lua')
Shim.load('config.lua')
Shim.load('shared/rules.lua')
local L = LXRLawman

local passed, failed = 0, 0
local function test(name, fn)
    local okT, err = xpcall(fn, debug.traceback)
    if okT then passed = passed + 1 print('  ^ ok   ' .. name) else failed = failed + 1 print('  x FAIL ' .. name .. '\n' .. err) end
end
local function eq(a, b, msg) if a ~= b then error((msg or 'eq') .. ': expected ' .. tostring(b) .. ' got ' .. tostring(a), 2) end end

print('lxr-lawman offline tests')

test('every station names real law jobs and every law job of a town has a station', function()
    for _, s in ipairs(Config.Stations) do
        assert(s.desk and s.armoury and s.evidence and s.label, s.id)
        for _, j in ipairs(s.jobs) do local d = LXRShared.Jobs[j] assert(d and (d.type == 'leo' or d.type == 'federal'), s.id .. ' job ' .. j) end
    end
    assert(L.StationFor('vallaw').id == 'valentine')
    assert(L.StationFor('valdoc') == nil)
    assert(LXRShared.Items[Config.Law.cuffItem], 'cuff item in the catalog')
    assert(LXRShared.Jobs[Config.Bounties.hunterJob], 'hunter job exists')
end)

test('who is the law', function()
    assert(L.IsLaw({ name = 'vallaw', onduty = true }))
    assert(not L.IsLaw({ name = 'vallaw', onduty = false }))
    assert(L.IsLaw({ name = 'vallaw', onduty = false }, true), 'ignoreDuty')
    assert(L.IsLaw({ name = 'usmarshal', onduty = true }))
    assert(not L.IsLaw({ name = 'valdoc', onduty = true }))
    assert(L.IsHunter({ name = 'bountyhunter' }))
    eq(L.ArmouryStash('vallaw'), 'stash_job_vallaw_armoury')
    eq(L.EvidenceStash('valentine'), 'stash_evidence_valentine')
end)

test('lawful amounts', function()
    eq(L.Fine(5), 5) eq(L.Fine('12.345'), 12.35) eq(L.Fine(0), nil) eq(L.Fine(9999), nil) eq(L.Fine('x'), nil)
    eq(L.Sentence(10), 10) eq(L.Sentence(0), nil) eq(L.Sentence(999), nil) eq(L.Sentence('7.9'), 7)
    eq(L.Bounty(25), 25) eq(L.Bounty(1), nil) eq(L.Bounty(500), 500) eq(L.Bounty(501), nil)
end)

test('seizable items are the illegal ones', function()
    local items = { [1] = { name = 'bread', amount = 2 }, [2] = { name = 'lockpick', amount = 1 }, [5] = { name = 'weapon_shotgun_sawedoff', amount = 1, info = { serie = 'x' } } }
    local s = L.Seizable(items)
    eq(#s, 2) eq(s[1].name, 'lockpick') eq(s[2].slot, 5)
end)

test('locale parity', function()
    local en, ka = Locale.Bundles.en, Locale.Bundles.ka
    local missing = {}
    for k in pairs(en) do if ka[k] == nil then missing[#missing + 1] = k end end
    eq(#missing, 0, 'ka missing: ' .. table.concat(missing, ', '))
end)

print(('%d passed, %d failed'):format(passed, failed))

if arg and arg[1] == '--mock' and arg[2] then
    Config.Lang = arg[3] or 'en'
    local data = {
        station = { id = 'valentine', label = "Valentine Sheriff's Office" }, job = { name = 'vallaw', label = "Valentine Sheriff's Office", grade = 'Deputy', onduty = true },
        onDuty = { { name = 'Sadie Adler', job = 'vallaw', grade = 'Deputy' }, { name = 'Archibald MacGregor', job = 'vallaw', grade = 'Sheriff' } },
        bounties = { { id = 3, citizenid = 'LXR1001', name = 'Micah Bell', amount = 250, reason = 'Murder at Strawberry', posted_by = 'Archibald MacGregor', created_at = '2026-09-17 12:00:00' }, { id = 2, citizenid = 'LXR1044', name = 'Sean MacGuire', amount = 40, reason = 'Horse theft', posted_by = 'Sadie Adler', created_at = '2026-09-16 18:30:00' } },
        canPost = true, limits = { bountyMin = 5, bountyMax = 500, fineMin = 0.25, fineMax = 250, jailMax = 120 },
    }
    local f = assert(io.open(arg[2], 'w'))
    f:write('window.__LXR_MOCK__ = ' .. json.encode({ action = 'open', data = data, locale = Lang.bundle(), lang = Config.Lang, brand = { name = 'The Land of Wolves', theme = 'night' } }) .. ';\n')
    f:close()
    print('mock written to ' .. arg[2])
end
os.exit(failed == 0 and 0 or 1)
