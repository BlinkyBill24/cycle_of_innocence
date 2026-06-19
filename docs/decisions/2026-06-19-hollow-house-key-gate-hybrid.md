---
name: Hollow House inner gate — key-item hybrid
date: 2026-06-19
tags: [decision, quest, hollow-house, companions, secrets]
status: accepted
branch: feature/hollow-house-microquest
related: "[[design/hollow-house-quest]] · [[mechanics/companion-pointer]] · [[mechanics/inventory]] · [[mechanics/zone-recontextualization]] · [[decisions/2026-06-13-next-phase-hollow-house-slice]]"
---

# Decision — Hollow House inner gate goes key-item (hybrid)

The pass-1 Hollow House slice ([[design/hollow-house-quest]], built
2026-06-13) gated the inner room with a **stuck door Briar scratches open**
(`GatedDoor` → its paired `DiggableSpot` reveal) and kept the whole quest
**knowledge-gated** (the recontext beat fires on *book found + ≥2 doom-signals*,
never an inventory check). That doc explicitly argued **against** a key-hunt
("whose house would be like that?", `[verified 2026-06-13]`).

A `/goal` on 2026-06-19 asked to wire the (still unreachable) house into the
world as a **dig-up-key** micro-quest: buried key → key-gated inner door →
separate back-nook → hidden book. That reverses the "not a key-hunt" line.

## Decision: HYBRID (chosen by the human at the fork)

Keep the *mechanical* key loop the goal wants, but keep the *narrative payoff*
knowledge-gated:

- **Reachability (the real gap).** The house was referenced by nothing but its
  own quest script. Add the entrance off `village_green` (the **lower-right
  cottage `BldCotR`**, near where the player arrives from the playground — moved
  there 2026-06-19 after the first spot, `BldCotL`, turned out to be garden
  plots in the painting, not a house) + a `spawn_from_hollow_house` return
  marker; repoint the hall `ExitDoor` → `village_green`. A graybox doorway
  Polygon2D + clue glint marks it (the painting has no door there yet). *Soft
  lore overlap to revisit: `BldCotR` also carries the `marker_house_pieter`
  nav marker — fine for the graybox, flag for the art/lore pass.*
- **Key gate.** `DoorTransition` gains `unlock_item_id` + a persistent
  `unlock_flag` + `consume_key_on_unlock`, and a pure static `compute_locked()`.
  A buried-key `DiggableSpot` (`dig_item=&"hollow_key"`) in the hall feeds it;
  Briar's existing scent-growl/seek targets it (it is just a `diggable`).
  Passing the gate records the flag and **spends** the key, so re-entry stays
  open after the key is gone (survives save/load).
- **Book stays the lottery-ledger revelation, in a back-nook scene**
  (`hollow_house_back.tscn`), read via a new `SearchableClue` INTERACT one-shot.
  Reading it writes the witnessed LORE entry **and** calls
  `HollowHouseQuest.try_fire`, which still requires **≥2 `sign_hollow_*` DOOM
  signs** before the recontext beat (unlock + stinger + dread spike + DOOM
  entry) lands. The knowledge gate is preserved; the key only gates *access*.
- **Cross-scene completion.** Because the book lives in a separate scene,
  `HollowHouseQuest` (in the hall) became the safety-net watcher: it re-runs
  `try_fire` on every new sign, so reading-the-book-then-seeing-more still
  completes — either order, nothing missable. The recontext node-swap
  (`ZoneRecontext`, `RecontextDrawing` moved to the hall) reframes the space
  when the player steps back out.

## Superseded / removed
- `GatedDoor` node (script `scripts/world/gated_door.gd` left in tree, now
  unused by any scene) — replaced by the key-gated `DoorTransition` + a solid
  door-leaf `StaticBody2D`.
- The hall `Ledger` `DiggableSpot` and its `FearEmitter`/`DeepDread` (right
  room) — the book moved to the nook; the nook carries the dread via its
  `InteriorRoot.dread_baseline`. `fear_emitter.gd` stays (its proximity curve is
  still unit-tested; no node instances it yet).

## Voice / art (deferred)
Draft content lines (`locked_reason`, dig lore, the child's-primer clue prop)
are placeholders for a later voice pass. Interior art stays graybox per
[[decisions/2026-06-14-interior-art-pass]].

## Tests
`tests/test_hollow_house.gd` (25): `compute_locked`/`is_locked` with & without
key, `_apply_unlock` consumes + persists, `DiggableSpot` yields `hollow_key`,
`SearchableClue` writes LORE exactly once, `try_fire` gating (book-read AND doom
threshold, idempotent), a full-path logic smoke, and scene-wiring smokes for
both halls. Suite 275 green; check-brain green.

> F5 checks (agents are runtime-blind): the village→house→nook→back traversal,
> Briar pointing at the buried key, the locked-door float reading, and the
> stinger/dread timing on the ledger read.
