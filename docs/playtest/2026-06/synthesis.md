---
name: Playtest synthesis — June 2026 feel pass
status: in progress (1 of 3–5 sessions)
protocol: "[[plan/playtest-protocol-2026-06]]"
---

# Synthesis (running — do NOT tune from n=1 except defects)

## Sessions
| # | profile | length | valid beats |
|---|---|---|---|
| [[tester-01]] | horror+rpg | ~5 min | 1–2 only (no village, no night, no stage 1) |

## Defects fixed immediately (bug class, not tuning — protocol allows)
- **Soothe affordance** (tester-01 Q3 "broken"): no HOLD hint, no progress
  feedback outside the debug HUD → `SoothePrompt` shipped (hint near a
  spareable monster, recognition bar while holding, hidden in dialogue).
  Re-test with tester-02+.

## Threshold tracker (needs ≥3 valid sessions)
| Signal | t01 | t02 | t03 | verdict |
|---|---|---|---|---|
| Soothe discovered unprompted | ✗ (pre-fix — discount) | | | pending |
| "Reacting" vs "timer" | n/a (5 min) | | | pending |
| Doom cites world evidence | n/a (5 min) | | | pending |
| Interface horror = haunted | n/a (never triggered) | | | pending |
| Briar pings noticed | ? | | | pending |
| Audio never "messy" | **✗ — "reggae" when darkness/terror starts** | | | 1 strike |
| Night worry ≥3 | ✗ (2/5) | | | 1 strike |
| Would keep playing | **✗ — "want to see something happening"** | | | 1 strike |

## Early signals (await confirmation, but already pointed)
1. **Danger/tense stem reads as REGGAE** — content, not mixing. Strongest
   single quote of the session. Feeds next-arc 2 (audio content sprint:
   one composition, stripped mixes) and raises its priority: the current
   ACE-Step danger track may be unusable regardless of crossfade quality.
   *(Human task: regenerate stems; agents don't tune audio feel.)*
2. **First-five-minutes pacing**: "want to see something happening" + dread
   1/5. The slice's scripted dread beat either isn't early enough or didn't
   fire in their path. Candidate fix is CONTENT (an authored early beat —
   fog/wrong-toy/monster glimpse within ~3 min), not knobs. Pairs with
   next-arc 3 (playground recontext authoring) and the demo-arc design
   ([[design/market-positioning]]: the demo must hook before the bell).
3. **Night darkness 2/5** — second independent strike on the darker-dread
   leftover (slice gate said the same). The knob exists (CanvasModulate
   floor with dread). Still waiting for n≥3 per protocol, but this one is
   close to actionable.
4. Positives worth keeping: choice agency 5/5, opening atmosphere praised,
   Briar middling-positive at 3/5 in 5 minutes.

## Process notes
- 5-minute informal sessions produce invalid clock/doom/interface data —
  for testers 02+ enforce the protocol's 30–45 min + the 5 beats, or mark
  answers n/a as here.
- Debug HUD was correctly off; its absence exposed the soothe affordance gap
  the dev never sees. Good trade.
