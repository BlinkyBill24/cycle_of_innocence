---
name: Monster-glance cue (stall hint toward the buried key)
date: 2026-06-20
branch: feature/monster-glance
tags: [session, encounters-mercy, horror, wiring-pass]
---

# 2026-06-20 — Monster-glance cue (Wiring & Audibility pass, nice-to-have)

## What I did
When the generic lullaby stalls at the plateau (recognition 60, no key yet), the
child monster now **briefly turns toward its buried key** — a wordless "look
there" so the stall reads as "find its key", not a broken verb. No UI, builds on
the existing soothe/stall state.

- **`EnemyBase`**: a glance window (`GLANCE_SECONDS`/`GLANCE_COOLDOWN`) — while
  being soothed and stalled, `_update_glance` aims `_facing` at the `secret_spot`
  so the existing `_update_animation` shows the look. Pure, testable
  `should_glance_at_secret(recognition, plateau, stilled, has_key, has_secret)`.

## Tests
`test_monster_glance.gd` (2): the pure rule (only stalls with no key, not Stilled,
a secret to point at); a stalled monster turns east toward a key placed to its
east. Suite **282 green**; check-brain green. The on-screen turn is an F5 check.

## Notes
- Minimal, as the goal asked (skip-if-risky): reuses `secret_spot_path` (the same
  spot the Stilled child later leads to) + the existing facing/anim path; no new
  template.
