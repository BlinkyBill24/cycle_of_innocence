---
name: Hollow House micro-quest — playable loop (key-gate hybrid)
date: 2026-06-19
branch: feature/hollow-house-microquest
tags: [session, quest, hollow-house, companions, inventory, secrets]
---

# 2026-06-19 — Hollow House micro-quest

## What I did
Turned the (built but **unreachable**) `hollow_house.tscn` into a playable
dig-up-key micro-quest, end-to-end. At the design fork I surfaced that the
goal's key-hunt reversed a `[verified]` "knowledge-gated, not a key-hunt"
decision in [[design/hollow-house-quest]]; the human chose **HYBRID** + a
**village_green** entrance. Decision: [[decisions/2026-06-19-hollow-house-key-gate-hybrid]].

- **Reachability**: added `HollowHouseDoor` (`DoorTransition`) off the
  lower-right cottage `BldCotR` in `village_green.tscn` (+ a graybox doorway
  Polygon2D + clue glint, since the painting has no door there) +
  `spawn_from_hollow_house` return marker; repointed the hall `ExitDoor` →
  `village_green`. *(First tried `BldCotL`; that spot is garden plots in the
  painting, not a house — moved to the lower-right cottage per playtest.)*
- **Key gate on `DoorTransition`**: `unlock_item_id`, persistent `unlock_flag`,
  `consume_key_on_unlock`, and pure static `compute_locked()` / instance
  `is_locked()` / `_apply_unlock()` (records the flag, spends the key via
  `Inventory.use` so non-discardable keys still consume).
- **Buried key**: repurposed the hall dig spot → `BuriedKey` `DiggableSpot`
  (`dig_item=&"hollow_key"`); Briar's existing scent-growl/seek targets it.
  `HollowHouseQuest.seek_spot_path` now points at it.
- **Back nook**: new `scenes/zones/hollow_house_back.tscn` (`InteriorRoot`,
  `dread_baseline 30`) holding the ledger + a child's-primer clue prop.
- **`SearchableClue`** (new `scripts/world/searchable_clue.gd`): INTERACT
  one-shot that writes a witnessed Journal entry, optionally plays a balloon,
  and (for the book) sets `hollow_book_read` + calls `HollowHouseQuest.try_fire`.
- **`HollowHouseQuest` refactor**: dropped the in-scene book-diggable wiring;
  added a static, cross-scene `try_fire(rev, prefix, threshold, read_flag)` that
  fires the recontext beat only when the book is read **and** ≥2 `sign_hollow_*`
  DOOM signs are witnessed (either order). The hall node is the safety-net.
- **Asset**: `hollow_key` ItemDef ("Tarnished Key", KEY, consumed) + a PixelLab
  sprite (low top-down, 32px, transparent) — `assets/sprites/items/hollow_key.png`.
- **Tests**: `tests/test_hollow_house.gd` now 25 (key-gate logic, buried-key
  yield, book-search-once, recontext gating + idempotency, full-path smoke, two
  scene-wiring smokes). **Suite 275 green; check-brain green.**

## Exit criteria — status
`village_green → hollow_house door → Briar points → dig hollow_key → inner door
unlocks (key consumed) → book read writes one LORE entry + fires recontext when
doom-gate met → exit → village_green @ spawn_from_hollow_house`. Logic verified
by tests; **traversal/feel is the human F5 check** (agents are runtime-blind).

## Notes / for next time
- **F5 to verify**: the village→house→nook→back walk, Briar pointing at the
  buried key, locked-door float legibility, stinger/dread timing on the read.
- Pre-existing (not mine): zone smoke tests log `Node not found: "Ground"/
  "DuskTint"` + `set_cell on null` for `village_green.gd`/`playground_fringes.gd`
  — stale node refs in those zone scripts. Logged to [[ideas]] as a cleanup.
- `gated_door.gd` is now unused by any scene (kept the file; flagged in the
  decision). Could be deleted once we're sure no other slice wants it.
