---
name: "Session 2026-07-25 — Flute-gate combat half"
date: "2026-07-25"
tags: [session, combat, flute, companions]
branch: "feature/flute-gate-combat"
commits: []
---

# Session 2026-07-25 — Flute-gate combat half

## Focus

Bite 1 from PM plan: bare fists never hurt monsters; pre-flute weapons/throws
also deal no monster damage (decision 2026-06-21 combat half).

## What I did
*(newest first)*

- 416/416 tests green (`test_flute_combat_gate.gd` + combat box / throwable updates).
- `Hurtbox`: player→enemy damage only if `PlayerController.can_player_hitbox_hurt_monsters`.
- `perform_attack`: melee activates hitbox only when armed + flute; throw damage 0 pre-gate.
- Static rules: `monsters_combat_unlocked`, `can_armed_attack_hurt_monsters`,
  `can_player_hitbox_hurt_monsters` (thrown tools OK post-flute unarmed).
- Ideas inbox marked bare-fists + combat half done.

## Decisions made

- None new; implements locked [[decisions/2026-06-21-companions-and-flute-gate]] combat half.

## Bugs fixed

- Pre-existing: player could damage monsters unarmed / pre-flute (canon break).

## Files touched

**New:** `tests/test_flute_combat_gate.gd`, this journal.

**Modified:** `player_controller.gd`, `hurtbox.gd`, `test_combat_boxes.gd`,
`test_throwable.gd`, `docs/ideas.md`.

## Next session

- **Human F5:** pre-flute swing feels flee-only (not broken); stick+flute still hits.
- Bite 2: stinger Sorceress WAV swap.
- Bite 3: place berries.

## Related

- [[decisions/2026-06-21-companions-and-flute-gate]]
- [[tests/test_flute_gate]] (soothe half)
