---
name: Faction-aware hitboxes
date: 2026-06-20
branch: feature/faction-aware-hitboxes
tags: [session, combat, factions, encounters-mercy, plumbing]
---

# 2026-06-20 — Faction-aware hitboxes (Dominated-thrall plumbing)

## Plain summary
When Rowan **Dominates** a monster (Vessel path), the thrall fights for you — but
its attack reused the player-hurting hitbox, so it would (a) ignore other monsters
and (b) still hurt Rowan. Harmless with one enemy on screen; wrong the moment a zone
has two. This pass adds a small **faction tag** so the same lunge can hurt enemies
instead of the player. No new mechanics, no balance changes.

## What I did
- New `scripts/combat/faction.gd` — `Faction` with `player` / `ally` / `enemy`
  constants and a pure `hostile(a, b)` rule: **player + ally are one side, monsters
  the other; a hit only lands across the line.** No friendly fire (`enemy↔enemy`,
  `player↔ally` are safe).
- `Hurtbox` now (1) **self-excludes** any hitbox on its own `CharacterBody2D`, and
  (2) gates damage on `Faction.hostile` instead of the old "any different faction"
  check (which would have let an `ally` thrall hit Rowan).
- A Dominated thrall's `LungeHitbox` is re-tagged **`ally`** on entering the
  Dominated state. Its own hurtbox stays `enemy`, so the thrall is still a normal
  target (player can hit it; other enemies can't) — self-exclusion stops it biting
  itself. Behaviour for the player and normal enemies is unchanged.

## Why this shape (not per-faction layers)
The goal sketched "an enum + a collision layer+mask mapping." The existing combat
already routes **all** hit/hurtboxes through one shared `hit_hurt` layer and filters
by faction in code. Splitting factions across physics layers would mean re-laying
every hitbox/hurtbox node — the opposite of "reuse the existing nodes." So I kept the
shared layer and put the relationship in `Faction.hostile`. Same result, far smaller
blast radius.

## Tests (all four required + more) — suite 308 green, check-brain green
- `test_faction.gd`: the `hostile()` truth table.
- `test_combat_boxes.gd`: thrall(ally)→enemy damages; thrall(ally)→player does NOT;
  player→enemy still damages (regression); enemy→player still damages (regression);
  same-character boxes never self-damage.
- `test_enemy_base.gd`: domination re-tags the lunge `enemy` → `ally`.

## Notes / out of scope (untouched, as scoped)
No multi-enemy zone content, no new enemy types, no damage/aggro/AI retuning,
no Echo/Storm, no day-night, no vision cone, no sprite/anim or art-register work.
The thrall's hurtbox faction was deliberately left `enemy` (changing it would make
enemies able to damage the thrall — a behaviour change beyond plumbing).
