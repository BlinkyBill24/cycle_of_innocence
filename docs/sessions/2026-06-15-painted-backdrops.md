---
name: Painted Grok backdrops wired into all zones + playground/fringes split
date: 2026-06-15
branch: feature/painted-backdrops
tags: [session, art, zones, refactor]
---

# 2026-06-15 — Painted backdrops (full re-wire)

User supplied 6 Grok-Imagine painted maps; wired them into the game (full re-wire:
swap backdrop, drop decorative/tile/light layers the painting now provides, keep +
reposition gameplay nodes, author collision). Positions are F5-tunable approximations.

## What I did
- **cottage_ground / cottage_basement**: painted room backdrops (1248x832); dropped
  procedural floors + furniture sprites + runtime light stack; kept spawns/doors/
  stairs/MartaSpot/recontext repositioned; perimeter collision.
- **village_green**: painted village (1280x816); removed tile layer, DuskTint, all
  Prop* building/decor sprites; kept NPC markers, 5 villagers, eavesdrop zones,
  playground transition, Marta door, spawns, dread overlay, HUD/touch/debug; added
  building + perimeter collision. NEW **ChapelDoor -> church_interior** + SpawnFromChurch.
- **church_interior** (NEW scene): portrait church (720x1280); spawn, ExitDoor->village,
  perimeter + pew collision (central aisle walkable). Entered from the village chapel.
- **playground/fringes SPLIT** (was one combined main scene): kept
  `playground_fringes.tscn` as the PLAYGROUND (+main, name/zone_id/village-target
  unchanged) with the full intro/escape + equipment + hideout; new **fringes.tscn**
  (ZoneRoot, zone_id 'fringes') holds the woods (dread zones, Twisted Child + keepsake,
  fringes diggable). Added playground<->fringes transitions + entry markers;
  `ZONE_SCENES += fringes`. Flow: village <- playground -> fringes.

## Notes / flags
- **Style shift**: painted hi-fi maps + 32px pixel player/companions read as mixed —
  user's intended direction (confirmed). Diverges from the locked "32px everything" and
  the flat-lit hybrid rule ([[art/prop-coherence]] room-anchor flag) — these are shipped
  backdrops, not refs, so that's a deliberate art-direction choice.
- All node positions / collision are **first-pass approximations from the images** —
  need an F5 tuning pass (marker alignment, building/tree collision, transition spawns).
- All scenes load + can_instantiate; suite green (881).

## Next
- F5 tuning pass across all zones (positions, collision, transitions, the intro flow
  after the split).
- Texture filtering: painted backdrops use project-default nearest; consider linear if
  camera zoom is added.
