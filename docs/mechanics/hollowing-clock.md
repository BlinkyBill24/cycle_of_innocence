---
name: The Hollowing Clock (Doom Escalation)
date: 2026-06-10
tags: [feature, mechanics, narrative, horror, world-state]
status: implemented
related_decisions: "[[decisions/2026-06-10-new-features-and-ai-setup]]"
---

# The Hollowing Clock — Doom Escalation System

## What it does
Mechanizes the story bible's "delayed alarm" beat: the village does not yet know the ritual failed. A hidden **Hollowing meter** advances in discrete stages as the Hunger and then the village realize the offering escaped. Each stage permanently worsens the world: emergency rituals, more monsters, corrupted zones, changed NPC behavior. Inspired by World of Horror's doom clock, but **event-driven, not real-time** — stages advance on story beats and player actions, never on a wall-clock timer (mobile-friendly, no anxiety treadmill).

## Why it fits (prior art check, R3b)
- [[story/bible]] explicitly describes the escalation ("villagers grow panicked and begin sacrificing more children in additional emergency rituals") but no doc mechanized it.
- [[design/game-features]] §7 says "time pressure is narrative (the next Hollowing approaches) rather than strict timer" — this doc is that system, made concrete.
- Interacts with [[mechanics/encounters-mercy]] (escalation can undo Stilled states) and [[mechanics/day-night-hideout]] (night danger scales with stage).

## Stages (v1: five)
| Stage | Name | World state |
|---|---|---|
| 0 | The Quiet | Post-escape. Village believes ritual succeeded. Safest the game will ever be. |
| 1 | The Doubt | Hunger stirs; crops twist wrong. Searchers on roads at night. First whispers. |
| 2 | The Alarm | Village knows. Wardens hunt Rowan. First emergency ritual → a new monster appears *that the player could not save*. |
| 3 | The Frenzy | Multiple emergency rituals. New corrupted zones; some NPCs vanish (their children taken). Stilled monsters can re-aggro. |
| 4 | The Hollowing | Endgame state. The next great ritual is imminent; ending branches lock in. |

## Advancement rules
- Primary: **story milestones** (revelations, zone firsts, age-ups).
- Secondary: **player noise** — being seen by villagers/Wardens, loud kills near the village, using high-corruption powers add hidden Alarm points; enough points pulls the next stage early.
- Mercy/stealth playstyles delay stages; ruthless/loud playstyles accelerate them. The clock is the world's response to *who Rowan is becoming*.
- Never advances while idle or during care/hideout scenes. No timer UI — the player reads the world (posters, patrols, church bells, NPC dialogue), with companion behavior as the early-warning system (Echo refuses to fly toward the village a stage before the player learns why).

## Consequences per stage
- Spawn tables and patrol routes per zone keyed to stage.
- Dialogue: `hollowing_stage` variable gates dialogue everywhere.
- Each stage adds one **irreversible loss** (an NPC, a safe path, a child) — the cost of delay is shown, not told.
- Endings read peak-stage and stage-at-finale flags ([[story/endings]]: Frenzy reached + low bonds feeds The Failure).

## Data model
- `HollowingClock` autoload (or merged into a WorldState autoload): `stage: int`, `alarm_points: int`, signals `stage_advanced(stage)`.
- GameEvents already has `horror_stinger` / zone signals to react to.
- Save: stage + points + per-stage loss flags.

## Edge cases
- NG+ starts at stage 0 but with `$knew_it_was_coming` echoes (NPCs uneasy around Rowan).
- Stage must never advance mid-dialogue or mid-hideout; queue and fire on zone transition.
- Anti-frustration: stage 2+ always leaves at least one safe route to the current objective.

## Implementation notes (2026-06-11, branch feature/hollowing-clock)
- `HollowingClock` autoload: `stage` (QUIET→HOLLOWING), milestones (revelations, age-ups — once per id) + Alarm points (kill +25, betrayal +40, domination +35, stilling **−20**; 100 = one stage early, overflow carries).
- Queue rule enforced: never advances mid-dialogue (`exploration_paused`) or inside the hideout (`hideout_entered/exited` on GameEvents); fires on resume.
- Stage feedback: distant bell toll (`hollowing_bell.wav`), Briar whimper (early warning), +12 dread, `horror_stinger`. No UI — debug label shows stage during dev (key H = +1 stage).
- Consequences live now: **Frenzy (3) un-stills every Stilled monster** (no betrayal cost — the Hunger's doing; `spared_` history kept); **Alarm (2) spawns the emergency-ritual child** in the deep fringes (`spareable=false` — the player could not save it); night dread floor 20 + 5×stage; enemy detection radius ×(1 + 0.1×stage).
- Persisted in saves (stage, points, pending, consumed milestones). Dialogue can gate on `HollowingClock.stage` directly.

## Related
- [[story/bible]] · [[story/endings]] · [[mechanics/encounters-mercy]] · [[mechanics/day-night-hideout]] · [[mechanics/horror-and-dread]]
