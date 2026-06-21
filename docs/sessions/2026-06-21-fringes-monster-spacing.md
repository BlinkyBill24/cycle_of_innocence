---
name: Space the fringes monsters apart
date: 2026-06-21
branch: fix/fringes-monster-spacing
tags: [session, monster, fringes, playtest, mercy, soothe]
---

# 2026-06-21 — Space the two fringes monsters apart (playtest)

## The report
The two fringes monsters spawned ~90px apart, so both aggro and attack at once.
Soothing leaves Rowan defenseless (no i-frames), so a double mobbing makes it
impossible to hold a soothe — and therefore impossible to reach the fully-soothed
(Stilled/allied) state.

## The fix
Moved them well apart (north/south) so the player can face one at a time:
- TwistedChild: (180, 130) → **(180, -150)**
- TwistedChildTwo: (250, 70) → **(300, 210)**
- Gap ~379px — **> 2× the 110px detection radius**, so standing near one keeps the
  player outside the other's notice. Approach, soothe, then handle the second.

No mechanic/balance change — only spawn positions. (Soothe key is still the playground
rabbit's `dug_playground_buried_toy`, dug safely in the monster-free playground.)

## Trade-off note
This favors soothe-ability over the auto faction-demo (a Dominated thrall only seeks
another monster within 140px, and they now start ~379px apart). The faction MECHANIC is
unit-tested and unchanged; in play a thrall can still fight another monster once they've
converged on Rowan in a chase. Net: better for the Empath/soothe path, which is what the
player was blocked on.

## Test — suite 347 green, check-brain green
`test_enemy_base.gd::test_fringes_monsters_spawn_far_enough_to_engage_one_at_a_time`:
the two fringes monsters spawn > 220px apart (locks the spacing against regression).
