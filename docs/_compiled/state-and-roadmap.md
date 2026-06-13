# Project State & Roadmap — canonical brain (AGENTS.md), roadmap, ideas inbox, latest session journals
> GENERATED 2026-06-13 by tools/compile_snapshots.py — do NOT edit (not here, not in claude.ai). Source of truth is the Obsidian vault in the game repo; this file is replaced wholesale at milestones.
> Sources: AGENTS.md, docs/plan/playtest-protocol-2026-06.md, docs/plan/slice-implementation-roadmap.md, docs/ideas.md, docs/sessions/2026-06-13-charsheet-animations.md, docs/sessions/2026-06-13-accessible-interiors.md, docs/sessions/2026-06-13-per-session-journals.md, docs/sessions/2026-06-13-bible-charsheets.md, docs/sessions/2026-06-13-pixellab-fx-props.md


======================================================================
SOURCE: AGENTS.md
======================================================================

# AGENTS.md — Cycle of Innocence (Canonical Project Brain)

**This is the single source of truth for ALL AI tools** (Claude Code, Codex CLI, Grok CLI, Cursor) working on this project. Per-tool files (`CLAUDE.md`, `GROK.md`, `AGENT_RULES.md`) are thin shims pointing here. Rules live ONLY in this file; project *knowledge* lives in the Obsidian vault at `docs/` (story bible, mechanics, decisions, sessions). If you change a rule here, change it nowhere else.

## Project identity

**Cycle of Innocence** — 2D top-down horror-conspiracy action-adventure RPG (Godot 4.4.x).

- Protagonist **Rowan**: escaped child sacrifice (selected via lottery / Community Harmony Score; ritual at the village playground with creepy clown "Playtime Guardians", stitched stuffed animals, living toys). Villagers initially believe the ritual succeeded — the "delayed alarm" drives escalation.
- **Animal companions are the found family and the mechanical party**: Briar (hound, emotional heart), Echo (bird, knowledge), Storm (mount, freedom). Bond/corruption per companion. Human NPCs are secondary and untrustworthy.
- Age progression (child → teen → adult) + morality (-100 Innocent/Empath … +100 Ruthless/Vessel) with **visible** consequences (appearance, companion states, world reactions, abilities, 4 endings).
- Tone: Zelda/Mana exploration + real-time combat, Silent-Hill-adjacent dread, AoT-style conspiracy twists, Fable-style life progression.
- Platforms: Linux (primary), Android (touch), **Web/HTML5** (itch demo + NAS playtest loop — Web support is a hard constraint).
- Scope: focused single-player campaign (6–10h v1); replay via choices/companion fates/endings/NG+. **Vertical slice first.**

**Guardrails**: No reuse of the Mote/"Echoes of the Verdant Realm" cozy game (only low-level 2D patterns/pipelines). Every feature must serve story, a companion arc, a horror beat, or replay — otherwise cut/defer. **Patent posture** (docs/decisions/2026-06-10-patent-risk-review.md): companions are authored characters with scripted progressions — never frame/implement as procedural NPC hierarchies, ranks, or "nemesis systems" (WB patent live to 2036); no radial emotion-mapped dialogue wheel UI before Oct 2029 (BioWare patent) — list balloons as built.

## Locked tech stack

- Godot **4.4.x standard build** (no .NET — C# breaks Web export), typed GDScript.
- **Dialogue Manager** (nathanhoad, `addons/dialogue_manager/`) for all branching dialogue — conditions/mutations read & write `PlayerData` directly. *(Replaced Yarn Spinner 2026-06-10; see `docs/decisions/2026-06-10-new-features-and-ai-setup.md`.)*
- **LimboAI** (`addons/limboai/`, v1.6.0 gdextension-4.4) for enemy/companion behavior trees + `NavigationAgent2D` pathfinding. **No runtime LLM calls in the shipped game** (offline mobile, latency, cost).
- **GUT** (`addons/gut/`, v9.4.0) for unit tests — run `bash tools/run-tests.sh` (headless). ⚠️ Addon versions are pinned to Godot 4.4; bump Godot and addons together.
- Art: 32×32 pixel (SNES/Zelda + horror), Grok Imagine → pixel cleanup (scripted or any layer-capable editor — GIMP/Pixelorama; no Aseprite installed) → Godot nearest-filter import.
- Autoloads (current): `GameEvents`, `PlayerData`, `DialogueManager` (addon), `DreadManager`, `ZoneManager`, `WorldState`, `HollowingClock`, `VillageState`, `Journal`, `SaveManager`, `Sfx`, `AdaptiveAudio`; (planned): `CompanionManager`, `InputManager`.
- **PixelLab API** available for character/animation generation: key at `~/.config/pixellab/api_key` (NEVER in repo), client `tools/pixellab_api.py` (generate/rotate; free tier needs credits for generation). Decision: docs/decisions/2026-06-10-sprite-tool-pixellab.md.
- **ElevenLabs API** for SFX (text-to-sound-effects): key at `~/.config/elevenlabs/api_key` (NEVER in repo; **free tier**, credits reset monthly — pause generation when exhausted), client `tools/gen_elevenlabs_sfx.py` (requests PCM → downmixes to mono 16-bit WAV via stdlib `wave`, no ffmpeg). Real SFX replace the `gen_placeholder_sfx.py` placeholders in `assets/audio/sfx/` (keep filenames → `Sfx.gd` keys intact).
- AI production stack: FOSS-first; see `docs/design/ai-production-setup.md`.

## Critical rules (R1–R7)

- **R1 — Branch first.** Never commit to main. `type/short-name` (`feature/…`, `fix/…`, `refactor/…`, `docs/…`). A PreToolUse hook blocks main commits.
- **R2 — Read before work.** This file + `docs/story/bible.md` + the relevant `docs/mechanics|design/*.md` before any feature work. Grep `docs/decisions/` for prior art; link findings with `[[backlinks]]`.
- **R3 — Vertical slices.** Every increment F5-playable. Slice definition below.
- **R4 — Imagine-first assets.** Character/companion bibles before sprite sheets; document every prompt in `docs/art/imagine-prompts.md`; pixel post-process (scripted or GIMP/Pixelorama — no Aseprite); nearest-filter import.
- **R5 — Journal & capture.** **Each session writes its OWN journal file** `docs/sessions/YYYY-MM-DD-<slug>.md` (slug = your branch/feature, e.g. `2026-06-13-footstep-surface.md`); newest entries first within your file. **NEVER append to a shared daily file or edit another session's file** — that shared-file append is what kept causing parallel-session merge conflicts (per-session files never collide). Read a whole day with `python3 tools/session_digest.py [YYYY-MM-DD]`. Convention: `docs/sessions/README.md`. Stray ideas → `docs/ideas.md` inbox, never dropped. Run `python3 ../scripts/obsidian/status.py` at checkpoints.
- **R6 — Commit & push.** After meaningful changes: commit on the feature branch and push to `origin` (github.com/tchintchie/**game** — the only repo; the rpg-adventure mirror was retired 2026-06-10, see `docs/decisions/2026-06-10-repo-consolidation-game-only.md`). The user merges to main. A public standalone repo will be split out when a demo is ready.
- **R7 — Research bridge.** Web research lives in the claude.ai Project "Cycle of Innocence — Design & Research", grounded in the `docs/_compiled/` snapshots (`python3 tools/compile_snapshots.py`, regenerate + re-upload after milestone merges that touch docs). Results come back ONLY via the `docs/research/` inbox → librarian pass (propose-first; locked decisions get flags, not edits). Convention: `docs/research/README.md`; system: `docs/setup-guide.md`.

**Completion checklist**: feature branch ✓ · docs updated ✓ · journal ✓ · ideas triaged ✓ · `tools/run-tests.sh` ✓ · `tools/check-brain.sh` ✓ · `status.py` no RED ✓ · pushed to origin ✓.

## Tool roles (who does what)

| Tool | Role | How |
|---|---|---|
| **Claude Code** | Hub/orchestrator + primary implementation | Hooks enforce R1; plugins drive the others; auto-memory at `~/.claude/projects/-home-seitanist-game/memory/` |
| **Grok** | Vision, story consistency, Imagine art prompts/generation | Grok MCP tools from Claude Code, or `grok` CLI (reads this file natively) |
| **Codex CLI** | Second-opinion code review, stuck-state rescue | `codex:rescue` skill from Claude Code, or `codex` directly (reads this file natively) |
| **Cursor** | IDE: visual review, manual multi-file editing | Reads this file natively; no Cursor-specific rules maintained |

All tools read this AGENTS.md: natively (Codex, Cursor, Grok) or via the `@AGENTS.md` import in `CLAUDE.md` (Claude Code).

## Vertical slice definition (Phase 0/1 exit criteria)

- Child Rowan (age visuals stub) + Briar pup (follow + one contextual assist: dig or bark).
- One small zone: playground at dusk → fringes (tilemap + collision + ritual decor).
- Real-time movement + basic attack (facing, anim lock) — exists in `scripts/player/player_controller.gd`.
- One environmental puzzle using companion or morality choice.
- One Dialogue Manager scene: escape-ritual context + first bond/morality choice with Briar (state on PlayerData).
- One dread beat: fog, wrong toy sounds, first monster glimpse; companion fear behavior.
- Save stub, interact prompt, touch parity. F5 <10s on web export.
- Playtest bar: did the choice matter, did dread land, did the bond feel real?

## Architecture & key paths

```
test/  (active dev root inside the tchintchie/game monorepo)
├── project.godot            autoloads: GameEvents, PlayerData, DialogueManager
├── scripts/autoload/        game_events.gd, player_data.gd (age/morality/companions/revelations — fully implemented)
├── scripts/player/          player_controller.gd (8-dir, states), age_morph.gd (age/morality/corruption visuals)
├── scripts/debug/           progression_test.gd (debug panel, keybinds 1-0)
├── scenes/player/player.tscn · playground.tscn (main scene)
├── assets/shaders/          marked_corruption.gdshader
├── addons/                  dialogue_manager/ · limboai/ · gut/
├── tests/                   GUT tests (run: bash tools/run-tests.sh)
├── tools/                   run-tests.sh · check-brain.sh
└── docs/                    Obsidian vault — THE KNOWLEDGE BASE:
    ├── story/bible.md · endings.md · choice-matrix.md · characters/companions.md
    ├── mechanics/  combat · progression · horror-and-dread · inventory ·
    │               encounters-mercy · hollowing-clock · day-night-hideout · vision-and-darkness
    ├── design/     game-features (index) · customization · ai-production-setup
    ├── research/   claude.ai inbox (R7) · _compiled/ snapshots · setup-guide.md
    ├── decisions/ · sessions/ · ideas.md · art/imagine-prompts.md
```

Conventions: typed GDScript; signals for decoupling (extend `GameEvents`); state machines for player/companions; no monolithic scripts; Resources for SpriteFrames/abilities. For Godot 4.4 typing: explicit types for Dictionary/Variant access (no `:=` inference there); don't access other scripts' vars by type — use signals.

## Working loop

1. Plan against the bible + mechanics docs (R2).
2. Implement in small F5-testable steps; agents are runtime-blind — run the game/tests, paste errors back, iterate.
3. Test: `bash tools/run-tests.sh`; manual F5 for feel. Humans tune balance/difficulty/dread — agents don't. **Before any F5 in the shared `test/` checkout, run `bash tools/sync.sh`** — merging a PR on GitHub does NOT update the working copy, so a stale checkout shows old code (auto-stashes local editor edits, fast-forwards, reimports).
4. Asset work: prompts per `docs/art/imagine-prompts.md` style rules (32×32, limited palette, no AA, transparent bg; age/growth/corruption variants).
5. Close: journal, ideas, status, sync, commit (checklist above).


======================================================================
SOURCE: docs/plan/playtest-protocol-2026-06.md
======================================================================

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


======================================================================
SOURCE: docs/plan/slice-implementation-roadmap.md
======================================================================

---
name: Vertical Slice Implementation Roadmap (M0–M3)
date: 2026-06-10
tags: [plan, roadmap, vertical-slice, agents]
status: active
related_decisions: "[[decisions/2026-06-10-slice-implementation-plan]]"
---

# Vertical Slice — Implementation Roadmap with Agent Distribution

Concretizes Phases 0–2 of [[decisions/2026-06-09-cycle-of-innocence-build-plan]] into executable, agent-assigned milestones. Slice definition + exit criteria: AGENTS.md. **Slice target**: child Rowan + Briar pup, playground→fringes zone, real-time combat vs one monster, one dialogue choice with morality/bond impact, one dread beat, save stub, touch parity, F5 <10s on web.

## Agent assignment matrix

| Agent | Owns | Interface |
|---|---|---|
| **Claude Code** (hub) | All GDScript/scenes/tests, orchestration, commits + push | godot-mcp (scene tree, run-game, error capture) |
| **Grok** | Art generation A1–A5, dialogue voice review, prompt iteration | `mcp__Grok__generate_image`/`edit_image`/`chat` or Grok CLI; prompts in [[art/imagine-prompts]] |
| **Codex** | Review gates after M1.2 + M1.3, stuck-state rescue | `codex:rescue` skill from Claude Code |
| **Cursor** | Human-driven in-editor work: TileMap painting, light/shader tuning, scene composition | reads AGENTS.md natively |
| **Human** | pixel cleanup (GIMP/Pixelorama/scripted — no Aseprite), ACE-Step/ChipTone audio runs, playtests, branch merges, slice gate verdict | — |

## M0 — Art & audio production (parallel track — NEVER blocks code)

Code always proceeds on existing placeholder sprites; assets land when they land.

| # | Task | Owner | Source/Target |
|---|---|---|---|
| A1 | Rowan child bible → 4-dir sheet (idle/walk/attack/hurt) | Grok Imagine → human Aseprite | prompt in [[art/imagine-prompts]] → `assets/reference/`, `Player/Sprites/` |
| A2 | Briar pup bible → sheet (follow/sit/dig/fear/bark) | Grok Imagine → human Aseprite | prompt in [[art/imagine-prompts]] |
| A3 | Playground-dusk tileset + fringes-forest tileset | Grok Imagine → human Aseprite | NEW prompts (added below in imagine-prompts) |
| A4 | "Twisted Child" monster design (subtle: faded clown ruff, broken toy) | Grok Imagine → human Aseprite | NEW prompt |
| A5 | Minimal HUD + touch icons (hearts, interact, soothe-hold) | Grok Imagine or hand-pixel | NEW prompt |
| AU1 | Playground theme as 3 stems (ambient/tense/danger, shared BPM/key) + lullaby motif | Human via ACE-Step (prompts in [[mechanics/adaptive-audio]]) | `assets/audio/stems/` |
| AU2 | SFX batch: steps, attack, hit, dig, whimper, bark, toy-creak stinger | Human via ChipTone/sfxr | `assets/audio/sfx/` |

## M1 — Core systems (Claude Code; one branch per item; GUT tests each)

1. **DreadManager autoload** — meter (0–100), sources (zone, events, night later), signals, CanvasModulate/vignette hookup, horror-intensity setting read. Spec: [[mechanics/horror-and-dread]].
2. **Combat v1** — attack hitbox (Area2D, proper physics layers), damage/knockback/hitstop, enemy base scene + LimboAI BT (patrol/notice/chase/attack), Twisted Child enemy (Recognition field stubbed for M3). Spec: [[mechanics/combat]]. → **Codex gate**: physics layers + BT structure review.
3. **Briar companion** — scene + LimboAI follow/assist/fear states keyed to `PlayerData.companions[briar]` + DreadManager; contextual dig assist (interact near diggable). Spec: [[characters/companions]]. → **Codex gate**.
4. **Zone framework** — ZoneManager autoload; `scenes/zones/playground_fringes.tscn`: TileMap + collision + occluders, basic ambient-radius lighting (full vision cone is post-slice, [[mechanics/vision-and-darkness]]), zone transitions.

## M2 — Narrative & persistence

1. **First dialogue** — escape aftermath + "The Food" choice (share with Briar / keep it): Dialogue Manager balloon; mutations call `PlayerData.change_morality` / `set_companion_bond` directly. **Grok reviews lines** against [[story/bible]] voice before merge.
2. **SaveManager autoload** — JSON persistence of PlayerData + zone + companion/Stilled states; GUT round-trip tests.
3. **Scripted dread beat** — fog roll-in, wrong-toy audio, Briar fear behavior, monster glimpse (uses DreadManager + AU1/AU2 if landed).

## M3 — Slice assembly & gate

1. **Mercy v1** — hold-to-soothe → Stilled on the Twisted Child ([[mechanics/encounters-mercy]] core loop only).
2. **Touch input** — virtual stick/buttons ported from `../godot/` sibling; minimal HUD.
3. **Adaptive audio v1** — hand-rolled 3-stem autoload (AdaptiSound only if verified 4.4-compatible). Spec: [[mechanics/adaptive-audio]]. *(Resolved 2026-06-12: AdaptiSound rejected — no web export; hand-rolled shipped. [[decisions/2026-06-12-adaptisound-rejected]])*
4. **Web export** — preset + NAS deploy (serve.py workflow), <10s load verified.
5. **SLICE GATE (human)** — playtest: did the choice matter? did dread land? did the bond feel real? Fail → re-scope before any post-slice feature work.

## Post-slice build order (after gate passes)

vision-cone polish → day/night + hideout → mercy full (unique soothes, Domination) → hollowing clock → companion quirks → interface horror → village life → zone recontextualization. Specs all in `docs/mechanics/`. **← queue completed 2026-06-11.**

## Next arcs (2026-06-12, research round 3)

Scope rule adopted: **define "content-complete" per zone** (recontext moments authored, gossip pools written, stems present, props placed) **and burn it down before any new mechanic** — the playtest pass gates each arc.

1. **Structured playtest/feel pass**: clock pacing ("urgency without anxiety treadmill"), interface-horror frustration ceiling, suspicion→alarm tuning, plus slice-gate leftovers (stem overlap, darker dread, bark visibility). Recruit 3–5 outside testers via the NAS/itch web build. **Protocol ready: [[playtest-protocol-2026-06]]** (session script, observation checklist, debrief, pass/fail thresholds → tuning knobs).
2. **Audio content sprint**: produce playground/fringes stems as *one composition, stripped mixes* so the v2 crossfade graduates to true layering ([[mechanics/adaptive-audio]]).
3. **Playground recontext authoring**: the 2–3 thesis-statement moments for the first revelation — content, not mechanism ([[mechanics/zone-recontextualization]]).
4. **Steam timing decision** (user): [[decisions/2026-06-12-steam-timing]] — Coming Soon page lead time compounds; patent re-review rides the same milestone.
5. **Village zone coherence conversion**: execute the [[art/prop-coherence]] fix plan (camera clamps, palette hard-lock, foundations, prop regen, `create_map_object` smoke test) inside the content-complete-per-zone rule — no new mechanics ride along. *Ordering note (user's call): plan items 2–3 (camera clamp + palette pass) are cheap and arguably belong BEFORE arc 1's external playtest — an incoherent village muddies dread feedback.*

## Working rules (from AGENTS.md, repeated for hand-offs)

- One branch per milestone item (`feature/m1-dread-manager` etc.); GUT green + check-brain green before push; user merges.
- Codex gates are advisory second opinions — findings triaged by Claude Code, not auto-applied.
- Every system reads/writes PlayerData via existing signals; no new global state without a doc.

## Related
[[decisions/2026-06-10-slice-implementation-plan]] · [[design/game-features]] · [[art/imagine-prompts]] · AGENTS.md


======================================================================
SOURCE: docs/ideas.md
======================================================================

---
name: Ideas Inbox — Cycle of Innocence
tags: [inbox]
---

# Ideas Inbox — Cycle of Innocence

Raw capture → triage → promote to decisions/features. Never delete, only move.

## 🆕 Unsorted
*Raw capture during sessions. No structure required.*

- (From approved plan) First companion in escape: small dog or bird that was also "wrong" for the ritual — instant bond + shared "marked" status.
- Consider one "corruptible exotic" companion option late-game (high risk/reward for ruthless paths).
- Care mechanics for animals: simple (feed from foraged items, soothe after horror events, protect in fights) but with visible loyalty + visual shifts.
- Horror via animals: the dog whimpering at things the player can't see yet; bird refusing to land in certain zones; horse bolting and forcing a choice.
- NG+ idea: carry over a "ghost" of a lost companion that gives unique (bittersweet) dialogue/options.
- Accessibility: "reduced dread" mode that mutes some stingers / companion fear reactions while keeping story.

## 🔜 Ready to promote
*Triaged ideas, ready to become decisions or features.*

- (Phase 0) Generate protagonist + first animal bible(s) with Grok image_gen using the prompt template in the plan before any code.
- Strong emphasis on "no Mote reuse" — document guardrails in GROK.md and local handbook.

## 📥 Captured this session
- Monster + ambient SFX wiring: batch-2 sounds exist but nothing calls them — `twisted_child` → `monster_attack` (lunge), `monster_hurt` (hurt/crumble), `monster_creep` (stalk ambient); `campfire_crackle` → `AudioStreamPlayer2D` on the Hideout campfire (loop already enabled); `church_bell` → village chapel toll.
- Ambient SFX beds: `crickets.wav` + `owl_hoot.wav` exist but aren't wired — loop-enable the import and drive them from AdaptiveAudio (night/dread layer) so the fringe feels alive. Owl could also fire as an occasional dread stinger.
- Per-surface footsteps: `footstep_grass` + `footstep_gravel` both exist; player_controller should pick by ground type (tile/zone) instead of always grass. Tiny state hook.
- SFX coverage gaps (next ElevenLabs batch when credits reset): monster vocalizations (twisted-child stalk/lunge), item pickup vs the "found" stinger, bond-up chime, UI open/close (satchel/journal), water/fog ambience.
- Weapon combat wiring: `sturdy_stick`/`slingshot`/`sling_stones` exist as items+art but `use_kind=NONE`. Needs a combat-facing UseKind (EQUIP/THROW) + player_controller hook so the stick swings and the slingshot consumes a stone. Ties into [[mechanics/combat]].
- Item world-placement pass: berries + weapons aren't placed in any zone yet (ForageSpot exists; or a small loot table). Dig-up items (bone, locket) are placed.
- Dig-up loot variety: `DiggableSpot.dig_item` is a single id — a weighted table or per-NG+ swap (like `lore_text_recontext`) could make repeat digs less samey.
- Inventory v1.1: shared "one modal at a time" guard — Journal + Inventory panels both sit at layer 60; v1 mitigation is force-close-on-foreign-pause, but a single modal-stack arbiter would be cleaner. From [[decisions/2026-06-13-inventory-system]].
- Inventory touch parity hardening: the v1 "BAG" button opens the satchel, but slot interaction (feed/inspect) on touch isn't designed yet — needs a touch pass before the mobile demo.
- Item effect extensibility: `use_kind` enum reserves HEAL / REDUCE_DREAD; first utility consumable (bandage / clean lantern oil) will exercise the non-FEED dispatch + the `consumed_on_use=false` reusable-tool path (whistle/lantern).
- Morality-flavored item *effects* (not just descriptions): the "kind herb soothes / ruthless prep poisons" idea from [[mechanics/inventory]] is still unbuilt — v1 only swaps description text.
- Quirk journal UI: let the player pin one observed line per discovered quirk (companion-quirks.md diagnosis loop) — fold into the interface-horror/UI pass.
- Plateau discovery cue: when generic soothe stalls at 60, the monster could glance toward its buried key (environmental hint without UI). *(2026-06-12: stall now shows "it calms… but something is missing" + amber bar; the monster-glance environmental cue is still the richer follow-up. Backed by secrets research → [[design/secrets-and-discovery]].)*
- Faction-aware hitboxes before multi-enemy zones: a Dominated thrall's lunge currently uses the player-hurting hitbox layer — fine with one enemy, needs factions later.
*From plan creation + initial setup (2026-04). Move to Unsorted or Ready after review.*

- Protagonist as escaped sacrifice + animal companions (dog/ bird / horse) as primary found family and mechanical helpers.
- Use test/ as active dev root for now; create self-contained docs/ vault here while linking to parent.
- Create GROK.md + full Obsidian setup inside test/ before Phase 0 code spikes.
- Leverage existing hooks (check-branch), .grok agents/skills (spawn_subagent, imagine, graphify on bible), and parent obsidian scripts.
- Yarn Spinner chosen (→ replaced by Dialogue Manager 2026-06-10); real-time action combat; 32x32 pixel with age + corruption + animal growth variants.

## 🗑️ Rejected
*Won't-do with reasons. Keep for future reference.*

- Human-centric party as primary bonds (replaced by animals per revision).
- Any direct reuse of Mote cozy mechanics, diorama framing, or season/vine systems.
- Extra art vendors — Ludo.ai tilesets, Leonardo/Midjourney "tilemap export" (2026-06-12 art-tooling research): Ludo adds nothing layout-level [verified 2026-06-12]; Leonardo/MJ first-party tilemap export likely doesn't exist [unverified]; all three would add vendors to the locked art lane without capability we lack. ([[art/prop-coherence]])

## 📥 Captured this session (story fleshing)

- Gave the protagonist a concrete name and background: Rowan, Subject-07, escaped during the Night of the Hollowing with the first companion (a pup that was also a "lesser offering").
- Companions now have names and strong personalities: Briar (hound — emotional heart, most tragic corruption path), Echo (bird — knowledge and uncomfortable truths), Storm (mount — symbol of freedom and the cost of care).
- The four endings are now distinct and companion-dependent. The "Transformation" ending feels like the thematic sweet spot (hopeful but alien, found family literally changes the rules of the world).
- Early choice "The Food" (sharing with Briar on night 1) is now the very first major signal for bond vs corruption.
- Need to decide: Can any human ever be a true long-term ally, or are all human bonds ultimately tragic or illusory? (Leaning toward "mostly tragic" to keep the animal found-family focus pure.)
- For art: Now that we have specific companion personalities and the "corrupted" body-horror direction, the next image_gen calls should be for full bibles with growth + corruption variants.

## 📥 Captured this session (game features brainstorming)

- Strong support for player naming the protagonist and all companions — this is high immersion value for the found-family theme and costs very little.
- Gender selection for Rowan with mostly cosmetic pixel art impact but meaningful subtle narrative flavor (elders' biases, some companion reactions). Keeps story universal while adding replay texture.
- Morality as the primary "build" and visual driver (age + morality variants for sprites + shaders) instead of traditional character creator or heavy customization. This keeps art scope under control while making choices feel visible.
- Companion care items as the main "inventory loop" — turns inventory into an emotional and mechanical extension of the bond system rather than busywork.
- Dread meter as a global systemic layer that affects combat, audio, visuals, *and* companion behavior. This is a great way to make horror feel systemic rather than just set dressing.
- Revelation-gated content (abilities, enemy behavior, puzzle solutions, dialogue) as a core way the conspiracy "leaks" into gameplay.
- Horror intensity slider that reduces effects but never removes mechanical or story consequences — important accessibility commitment.
- NG+ with companion "echoes" and knowledge carry-over is one of the strongest replay hooks alongside different morality/ending paths.
- Every feature brainstorm was filtered through "does this serve the story, a companion arc, or a horror beat?" — several ideas were cut or deferred for scope.

These ideas are now documented in the new design/mechanics files and should be referenced when moving from story bible → prototype.

## 📥 Captured this session (slice gate polish, 2026-06-10)

Gate passed; polish items from the verdict (address during post-slice audio/feel passes):

- **Audio stem overlap**: stems clash when layered — regenerate as true aligned layers (same seed/progression in ACE-Step, or strip-down mixes of ONE track), duck tense/danger under stingers, review mix levels. ([[mechanics/adaptive-audio]])
- **Darker dread**: push the dusk/vignette further at high tiers — consider lowering CanvasModulate with dread, not just the overlay.
- **Bark visibility**: barking is easy to miss — louder/double bark SFX, a small "!" pixel indicator above Briar, and/or a brief hop animation; companion telegraphs must read instantly (feeds [[mechanics/companion-quirks]] later).

## 📥 Captured this session (legal, 2026-06-10)

- **Re-run the patent review at the demo/marketing milestone**: verify Nemesis patent unchanged, check Palworld-case fallout (USPTO re-exam of US 12,403,397 may set precedent), and have an IP attorney sanity-check before commercial release. ([[decisions/2026-06-10-patent-risk-review]])

## 📥 Captured this session (sprite tooling, 2026-06-10)

- **PixelLab API/MCP from the hub**: PixelLab has an API + documented MCP/Claude Code workflow — when variant batches start (outfits × ages), drive generation from Claude Code instead of clicking the web UI. (Decision: [[decisions/2026-06-10-sprite-tool-pixellab]])
- **Paper-doll layering v2**: if weapon/equipment combinatorics outgrow the 3 morality outfit states, switch from full variant sheets to base-body + clothing/weapon overlay layers (PixelLab can generate clothing-only transparent layers); composite in Godot.
- LPC/OpenGameArt dog walk cycles (CC) as animation timing reference for Briar polish.

## 📥 Captured this session (research round 2, 2026-06-10)

- **Ability layering rule** (Animal Well): every companion ability must ship with 2-3 cross-context uses (Briar's dig = puzzle + combat interrupt + lore unearthing) — depth without new ability count. Apply when implementing assists.
- **Puzzle-only progression guarantee** (Crow Country): accessibility stretch goal — the critical path never *requires* combat (mercy/stealth always viable). Audit when zones are built.
- **Ritual-symbol literacy** (Lorelei and the Laser Eyes): the player gradually learns to *read* the cult's symbols; late-game environmental text becomes legible. Cheap flavor layer on zone-recontextualization.
- **Transformation phases mid-fight** (Look Outside): corrupted companion boss variants could evolve phases during the encounter — reserve for the Briar tragedy fight if corruption path is taken.

*(Secrets research 2026-06-13 deepened the first three of these with sourced backing — Animal Well "each tool teaches a singular fact, discoverable through play not text"; Crow Country ships a combat-free Exploration Mode + 15 optional non-combat secrets; Lorelei keeps all knowledge in-game + randomizes solutions. All folded into [[design/secrets-and-discovery]].)*

## 📥 Captured this session (footstep surfaces, 2026-06-13)

- **SurfaceZone editor pass**: the per-surface footstep hook ships with ONE rough `PlazaGravel` zone in the playground — author the real surface map in the editor (path band, ritual sand, wood on the play equipment). Add `SurfaceZone` Area2Ds, set `surface` (gravel/path/sand → gravel sound; anything else → grass). Pairs with the SFX session's `footstep_gravel` wiring.

## 📥 Captured this session (secrets research, 2026-06-13)

Synthesized in [[design/secrets-and-discovery]]; raw captures here for the inbox trail.

- **Obra-Dinn confirmation buffer** ("confirm in threes"): for any deduction-style cult secret, require N confirmations before the game locks it in — blocks brute-force guessing. Copied since by Golden Idol / Roottrees. Reserve for after the early arc proves out.
- **Replay/failure as the key** (Inscryption): the safe code is only visible after the player has died at least once — failure itself unlocks. Candidate flavor for NG+ / death-gated reveals; pairs with the existing NG+ echoes.
- **Second-read VillageState gossip**: author gossip lines that read differently once a revelation is known (Undertale-style foreshadowing-that-only-reads-post-twist; In Stars and Time loop-locked re-interaction). Cheap replay layer on the existing stage-keyed gossip pools.
- **"Three players at once" layering** (Animal Well): clean critical path / optional explorer layer / reserved NG+/community layer — density under constraint. The structural target once the early secrets arc lands.

## 📥 Captured this session (central brain, 2026-06-10)

- Karpathy LLM-wiki pattern: later, consider an auto-synthesized `wiki/` layer over raw docs (graphify skill could seed it) so agents read compounding summaries instead of raw files.
- When parallel implementation starts, use git worktrees per agent (Claude Code EnterWorktree / Grok CLI's native worktree subagents) to avoid file collisions.
- Watch Claude Code issue #34235 (native AGENTS.md support) — if it lands, the CLAUDE.md shim can shrink further.
- Cursor reads AGENTS.md natively — revisit Cursor background agents only if a heavy parallel refactor ever needs them (cost: credits).

## 📥 Captured this session (genre research, 2026-06-10)

Researched-but-not-greenlit candidates worth keeping (source game in parens):

- Save-scarcity "sanctuaries" — saves only at hideout/safe lights, making safety a resource (Fear & Hunger, softened). Partially absorbed by [[mechanics/day-night-hideout]]; full scarcity deferred — may frustrate mobile sessions.
- Corruption spreading visibly across zone maps over time, reclaimable by player action (Children of Morta). Overlaps with [[mechanics/hollowing-clock]] stages; revisit if zones feel static.
- Companion refusal extension: corrupted/low-bond companions refusing commands mid-combat with visible body language (The Last Guardian). Already implied in companions doc — promote when companion AI is built in LimboAI.
- Meta-narrative save awareness: NG+ companions reacting to "other timelines" (Undertale). NG+ echoes already designed; this is the +1 flavor pass.
- Doom-meter UI as diegetic church bells / village posters instead of any HUD element (World of Horror inversion) — folded into [[mechanics/hollowing-clock]] presentation rules.
- Monster silhouettes rendering with faint child-outlines after the revelation — folded into [[mechanics/vision-and-darkness]].

## 📥 Captured this session (story revision implications)

- The playground ritual + creepy clowns/stuffed animals/toys is much stronger thematically than a stone circle. It weaponizes childhood safety and play, which will make the horror land harder for the player (especially in the child section).
- Lottery / Harmony Score makes the system feel more modern-bureaucratic and unfair. Parents competing or gaming the "score" could be a great source of side dialogue and moral choices later (e.g., a family that sabotaged another's score).
- Villagers believing the ritual succeeded for days/weeks creates a powerful "the world moved on without you" feeling. Rowan can potentially watch or overhear normal village life while hiding. This delay also justifies the ramp-up of extra sacrifices when things start going wrong.
- Art & zone design impact: The ritual site can be revisited later (now a corrupted, blood-stained playground with abandoned toys that still move). Early "safe" playground memories can contrast with later horror versions.
- Monster creation: The escalation ("sacrificing more and more") means there can be fresher, more recently transformed monsters mixed with older ones — good variety and tragedy.
- Potential early game moment: Rowan overhears parents celebrating or breathing a sigh of relief ("Thank the Harmony Lottery our little one wasn't picked this time") while knowing the truth.

These should feed into zone design, art prompts, and the first few dialogue nodes.

## 📥 Captured this session (projection canon, 2026-06-12)

- **QA overlay layer** (user art task): transparent layer with the two canon ellipses, a canon box, and a vertical ruler — the rule-5 import gate for every new prop/building/repaint. ([[art/prop-coherence]]) → **CLOSED 2026-06-12**: shipped as `assets/reference/qa_overlay_128.png` + legend + `tools/gate_sheet.py` (no Aseprite needed).
- **Bitforge fallback params unconfirmed**: confirm `view`/`oblique_projection` on `generate-with-style-v2` against https://api.pixellab.ai/v2/openapi.json before next relying on the fallback path.

## 📥 Captured this session (research round 3, 2026-06-12)

- **External playtest cadence**: 3–5 outside testers through the NAS/itch web build at the end of *every* content arc — not just the next one. (Round-3 audit; the rest of its process advice lives in the roadmap "Next arcs" block.)


======================================================================
SOURCE: docs/sessions/2026-06-13-charsheet-animations.md
======================================================================

---
name: Session 2026-06-13 — character-sheet animation pass
date: 2026-06-13
tags: [session, cycle-of-innocence, art, pixellab, animation]
branch: feature/charsheet-animations
commits: []
---

# Session 2026-06-13 — character-sheet animation pass

## Focus
Turn the 10 batch-3 PixelLab base characters (8-dir rotations) into animated
sprite sheets + `SpriteFrames` `.tres`, on an isolated worktree so a parallel
session could use `game/test`.

## What I did
*(newest first)*
- **Animation pass — 7/10 delivered game-ready.** Authored `ANIMATIONS` +
  `SHEET_ROWS` for all 10 in `tools/pixellab_v2.py` (walk·idle·attack·hurt +
  signatures), ran `animate → download → sheets-pro`. Shipped sheets + `.tres`:
  `rowan_teen`, `rowan_adult`, `briar_corrupt`, `storm_corrupt`, `crawler`,
  `ghost_girl`, `evil_warden`. Horse motion uses v3 `action_description`
  (no horse template listing). Full recipe in [[art/imagine-prompts]].
- **3 deferred — PixelLab `animate-character` backend degradation** (not config):
  `briar_adult`, `storm_adult` (0 anims), `storm_young` (walk-west only).
  `404 "rotation image not found for direction: south"` despite valid, fetchable
  rotations; reproduced across two recreations + ~25 min retries with the
  generation counter **frozen** → service-side. **Retry when it recovers:**
  `animate --only <char>` → `download` → `sheets-pro` (resumes via state).
- **Pipeline hardening:** `animate()` retries transient 404/5xx; `download()`
  skips a wedged char instead of aborting; `pro_anim_map()` tolerates a missing
  animations dir; `preview()`/`_fetch_frame()` send a browser UA (Backblaze 403).
- **Isolation:** ran in worktree `.claude/worktrees/charsheet-animations` off a
  fresh branch; `game/test` stayed on clean `main` for the parallel session.

## Open / next
- **Re-run the 3 deferred** once PixelLab's animate service recovers (one-liner
  per char; tool resumes). Then their `.tres` complete the set.
- **Scene integration:** wire the 7 (now 10) `*_frames.tres` into player /
  companion / enemy scenes — none are referenced yet.
- **5 non-character bibles** (Echo egg/hatchling/adult/corrupt + grasping-roots)
  still need the object pipeline (`create_map_object` / `animate_object`).
- Minor: a stray `_probe` animation exists on storm_adult (harmless, not in any
  sheet) — delete on next account cleanup.

## Related
[[art/imagine-prompts]] · [[sessions/2026-06-13-bible-charsheets]] · [[characters/companions]]


======================================================================
SOURCE: docs/sessions/2026-06-13-accessible-interiors.md
======================================================================

---
name: "Session 2026-06-13 — accessible interiors"
date: "2026-06-13"
tags: [session, cycle-of-innocence, systems]
branch: worktree-accessible-interiors
commits: []
---

# Session 2026-06-13 — accessible interiors

## Focus
Build the Terranigma-model interiors system (enter houses/huts/caves, move
between floors) on the existing ZoneManager + ZoneRoot rails.

## What I did
*(newest first)*
- **Playtest fixes + real placement** (branch `chore/export-localhost`, off
  merged main; web build re-exported to localhost:8081):
  - **Entrance moved to a real village house**: the cottage is now entered via
    a `DoorTransition` on `PropCottageA` (Marta's house) in `village_green` —
    it already lines up with the interior's `marker_marta` spot. Added a
    `spawn_from_cottage` return marker; cottage `ExitDoor` repointed to
    `village_green`. The temporary playground test door was reverted.
  - **Stairs were unfindable** (invisible `Area2D`s sitting in the graybox
    wall-band): added `stairs_down`/`stairs_up` placeholder sprites and moved
    `StairsDown` onto open floor `(120,-10)` with a matching arrival marker, so
    the prompts trigger where the player can see to stand.
  - **Dark-interior prompt fix**: the door prompt rendered in world space, so
    the basement `DarkTint` crushed it to black. Moved it to a follow_viewport
    `CanvasLayer` (separate canvas, immune to world CanvasModulate).
  - Suite **250** green; reach: playground → walk west edge → village → Marta's
    house (NW) → cottage → stairs → basement → up → exit back to the village.
- **Accessible Interiors system** (suite 247, full enter→floor→save smoke green):
  built on the *existing* transition/camera rails per the goal, not a parallel
  mechanism. Spec → [[mechanics/accessible-interiors]].
  - **ZoneManager extension**: `go_to_scene(path, spawn_id)` for arbitrary
    interior scenes (not bloating the `ZONE_SCENES` const); `spawn_<id>` marker
    resolution + `restore_position`; `request_transition` gained an optional
    `spawn_id`. `place_player_at_entry` priority: restore_position > spawn_<id>
    > legacy `entry_from_<prev>`/`entry_default` (back-compat preserved).
    `ZoneRoot` records `current_scene_path` on enter.
  - **`DoorTransition`** (one component for door→interior, stairs→floor,
    exit→world): Area2D, INTERACT/ENTER modes, `target_scene` PackedScene OR
    `target_scene_path` string (string avoids circular floor↔floor loads),
    `locked`+reason, floating prompt.
  - **`InteriorRoot extends ZoneRoot`**: per-floor `dread_baseline` (registers a
    DreadManager zone level on enter, clears on `_exit_tree`); inherits the
    camera-clamp-per-GroundBackdrop invariant free.
  - **SaveManager floor persistence**: saves `scene_path` + `player_pos`; loads
    back into the saved floor at the exact spot (basement save reloads in the
    basement, not the world).
  - **Reference cottage**: `cottage_ground.tscn` (exit→village, stairs→basement,
    a `recontext_monsters_are_children` node, a VillageState `marker_marta`) +
    `cottage_basement.tscn` (dread_baseline 45, occluder walls + ambient light).
    Graybox placeholder backdrops — real interior art is the PixelLab pipeline
    pass; collision/dressing is the user's editor pass.
  - **Tests**: 9 GUT (door locked/target, spawn-id/default/restore/legacy
    resolution, save-load floor round-trip) + a headless integration smoke
    driving real scene swaps (enter→basement→up + save/load-in-basement, all
    landing at correct spawns; dread floor 45 confirmed).
  - **Parallelization** (user asked): dispatched a background sub-agent to write
    the mechanics doc while I built the system (non-overlapping files).
  - ✅ **Codex gate** done (background `codex:rescue` agent). No critical
    findings; three should-fix one-shot-state-hygiene edge cases on the
    autosave path, all fixed on a fresh branch `fix/interiors-arrival-state`
    (the system branch was already merged):
    - **S1** `load_game` wipes stale `arriving_spawn`/`arriving_from`/
      `restore_position` up front, so a load fired mid-transition is steered
      only by `restore_position`.
    - **S2** `place_player_at_entry` consumes the one-shot state even when the
      arriving scene has no player node (new `_clear_arrival_state` helper),
      instead of early-returning and leaking it to the next load.
    - **S3** `go_to_scene` `_transition_pending` guard blocks a second trigger
      (double-press / two doors in a frame) from overwriting the in-flight
      spawn+path; cleared when placement lands.
    +3 GUT tests → **250 passing**; check-brain green. Pushed.

## Related
[[mechanics/accessible-interiors]] · [[mechanics/zone-recontextualization]] ·
[[mechanics/hollowing-clock]] · [[mechanics/vision-and-darkness]]


======================================================================
SOURCE: docs/sessions/2026-06-13-per-session-journals.md
======================================================================

---
name: "Session 2026-06-13 — per-session journals"
date: "2026-06-13"
tags: [session, cycle-of-innocence, meta]
branch: worktree-per-session-journals
commits: []
---

# Session 2026-06-13 — per-session journals

## Focus
End the recurring parallel-session merge conflicts on the shared daily journal.

## What I did
*(newest first)*
- **Per-session journal convention** (R5 rewritten): each session now writes
  its own `docs/sessions/YYYY-MM-DD-<slug>.md` and never touches a shared file
  — the shared-daily-file append was the conflict magnet that bit us ~5×
  today (footsteps/bark/sfx/secrets sessions all rebasing on the same list).
  Added: `docs/sessions/README.md` (the convention), `tools/session_digest.py`
  (read a whole day's sessions at once), and a `status.py` fix so its "today's
  journal" check globs `YYYY-MM-DD*.md` (per-session files satisfy it). This
  file is the first one under the new scheme. Legacy bare `YYYY-MM-DD.md`
  files stay as history.

## Related
[[sessions/README]] · AGENTS.md R5


======================================================================
SOURCE: docs/sessions/2026-06-13-bible-charsheets.md
======================================================================

---
name: Session 2026-06-13 — bible concept art + PixelLab character sheets
date: 2026-06-13
tags: [session, cycle-of-innocence, art, pixellab]
branch: feature/bible-concept-art-batch3
commits: []
---

# Session 2026-06-13 — bible concept art + PixelLab character sheets

## Focus
New Grok bible concept art (protagonist stages, full companion sets, new
monsters) → then the PixelLab `create-character-pro` pass to turn the
animatable ones into 8-direction character sheets.

## What I did
*(newest first)*
- **PixelLab character-sheet pass (batch 3)** — ran the proven
  `create-character-pro` (`create_from_concept`) pipeline on the 10 *directional*
  bibles → 8-dir characters (ids in `assets/reference/pixellab_v2/state.json`,
  strips in `*_pro_preview.png`). Templates: `mannequin` (rowan_teen/adult,
  crawler, ghost_girl, evil_warden), `dog` (briar_adult/corrupt), `horse`
  (storm_young/adult/corrupt). The 5 non-directional bibles (Echo egg/hatchling/
  adult/corrupt + grasping-roots) are deferred to the object path — no template
  fits birds/objects. Full prompt + recipe in [[art/imagine-prompts]].
  - **Fixed two pipeline regressions the user caught in the first batch:**
    (1) the dog/horse templates painted a **backdrop box** — `create_pro` had
    lost the `style_description` no-box negative from the 2026-06-11 briar note;
    restored it. (2) corrupted/glow bibles bled a **magenta halo** into the
    generation as speckled bg — added `_strip_magenta_fringe` to concept
    extraction. Also de-translucent-ified the ghost (rendered invisible) and
    gave `preview()`/`_fetch_frame()` a browser UA (Backblaze now 403s UA-less
    fetches). Regenerated the 7 affected (both dogs, 3 horses, crawler, ghost);
    deleted the old artifacted characters from the account. Kept the 3 clean
    ones (rowan_teen, rowan_adult, evil_warden).
  - **Worktree isolation:** your `sync.sh` had moved `game/test` to `main`
    (PRs #87–89), which lacks the batch-3 bibles, so this whole pass ran in a
    throwaway worktree at `game/wt-charsheets` off the branch — `game/test`
    never touched. Worktree removed at end of session.
- **Grok bible concept art (batch 3)** — 15 bibles (2k, magenta key, locked
  format): protagonist late-teen + adult; Briar adult (**Belgian Malinois**) +
  corrupted; Echo egg→hatchling→adult→corrupted; Storm young→adult→corrupted;
  monsters fetus-crawler, grasping-roots, ghost-girl, evil-warden. All horse
  stages reworked once after feedback (colt read / no hippie-unicorn / real
  body-horror). Prompts in [[art/imagine-prompts]].

## Open / next
- **Animate** the 10 stored PixelLab characters → `sheets-pro` → `.tres`
  (define `SHEET_ROWS` per char), same as rowan/briar/twisted. This is the
  "later" step the sheets were built for.
- **5 deferred non-character bibles** (Echo egg/hatchling/adult/corrupt,
  grasping-roots) need the object pipeline (`create_map_object` /
  `animate_object`).
- **Branch reconciliation:** `feature/bible-concept-art-batch3` is behind `main`
  (PRs #87–89). On merge, reconcile the journal — my earlier batch-3 entry sits
  in the shared `2026-06-13.md` (pre-R5-rewrite); fold it into per-session files.

## Related
[[art/imagine-prompts]] · [[characters/companions]] · [[story/bible]]


======================================================================
SOURCE: docs/sessions/2026-06-13-pixellab-fx-props.md
======================================================================

---
name: "Session 2026-06-13 — PixelLab FX & prop sprites"
date: "2026-06-13"
tags: [session, cycle-of-innocence, art]
branch: worktree-pixellab-fx-props
commits: []
---

# Session 2026-06-13 — PixelLab FX & prop sprites

## Focus
Replace primitive Polygon2D placeholders (campfire, dig spots, fog) with real
PixelLab sprites.

## What I did
*(newest first)*
- **Committed the user's editor pass + rebased FX on top + tamed FireLight**:
  extracted the user's uncommitted playground editor pass (poster→harmony_board_v2,
  glow removed, poster collision bumper, DeadTreeA2 rect collider) into a clean
  commit `feature/playground-editor-pass` off main, then rebased this FX branch
  onto it — scene auto-merged (editor pass touches the poster node, FX touches
  campfire/fog → no clash; only load_steps reconciled to 62). FireLight bloom
  reduced (energy 1.1→0.6, scale 1.5→0.95, now `@export`-tunable) so the new
  campfire sprite reads instead of washing out the hideout.
- **Campfire / dig spot / fog sprites via PixelLab** (suite 238, boot clean):
  swapped three sets of crude Polygon2D primitives for real art.
  - **Dig spot** (static): `create_map_object` dug-earth, palette-locked →
    Sprite2D `Marker` in `diggable_spot.tscn` (all 3 dig spots updated at once).
  - **Campfire** (animated): 9-frame `AnimatedSprite2D` (`campfire_frames.tres`)
    replacing the Stones/Flames/FlameCore polygons; `FireLight` PointLight2D
    kept for the warm glow. User picked PixelLab object `a8ee2399` over my
    auto-pick — swapped in.
  - **Fog** (animated): 9-frame drifting `AnimatedSprite2D` replacing
    FogSeamNorth/South polygons — kept the node names + a base `modulate.a` so
    `dread_beat`'s NodePath fade-in still works.
  - **FX palette exemption** recorded ([[art/prop-coherence]] rule 1): campfire
    (emissive) + fog (translucent) NOT palette-locked, like `toy_duck`.
  - Pipeline: `create_1_direction_object` → pick candidate → `animate_object`
    v3 (9 frames) → download frames → union-bbox crop + horizontal sheet →
    hand-built SpriteFrames `.tres` (AtlasTexture regions). Prompts in
    [[art/imagine-prompts]].
  - ⚠️ **Scene-merge note**: built off origin/main, so my playground scene edits
    (campfire/fog nodes) don't have the user's concurrent editor pass (poster→v2,
    glow removed, collision added — different nodes). Expect a `load_steps` +
    ext-resource reconcile at merge; my changes don't touch the poster node.

## Related
[[art/imagine-prompts]] · [[art/prop-coherence]]
