--[[ ═══════════════════════════════════════════════════════════════════════════
     LXR-LAWMAN — Shared rules: who is the law, what a sentence and a fine may be
     ═══════════════════════════════════════════════════════════════════════════
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

LXRLawman = LXRLawman or {}
local L = LXRLawman

local function typeOf(job)
    if not job or not job.name then return nil end
    if job.type then return job.type end
    local def = LXRShared.Jobs and LXRShared.Jobs[job.name]
    return def and def.type
end

---Is this job record the law (type in Config.Law.jobTypes), on duty when required.
function L.IsLaw(job, ignoreDuty)
    local t = typeOf(job)
    if not t then return false end
    local ok = false
    for _, x in ipairs(Config.Law.jobTypes) do if x == t then ok = true end end
    if not ok then return false end
    if Config.Law.onDutyOnly and not ignoreDuty and not job.onduty then return false end
    return true
end

function L.IsHunter(job) return job and job.name == Config.Bounties.hunterJob end

---The station a job belongs to.
function L.StationFor(jobName)
    for _, s in ipairs(Config.Stations) do for _, j in ipairs(s.jobs) do if j == jobName then return s end end end
    return nil
end
function L.Station(id) for _, s in ipairs(Config.Stations) do if s.id == id then return s end end end

function L.ArmouryStash(jobName) return Config.Stash.armouryPrefix .. jobName .. '_armoury' end
function L.EvidenceStash(stationId) return Config.Stash.evidencePrefix .. stationId end

local function round2(n) return math.floor(n * 100 + 0.5) / 100 end

function L.Fine(n)
    n = tonumber(n)
    if not n or n ~= n or n <= 0 then return nil end
    n = round2(n)
    if n < Config.Fines.min or n > Config.Fines.max then return nil end
    return n
end

function L.Sentence(minutes)
    minutes = math.floor(tonumber(minutes) or 0)
    if minutes < Config.Jail.minMinutes or minutes > Config.Jail.maxMinutes then return nil end
    return minutes
end

function L.Bounty(amount)
    amount = tonumber(amount)
    if not amount or amount ~= amount then return nil end
    amount = round2(amount)
    if amount < Config.Bounties.min or amount > Config.Bounties.max then return nil end
    return amount
end

---Items the law seizes from a satchel: illegal ones (legal = false).
function L.Seizable(items)
    local out = {}
    for slot, it in pairs(items or {}) do
        local def = it and LXRShared.Items[it.name]
        if def and def.legal == false then out[#out + 1] = { slot = tonumber(slot), name = it.name, amount = it.amount, info = it.info } end
    end
    table.sort(out, function(a, b) return a.slot < b.slot end)
    return out
end
