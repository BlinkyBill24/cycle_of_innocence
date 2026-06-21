---
name: Fix the fringes soothe key (cross-zone bug)
date: 2026-06-21
branch: fix/fringes-soothe-key
tags: [session, mercy, soothe, fringes, playtest, legibility]
---

# 2026-06-21 — Fringes monsters were un-soothable (wrong-zone key)

## The report
"I dug both fringes spots but soothing still says 'something is missing.'"

## Root cause (a content bug, not the player)
A monster only fully soothes once you've dug ITS key (`soothe_key_flag`). The fringes
TwistedChildren used the script DEFAULT `dug_playground_buried_toy` — the **playground**
rabbit — a leftover from when the monster lived in the playground. The two *fringes* digs
the player did (shoe = `dug_fringes_buried_memory`, duck = `dug_stilled_child_keepsake`)
never set that flag, so the soothe always plateaued at 60. The key was in the wrong zone,
with no in-zone way to satisfy it.

## The fix
- Both fringes monsters now key off the **in-zone shoe dig**:
  `soothe_key_flag = dug_fringes_buried_memory`. (The player already dug it — so this
  unblocks existing saves on reload.)
- Split the glance hint from the lead target: new `@export soothe_key_spot_path` is where
  the **glance points** (the key dig = the shoe); `secret_spot_path` stays where a Stilled
  child **leads** afterward (the duck). Both monsters now glance at the shoe (previously
  the 2nd monster gave no hint at all, and the 1st pointed at the duck — the wrong dig).
- `_update_glance` uses `soothe_key_spot_path` (fallback `secret_spot_path`).

No balance/mechanic change — only which dig is the key + where the hint points.

## Test — suite 348 green, check-brain green
`test_enemy_base.gd::test_fringes_monster_soothe_key_is_diggable_in_the_same_zone`:
every fringes monster's `soothe_key_flag` corresponds to a diggable present in the fringes
scene (no cross-zone key).

## For the player
On the updated build: dig the **child's shoe** in the fringes (the monster glances toward
it when the soothe stalls), then the soothe fills all the way and the monster calms (and
glows). Your existing save already has that dig, so it should work on reload.
