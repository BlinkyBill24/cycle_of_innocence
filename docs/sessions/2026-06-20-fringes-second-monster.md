---
name: Second monster in fringes (faction demo)
date: 2026-06-20
branch: feature/fringes-second-monster
tags: [session, combat, factions, content, fringes]
---

# 2026-06-20 — Second monster in the fringes (to verify faction hitboxes)

## Why
The faction-hitbox plumbing landed, but you can only *see* a Dominated thrall fight
if there are two monsters — one to Dominate, one for it to attack. The fringes zone
had only one. Added a second.

## What I did
- `scenes/zones/fringes.tscn`: added **TwistedChildTwo** at (250, 70), ~90px from the
  original at (180, 130) — inside the thrall's 140px target search, so a Dominated
  thrall will seek and lunge at it.
- Gave it a **unique `stable_id = twisted_child_02`** (the original keeps the default
  `twisted_child_01`). This matters: the dominated/stilled story flags are keyed by
  `stable_id`, so a duplicate would corrupt that bookkeeping.
- The second monster has no `secret_spot_path` — the keepsake-lead stays the first
  child's beat.

## Test — suite 309 green, check-brain green
`test_enemy_base.gd::test_fringes_zone_has_two_distinct_monsters_to_verify_factions`:
the fringes scene authors exactly two EnemyBase monsters with distinct stable_ids.

## How to verify in-game (for the human)
1. Launch (F5) → you start in the playground (no enemies there).
2. Reach **Vessel** tier: open the debug panel and press **2** (morality +15) ~6×
   until the readout says VESSEL (needs morality > 80).
3. Walk **east** through the fringes transition — both monsters are there.
4. Hold **E (interact)** next to one monster. At Vessel tier the hold becomes
   **Domination**; the recognition bar fills and it turns into your thrall (reddish tint).
5. Watch it lunge at the **other** monster — and note it never damages Rowan. That's
   the faction system working.

## Out of scope (unchanged)
No new enemy types, no AI/aggro/damage retuning, no companions/day-night/vision/art.
Just one more instance of the existing TwistedChild for the demo.
