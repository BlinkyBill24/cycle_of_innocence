---
name: Playtest synthesis — June 2026 feel pass
status: in progress (2 of 3–5 sessions)
protocol: "[[plan/playtest-protocol-2026-06]]"
---

# Synthesis (running — do NOT tune from n<3 except defects)

## Sessions
| # | profile | length | valid beats |
|---|---|---|---|
| [[tester-01]] | horror+rpg | ~5 min | 1–2 only |
| [[tester-02]] | horror+rpg | short, native editor play | 1–2; crashed-out at the village transition |

## Defects fixed immediately (bug class, not tuning)
- **Soothe affordance** (t01 Q3): no HOLD hint/progress → `SoothePrompt`
  shipped. t02 confirms the bar works.
- **SoothePrompt hint placement** (t02 Q3): degenerate anchor rect put the
  hint under the HP hearts → explicit bottom-center anchors, verified by
  screenshot. Re-test with tester-03.
- **Village "crash"** (t02 Q6): editor paused on load errors —
  `village_tileset.tres` declared 4 dirt-variant tiles vs the curated
  1-tile texture; 3 out-of-texture tiles errored exactly as the village
  scene loaded. Tres + generator fixed; regression test
  `test_village_scene_loads.gd`. (Desktop CLI run had sailed past it —
  native editor play is the strictest runtime; keep using it for testers.)

## Threshold tracker (needs ≥3 valid sessions)
| Signal | t01 | t02 | t03 | verdict |
|---|---|---|---|---|
| Soothe discovered unprompted | ✗ (pre-fix) | ~ (bar seen, hint hidden) | | pending — affordance now complete |
| "Reacting" vs "timer" | n/a | n/a (neither; no village) | | pending |
| Doom cites world evidence | n/a | n/a | | pending |
| Interface horror = haunted | n/a | n/a | | pending |
| Briar pings noticed | ? | ~ ("bark sometimes"; "does not do much else") | | pending |
| Audio never "messy" | **✗ reggae** | **✗ reggae (same words)** | | **FAILED 2/2 — act** |
| Night worry ≥3 | ✗ (2/5) | ~ (3/5, "reggae breaks immersion") | | borderline — audio confounds it |
| Would keep playing | ✗ | ✗ (crash-driven) | | pending — both no's had defect causes |

## Actions from the failed threshold
- **Audio content sprint promoted to NOW** (human): regenerate
  `playground_tense.ogg` + `playground_danger.ogg` in ACE-Step as one
  composition / stripped mixes ([[mechanics/adaptive-audio]]). Identical
  unprompted "reggae" wording from two independent testers; it also
  confounds the darkness score (t02: night OK *but* music breaks it).
  Nothing else should be tuned until the stems are replaced — audio
  contaminates dread, night, and keep-playing answers.

## Early signals (still await n≥3)
1. First-minutes pacing: t01 "want to see something happening"; t02's best
   moment was an audio shift while exploring. An authored early dread beat
   remains the candidate content fix.
2. Briar reads as cute but passive ("follows, barks sometimes, not much
   else") — two 3/5s. Watch whether the dig assist + quirks surface at all
   in longer sessions before adding telegraphs.
3. Positives held across both: choice agency 5/5 ×2, opening atmosphere
   praised ×2 (same words — the intro is landing).

## Process notes
- Tester sessions are running ~5 min informal, not the protocol's 30–45 —
  beats 3–5 keep going unmeasured. For run 3: session length first.
- Native editor play exposed a resource error a CLI run survived — keep at
  least one native-editor tester per round.
