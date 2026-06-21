---
name: Throwables per zone (playtest fix)
date: 2026-06-21
branch: fix/throwables-per-zone
tags: [session, throwable, zones, playtest, fix]
---

# 2026-06-21 — A loose object in each play zone

## The report
"I can pick up the stone in the playground, but it's gone when I reach the village; it
respawns at the playground. I can't use it in another area."

## Diagnosis (not a carry bug — a placement gap)
A throwable is a **world object** that lives in its zone's scene. Crossing zones reloads
the whole scene, so the carried rock (a node in the *old* scene) is freed and the player
arrives empty-handed — the Zelda-pot model (objects belong to their room). The actual gap:
I'd only placed a throwable in the **playground**, so there was nothing to throw in the
village (exactly where you'd want one, to throw at Marta) or the fringes (the monsters).

## The fix
Placed a loose stone in each play zone:
- `village_green.tscn` → **VillageStone** (`village_stone`) near Marta — now you can throw
  at her right there.
- `fringes.tscn` → **FringesStone** (`fringes_stone`) on the path to the monsters — for the
  throw-at-monster / faction demo.
- (Playground already had `playground_rock`.)

Did NOT add cross-zone carry persistence — world objects staying local is the intended
model (and simpler/less surprising than a rock that follows you between rooms). If you'd
rather carry one object across a threshold, that's a separate, heavier feature — flag it.

## Test — suite 338 green, check-brain green
`test_throwable.gd::test_each_play_zone_authors_a_throwable`: every play zone
(playground/village/fringes) authors a throwable instance.
