---
name: Item world-placement (berries + weapons)
date: 2026-06-20
branch: feature/item-placement
tags: [session, items, placement, wiring-pass]
---

# 2026-06-20 — Item placement (Wiring & Audibility pass, item 4)

## What I did
Berries + weapons existed as items+art but weren't placed anywhere, so they could
never be found. Added them as `ForageSpot` pickups (the existing one-shot pickup
pattern — `DriedMeatForage` was the model) in `playground_fringes.tscn`:
- `BerryForage` → `forest_berries` ×2
- `StickForage` → `sturdy_stick`
- `SlingshotForage` → `slingshot`
- `StonesForage` → `sling_stones` ×5 (ammo for the slingshot)

No new mechanics — reuses `ForageSpot` (touches only `Inventory.add`). Dig-up items
(bone, locket) were already placed; left untouched.

## Tests
`test_item_placement.gd` (2): a `ForageSpot.grant` lands the item in the satchel
(one-shot); the playground scene actually places berries + all three weapon items.
Suite **282 green**; check-brain green.

## Notes
- Positions are a first pass (open spots in the east fringe) — exact placement is
  an editor/playtest tuning pass, not this wiring pass.
