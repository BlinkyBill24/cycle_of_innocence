---
name: Weapon combat wiring (EQUIP + THROW)
date: 2026-06-20
branch: feature/weapon-combat
tags: [session, combat, items, wiring-pass]
---

# 2026-06-20 — Weapon combat (Wiring & Audibility pass, item 1)

## What I did
Wired the existing weapon items (which were `use_kind=NONE`) into combat. No new
exotic systems — reuses the attack hitbox, facing, and the bag-tap → `Inventory.use`
path (already touch-capable).

- **`ItemDef`**: `UseKind` += `EQUIP` (2), `THROW` (3); new `ammo_id` field.
- **`PlayerData`**: `equipped_weapon: StringName` + save/load/reset.
- **`Inventory.use`**: EQUIP/THROW → equip the weapon (toggle; never consumed —
  weapons are reusable).
- **`player_controller`**: `perform_attack` reads the equipped weapon — EQUIP →
  the existing melee swing; THROW → `_perform_throw` (spawns `ThrownProjectile`
  in facing, spends one ammo; blocked with a dry click at 0 ammo). Testable
  statics `attack_is_throw(def)` + `consume_throw_ammo(ammo_id)`.
- **`thrown_projectile.tscn/.gd`**: a moving player-faction `Hitbox` (layer 32),
  frees on hit/timeout — Web-safe Area2D motion.
- **`.tres`**: stick → EQUIP; slingshot → THROW + `ammo_id=sling_stones`.

## Tests
- `test_weapon_combat.gd` (8): equip sets weapon + not consumed; equip toggles
  off; stick swings / slingshot throws; throw decrements a stone; throw blocked at
  0 / with no ammo id; equipped weapon survives save/load.
- Updated `test_item_content.gd` (`test_weapons_are_inert_for_now` →
  `test_weapons_are_wired_for_combat`) — the old test asserted the now-wired state.
- Suite **288 green**; check-brain green. The projectile spawn + swing visuals are
  F5 checks (agents runtime-blind).

## Notes
- Damage parity with the melee hitbox (1) for now; gear stat-weighting is the
  future [[mechanics/equipment]] pass (not this wiring pass).
