# Changelog

## 3.0.0 — 2026-09-19
* The record book: every fine, sentence and seizure is written down by itself; the desk shows open warrants (served by a jailing or by hand) and looks anyone up by name or id, with notes and warrants the law writes. A fine the citizen cannot pay is written as owed and settled at any station desk (`Settle your fines`). `Config.Records`, exports `Record / OpenWarrants / RecordsOf`, event `lxr:lawman:warrant`.
* Fix: `LXRCore.PlayerData` stays current — the core object comes back as a copy, so cash, job and metadata never changed after login in this resource. It now listens to `lxr:client:data` / `lxr:client:unloaded` and refreshes its copy.
* LXRCore v3 release line: every resource ships as 3.0.0 from here (the entries below are the road to it).

## 3.0.0 — 2026-09-18

Rebuilt on the LXRCore v3 native API (repository renamed from lxr-policejob). Nothing of the earlier build remains; station positions were kept as data.

* Every registry law job: duty, cuffs, escort, search, seizure, fines to the society book, Sisika sentences, release
* Bounty board with posting, pulling and pay-on-jail; hunters turn names in
* Station desk page on the LXR UI Kit; armoury and evidence stashes; backup through lxr-dispatch
* Locales EN / KA, offline tests
