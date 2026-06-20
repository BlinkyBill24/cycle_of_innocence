---
name: Pick-up-throw verb
date: 2026-06-21
branch: feature/pickup-throw
tags: [session, interaction, combat, throwable, web-safe, physical-verb]
---

# 2026-06-21 — Pick-up-throw (goal item 1)

A loose object Rowan can lift and hurl — Web-safe, no real physics.

## What I built
- `scripts/world/throwable_object.gd` + `scenes/world/throwable_object.tscn`:
  `ThrowableObject` (Node2D, group `throwable`) with states RESTING → CARRIED →
  FLYING → LANDED. The arc is **faked**: a parabola (`arc_height·4t(1-t)`) lerped onto
  the **Visual's y** while a **Shadow stays on the ground** — NOT RigidBody2D gravity.
  Lands then rests (re-liftable) or breaks (`breaks_on_land`).
- **Player hooks** (`player_controller.gd`): `interact` lifts the nearest loose
  object (≤40px, reuses `_facing`); a carried object hovers above Rowan; `interact`
  or `attack` while carrying **hurls it in the facing direction**. Priority:
  carried-throw → soothe → lift → hideout → assist (soothe keeps priority so a
  nearby rock can't steal the signature verb).
- **Bus events**: `GameEvents.throwable_picked_up / thrown / landed`.
- One `playground_rock` placed near Rowan's start for F5 play.

## Item 3 folded in (one combat system, not two)
While airborne the object carries a **player-faction `Hitbox`** (`faction=player`,
`damage=throw_damage`). A monster's `Hurtbox` detects it and routes through
`Faction.hostile(player, enemy)` → `Health.take_damage` — the **exact same path** the
slingshot's `ThrownProjectile` (also a player-faction Hitbox) uses. No second damage
system; the shared path is the Hitbox/Faction collision system itself.

## Tests — suite 326 green, check-brain green
`test_throwable.gd`: pickup sets carried state (+ event); throw travels in the facing
dir and lands; landing emits the land event; a thrown object deals exactly ONE hit to
an enemy Hurtbox/Health via the shared path.

## ⚠ Flag
The goal referenced a "physical-interaction research inbox note" — **no such note
exists** in `docs/research/` (inbox or `done/`). Built from the goal's own spec; if
that note arrives later, run it through the librarian pass against this implementation.
