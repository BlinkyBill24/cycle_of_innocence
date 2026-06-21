---
name: Forage spots persist (no duplicate pickups)
date: 2026-06-21
branch: fix/forage-persist
tags: [session, inventory, forage, persistence, playtest, bugfix]
---

# 2026-06-21 — Forage pickups are one-shot for good (no duplicates)

## The report (screenshot 16.png)
The satchel had TWO slingshots, two stone stacks, two sticks.

## Cause
`ForageSpot.granted` was runtime-only, so re-entering the playground (or reloading a
save that already held the items) reset it and the spot re-foraged — duplicate slots.
Only the flute was persisted (via its `grants_flag`); the weapons/stones/stick weren't.

## The fix
`ForageSpot` now persists a one-shot flag — `once_flag` (override) or `foraged_<node
name>` (auto; names are unique per scene) — set on grant, checked on `_ready`. Once
foraged, the spot is inert on every revisit and across save/load. Generic for ALL forage
spots; no per-scene edits needed (the existing nodes have unique names).

## Tests — suite 367 green, check-brain green
`test_item_placement.gd`: foraging persists a one-shot flag; an already-foraged spot is
inert on revisit (won't re-grant) — plus the existing one-shot/placement tests.

## ⚠ Note — existing saves
This PREVENTS new duplicates; it does not remove dupes already in a save. A debug reset
(key 0) or a fresh game clears them. (No save-migration/dedup added — out of scope.)
