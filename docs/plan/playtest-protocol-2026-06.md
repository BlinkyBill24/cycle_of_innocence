---
name: Playtest Protocol — Feel Pass (June 2026)
date: 2026-06-12
tags: [playtest, protocol, plan]
status: active
related: "[[slice-implementation-roadmap]] · [[mechanics/hollowing-clock]] · [[mechanics/interface-horror]] · [[mechanics/village-life]] · [[mechanics/adaptive-audio]]"
---

# Playtest Protocol — Structured Feel Pass

**Purpose**: first post-systems playtest. Every greenlit mechanic is built;
this pass decides what gets TUNED before any new content arc. It must answer
the open lookback questions the docs already pose — not collect generic
feedback.

## Setup

- **Build**: web export (`exports/web/`), served via NAS (`reference_nas_deploy`)
  or `tools/serve_web.py`; itch private page when ready. Test Firefox/Chromium
  first (Safari WebGL2 quirks).
- **Testers**: 3–5 external (not the developer). Mix: ≥1 who plays
  horror/RPGs, ≥1 who doesn't. Solo sessions, not group.
- **Session**: 30–45 min play + 10 min debrief. Fresh save. Tell them ONLY:
  "top-down adventure, arrows/WASD move, Space attacks, E interacts, hold E
  near a calm moment to soothe." Nothing about mercy, the clock, or the story.
- **Recording**: screen capture if possible; otherwise silent observation
  notes. Never coach mid-session — a stuck tester is data.
- **Debug HUD**: OFF for testers (`show_debug_label = false`). The doom must
  be read from the world, not the corner.

## What each session must touch (nudge only if a beat hasn't happened by ~min 25)

1. Name entry → escape → **The Food choice** with Briar.
2. First monster encounter — do they discover **soothe** unprompted? How long
   do they attack first?
3. Village visit: walk among villagers, ≥1 **eavesdrop**, get noticed once.
4. **Night + hideout** once (rest, re-anchor).
5. Reach **Hollowing stage 1** (the first bell + Briar whimper) — ideally the
   session ENDS shortly after this beat (it's the planned demo ending).

> **Short-session doom shortcut**: the debug keybinds work even with the
> debug label hidden. For sessions that can't run 30–45 min, instruct the
> tester: *"around minute 10–15, when you're outdoors and not in a
> conversation, press `H` once and keep playing."* `H` queues one Hollowing
> stage; the bell/whimper fire at the next clean moment (cross a zone gate
> if nothing happens within ~30 s). The probe stays blind — the tester
> doesn't know what `H` did, so question 2 (doom 1–10 + evidence) remains
> valid. `T` advances time of day if the darkness probe needs night.
> Don't reveal either key's effect until after the debrief.

## Silent observation checklist (live notes per tester)

| Watch for | Feeds |
|---|---|
| Attack-first duration before first soothe attempt; do they find soothe at all without being told | [[mechanics/encounters-mercy]] discovery cues (plateau glance idea) |
| Reaction at the stage-1 bell/whimper — do they LOOK for the source, do they verbalize dread or confusion | [[mechanics/hollowing-clock]] doom legibility (bells/posters/journal roadmap) |
| During an interface-pressure spike (input lag/eaten press): do they say "broken" or "creepy"? Do they retry the same input rapidly (frustration tell)? | [[mechanics/interface-horror]] frustration ceiling |
| Do they notice Briar's bark/growl pings at all (head turn, course change) | bark visibility (slice-gate leftover) |
| Villager suspicion: do they realize they're being watched/noticed; do they change behavior | [[mechanics/village-life]] suspicion→alarm tuning |
| Music: any comment on shifts; any moment where audio fights itself | [[mechanics/adaptive-audio]] stem overlap (slice-gate leftover) |
| Where they stall >2 min with no progress; where they go first everywhere | zone readability, lane design |
| Visual coherence breaks: pointing at a prop/building as "off" | [[art/prop-coherence]] (should be near-zero now) |

## Debrief (ask in this order, verbatim, after play)

Scores are 1–5 (1 = not at all, 5 = strongly). Always follow with "why?"

1. **The slice bar** (unchanged from the gate):
   a. "Did your choices feel like they mattered?" (1–5 + which choice)
   b. "Did the game scare or unsettle you at any point?" (1–5 + which moment)
   c. "Did the dog feel like a companion or a mechanic?" (1–5 + a moment)
2. **Clock urgency**: "Did you feel the world was reacting to you, or on a
   timer?" (reacting / timer / neither). Then: "How close is the village to
   catching you, 1–10 — and what told you that?" *(the doom-legibility probe:
   answers should cite bells/posters/patrols/gossip, not guesswork)*
3. **Interface horror**: "Did the controls ever feel wrong? Describe it." Then
   classify silently: haunted (intended) / broken (over ceiling) / unnoticed
   (under floor).
4. **Audio**: "Describe the music in one sentence." Then: "Any moment it got
   louder/messier without reason?" (stem overlap probe)
5. **Darkness**: "Was night dark enough to worry you?" (1–5; darker-dread
   leftover)
6. **The kill question**: "Would you keep playing right now if you could?
   What would you want to see next?" (the only retention probe that matters)

## Pass/fail thresholds → tuning knobs

| Signal | Threshold | Knob if failed |
|---|---|---|
| Soothe discovered unprompted | ≥3 of 5 testers | plateau glance cue ([[ideas]]), Briar aura telegraphing |
| "Reacting to me" vs "timer" | majority "reacting" | milestone/alarm point weights in `HollowingClock` |
| Doom 1–10 cites world evidence | ≥3 cite specifics | accelerate bells/posters/journal roadmap items |
| Interface horror read as haunted | 0 "broken" verdicts at default intensity | `interface_pressure` ramp/cooldown; spike duration |
| Briar pings noticed | ≥3 testers | bark SFX volume/double-bark, "!" pixel indicator, hop |
| Audio never "messy" | 0 stem complaints | crossfade dwell/levels; stems-as-one-composition sprint |
| Night worry score | median ≥3 | CanvasModulate floor with dread (not just overlay) |
| Would keep playing | ≥4 of 5 yes | if no: the answers to "what next" pick the content arc |

> **`[FLAG]` 5 testers ≠ tone validation** (solo-dev setup research, 2026-06-20): the "~5 users surfaces most problems" rule (NN/g, "Why You Only Need to Test with 5 Users") is about **usability** — *can they operate it* (the soothe/Briar/interface rows above). It does **not** validate *fun* or *atmosphere*: whether **dread actually lands** is a different question that needs **more, varied testers over time**, not 5. Trust small-n for the operability rows; treat the dread/doom/night rows as directional until repeated across several testing rounds. `[verified 2026-06-20]`

## Data capture

One file per tester: `docs/playtest/2026-06/tester-NN.md` — copy the template
below. Synthesis after ALL sessions (never tune after one tester):
`docs/playtest/2026-06/synthesis.md` — per-threshold verdicts + the tuning
list, which becomes the next branch plan.

```markdown
---
tester: NN (anon)
date: YYYY-MM-DD
profile: horror-familiar | rpg-familiar | neither
build: <git sha / export date>
---
## Observation notes
(timestamped, from the checklist)
## Debrief answers
1a: _/5 — | 1b: _/5 — | 1c: _/5 —
2: reacting/timer — | doom: _/10, evidence:
3: haunted/broken/unnoticed —
4: " " | overlap:
5: _/5
6: yes/no —
## One surprise
(the thing the protocol didn't ask about)
```

## Out of scope for this pass

Balance/difficulty numbers (combat damage etc.), content volume complaints
("too short"), and feature requests — capture in the tester file, route to
[[ideas]], do not act this pass. Humans tune dread; agents implement knobs.

## Related

[[slice-implementation-roadmap]] (Next arcs §1) · [[design/market-positioning]]
(demo ends at stage 0→1 — this protocol's beat 5 validates that ending lands)
