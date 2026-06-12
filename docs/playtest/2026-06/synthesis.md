---
name: Playtest synthesis — June 2026 feel pass
status: in progress (4 sessions, 3 distinct testers)
protocol: "[[plan/playtest-protocol-2026-06]]"
---

# Synthesis (running)

## Sessions
| # | profile | length | valid beats |
|---|---|---|---|
| [[tester-01]] (SJ) | horror+rpg | ~5 min | 1–2 |
| [[tester-02]] (MR) | horror+rpg | short, native editor | 1–2; crashed at village |
| [[tester-03]] (MR retest) | horror+rpg | longer, web | 1–3 (village reached); stage-1 unconfirmed |
| [[tester-04]] (PH, new) | horror+rpg | medium, web, H-shortcut | 1–3 + **bell reached** — first valid clock/doom session |

## Fix → verify loop (working)
| Defect | found | fixed | verified |
|---|---|---|---|
| Soothe affordance (no HOLD hint/bar) | t01 | SoothePrompt | t02 bar ✓, t03 **"haunted, prompt clear"** ✓ |
| Hint behind hearts | t02 | explicit anchors | t03 ✓ (no complaint) |
| Village "crash" (tileset decl) | t02 | tres+generator+test | t03 reached village ✓ |
| Reggae danger stem | t01+t02 | user-generated v2 | t03 **"danger sound now really good"** ✓ |
| Danger plays after Stilled / in daylight | t03 | `cap_layer` threat+daylight gate | t04 partial — lingers past visibility; radius 220→160 → t05 |
| Gossip text covered by props/characters | t03 | z_index 200 (gossip + "!") | t04 no complaint ✓ |
| Keyless soothe plateau reads as bug | t04 | stalled cue ("something is missing" + amber bar) | → t05 |

## Threshold tracker
| Signal | t01 | t02 | t03 | verdict |
|---|---|---|---|---|
| Soothe affordance | ✗ | ~ | ✓ haunted | **PASSED post-fix** |
| Audio never "messy" | ✗ | ✗ | content ✓ / logic ✗ (fixed) | re-verify t04 |
| Night worry ≥3 | 2/5 | 3/5 | 3/5 | borderline — darker-dread knob still candidate |
| "Reacting" vs "timer" | n/a | n/a | neither | t04: **"reacting vaguely"** — first positive movement |
| Doom cites evidence | n/a | n/a | 1/10 none | t04: **3/10 WITH evidence** (warden after the bell) — the one shipped doom signal (warden routines) is the one that landed; bells/posters/journal would add the rest |
| Briar pings noticed | ? | ~ | "bark sometimes" | Briar reads passive — see signals |
| Would keep playing | ✗ | ✗ (crash) | ✗ ("nothing to do") | t04 ✗ ("not enough action or **secrets**") — 4/4, content drought CONFIRMED |

## Doom legibility: partial proof (t04)
The first bell-valid session scored doom 3/10 **citing real evidence** (the
warden's post-bell appearance). The only world-visible doom signal that
exists today (stage-keyed warden routine) is exactly the one the tester
read. Direct validation of the hollowing-clock doom-legibility roadmap:
every added diegetic signal (bell pattern language, poster swaps, journal)
should move this number. "Reacting vaguely" beats three "neither"s.

## The headline (4/4 testers, defects now excluded): CONTENT, not systems
"Want to see something happening" (t01) → "nothing much to do except waiting
for sounds" (t03). Atmosphere praised 3/3, choices 5/5 ×3 — the foundation
holds; the first 10 minutes have no authored events. This is exactly
next-arc 3 (playground recontext authoring / early dread beat) + the
doom-legibility roadmap (bells/posters: SOUNDS the tester "almost couldn't
notice" need world-visible counterparts). Recommendation: the next dev arc
is the **early-game content beat**, ahead of any further knob tuning.

## Captured for later (await more data / route to ideas)
- **Combat feel**: "attack looks clunky on both sides" + "attack SFX weird"
  — anim timing/hitstop + AU2 SFX redo; combat doc is still `draft`.
- **Briar legibility**: stays put with no tell (quirk freezes/stare read as
  bugs), "does not do much else" — quirk telegraph + the dig-assist
  visibility; pairs with the quirk-journal idea.
- **Villager interaction affordance**: only "!" appears, no interaction, no
  hint. Even a one-line brush-off per villager ("…they turn away") would
  turn the mute "!" into the world-that-moved-on THEME. Strong candidate
  for the content arc.
- Danger stem still doesn't *align* with monster attacks (crossfade is
  2.5s) — by design for now; revisit in the audio sprint (stingers cover
  attack moments).

## Process notes
- Same-tester retests verify fixes but don't add independent thresholds —
  tester-04 should be a NEW person. *(Done — t04 was new, and the
  H-shortcut delivered the first valid bell session.)*
- Still no session has confirmed reaching hollowing stage 1; the
  clock/doom probes stay starved until a 30–45 min session happens.
