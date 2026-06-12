# Project State & Roadmap — canonical brain (AGENTS.md), roadmap, ideas inbox, latest session journals
> GENERATED 2026-06-12 by tools/compile_snapshots.py — do NOT edit (not here, not in claude.ai). Source of truth is the Obsidian vault in the game repo; this file is replaced wholesale at milestones.
> Sources: AGENTS.md, docs/plan/playtest-protocol-2026-06.md, docs/plan/slice-implementation-roadmap.md, docs/ideas.md, docs/sessions/2026-06-12.md, docs/sessions/2026-06-11.md


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
- Autoloads (current): `GameEvents`, `PlayerData`, `DialogueManager` (addon), `DreadManager`, `ZoneManager`, `WorldState`, `HollowingClock`, `VillageState`, `SaveManager`, `Sfx`, `AdaptiveAudio`; (planned): `CompanionManager`, `InputManager`.
- **PixelLab API** available for character/animation generation: key at `~/.config/pixellab/api_key` (NEVER in repo), client `tools/pixellab_api.py` (generate/rotate; free tier needs credits for generation). Decision: docs/decisions/2026-06-10-sprite-tool-pixellab.md.
- AI production stack: FOSS-first; see `docs/design/ai-production-setup.md`.

## Critical rules (R1–R7)

- **R1 — Branch first.** Never commit to main. `type/short-name` (`feature/…`, `fix/…`, `refactor/…`, `docs/…`). A PreToolUse hook blocks main commits.
- **R2 — Read before work.** This file + `docs/story/bible.md` + the relevant `docs/mechanics|design/*.md` before any feature work. Grep `docs/decisions/` for prior art; link findings with `[[backlinks]]`.
- **R3 — Vertical slices.** Every increment F5-playable. Slice definition below.
- **R4 — Imagine-first assets.** Character/companion bibles before sprite sheets; document every prompt in `docs/art/imagine-prompts.md`; pixel post-process (scripted or GIMP/Pixelorama — no Aseprite); nearest-filter import.
- **R5 — Journal & capture.** Session journal `docs/sessions/YYYY-MM-DD.md` (newest first). Stray ideas → `docs/ideas.md` inbox, never dropped. Run `python3 ../scripts/obsidian/status.py` at checkpoints.
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
3. Test: `bash tools/run-tests.sh`; manual F5 for feel. Humans tune balance/difficulty/dread — agents don't.
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
- Quirk journal UI: let the player pin one observed line per discovered quirk (companion-quirks.md diagnosis loop) — fold into the interface-horror/UI pass.
- Plateau discovery cue: when generic soothe stalls at 60, the monster could glance toward its buried key (environmental hint without UI).
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
SOURCE: docs/sessions/2026-06-12.md
======================================================================

---
name: Session 2026-06-12
date: 2026-06-12
tags: [session, cycle-of-innocence]
branch: feature/research-bridge
commits: []
---

# Session 2026-06-12

## Focus
Web research bridge: shared brain between the claude.ai Project (research) and
Claude Code (implementation), adapted from the user's space-game design system.

## What I did
*(newest first)*
- **Tester-03 follow-up** (branch `fix/playtest-tester03`, 195/195): the
  fix→verify loop works — soothe now "haunted" (was broken ×2), danger stem
  "really good" (was reggae ×2). Two new defects fixed: (1) danger layer
  ignored threat state (played after Stilled + in daylight) → new pure
  `cap_layer` gate (danger needs an un-stilled enemy ≤220px or stage ≥2;
  bright day without threat → ambient), tests updated with a threat fixture
  (learned: `bool(null)` has no constructor — null-safe Variant compares);
  (2) gossip text + villager "!" were occluded by y-sorted world →
  z_index 200 absolute. Synthesis headline (3/3 testers, defects excluded):
  **content drought, not systems** — "nothing to do except waiting for
  sounds"; next dev arc = early-game authored beat + doom legibility
  world-visuals; combat feel/SFX, Briar telegraphs, villager brush-off
  interactions captured. Tester-04 should be a new person, 30–45 min.

- **Danger stem v2 swapped in** (branch `fix/danger-stem-swap`, 194/194):
  downloaded the user's makebestmusic.com track (share page embeds the MP3
  publicly), converted MP3→OGG via a venv `soundfile` (no ffmpeg on box),
  RMS-matched to the old stem (×1.58) with peak limiting, replaced
  `playground_danger.ogg`; raw MP3 archived in `stems/raw/`, provenance in
  [[art/audio-prompts]]. Caveats noted: untrimmed loop seam + still not an
  aligned stem — audio content sprint still owns the real fix. The "reggae"
  v1 is gone for test run 3.
- **Tester-02 follow-up — two defects fixed for run 3** (branch
  `fix/playtest-tester02`, 194/194): (1) the village "crash" root-caused —
  `village_tileset.tres` declared 4 dirt-variant tiles vs the curated
  1-tile texture; the 3 out-of-texture tiles errored exactly when the
  village scene loaded and the EDITOR paused on it (native play = strictest
  runtime; my CLI auto-walk repro sailed past). Tres + generator fixed,
  regression test added. (2) SoothePrompt hint was invisible/misplaced
  (degenerate preset/grow rect — t02 saw it behind the hearts) → explicit
  bottom-center anchors, verified by in-game screenshot. Captured
  tester-02 verbatim; synthesis updated — **audio threshold FAILED 2/2**
  (identical "reggae" wording): stem regen (human, ACE-Step) promoted to
  before-any-tuning. Repro tooling: temporary auto-walk autoload (skip name
  entry, click dialogue during CUTSCENE, steer west) — removed after use.
- **First real playtest data + soothe affordance fix** (branch
  `fix/playtest-tester01-followup`, 193/193): tester-01 (SJ, ~5 min)
  captured verbatim in `docs/playtest/2026-06/tester-01.md` + running
  [[playtest/2026-06/synthesis]]. The Q3 "broken" verdict was a genuine
  defect, fixed now: **`SoothePrompt`** (CanvasLayer 15) — "HOLD E — sing to
  it" near a spareable monster, recognition bar while holding (plateau stall
  at 60% becomes visible = free discovery hint), hidden in dialogue; the
  hold verb previously had ZERO on-screen communication outside the
  tester-disabled debug HUD. Early signals (await n≥3 per protocol): danger
  stem reads as **reggae** (`playground_danger.ogg`/`playground_tense.ogg` —
  human regen, raises audio-sprint priority), first-5-min pacing ("want to
  see something happening" → authored early dread beat, content not knobs),
  night 2/5 (second strike on darker-dread). Positives: choices 5/5, opening
  atmosphere praised. Clock/doom answers marked n/a (5-min session never
  reached stage 1) — enforce session length for testers 02+.
- **Playtest protocol + prop rework round 2** (branch `fix/prop-rework`):
  (1) [[plan/playtest-protocol-2026-06]] drafted — session script (5 beats,
  ends on the stage-0→1 bell = demo ending validation), silent-observation
  checklist, verbatim debrief, pass/fail thresholds mapped to tuning knobs,
  per-tester capture template under `docs/playtest/2026-06/`; linked from
  roadmap arc 1. Debug HUD OFF for testers. (2) User feedback "cottages/
  houses + playground props/trees look off": playground props palette-locked
  (were 100% off-palette like the village; **toy_duck exempt** — authored
  saturation rule). Buildings regenerated after all — inpainting at the
  placement-spot crop answers the foundation-fight concern (foundation is in
  the crop): cottage_a/b/dark + chapel + 2 dead trees, all canon view,
  palette-locked, **gated PASS**, staged as candidates. New buildings are
  TALLER than the old slabs → placement/colliders = user editor judgment.
  Also committed the user's village collider audit (item 7 progress).
  PixelLab: ~7 generations; v2 status GET endpoint 404s — poll via MCP
  get_map_object, not the REST status URL.
- **Gated candidates placed** (branch `fix/place-gated-candidates`,
  191/191): village_green.tscn retargeted to the four gated candidates
  (bench, harmony_board, lantern_post ×4 instances, market_stall) with
  base-anchored sprite offsets (board −10 px height, lantern +2 px;
  bench/stall same height = pure swaps); UIDs from the candidate imports.
  Composite-at-scene-anchors sanity check looks right. Remaining for the
  user: item-7 editor audit incl. collider verify on board/stall (footprint
  width changed) + well-collider nudge. Preview mock left on old paths
  (editor is placement truth; mock approximates).
- **Gate-validation note integrated (§1–4, §6)**: rule 5 gained the
  shipped-instrument spec (qa_overlay_128 ellipse/box dimensions + legend +
  gate_sheet.py), the **iconic-prior props** addendum (angle in description
  content; empirics: param-only 0.51 FAIL → prior-busting PASS roll 1), the
  **gate instrument note** (horizontal circles, not roofs, are the pitch
  instrument), and the **edge-canon candidate closed** (edges empirically
  clean — no defringe step). Fix plan: items 1–6 all closed; item 7 (editor
  audit + place gated candidates + well-collider nudge) is the only open
  item. **§4 Aseprite sweep**: no Aseprite installed — AGENTS.md (art line +
  R4), ai-production-setup, roadmap matrix now say scripted/GIMP/Pixelorama;
  history untouched; auto-memory corrected too. §6 reconciliation: its "pin
  reference crops still open" was stale — closed in b506284; the web side
  read a pre-close-out snapshot (self-corrects on merge + re-upload).
- **Gate-validation work order executed** (§5 of the new inbox note; §1–4/§6
  integrate at the next librarian pass): (1) well regenerated with the
  prior-busting description (cylinder side visible, rim = thin ellipse) at
  its actual placement-spot crop — **PASS on roll 1**, no depth-i2i needed;
  the iconic-prior diagnosis was right. (2) New `tools/gate_sheet.py` —
  editor-less rule-5 gate: qa_overlay_128 composited onto candidates/ at 4×
  NN into one contact sheet. (3) Remaining village props batch-regenerated
  at their placement-spot crops (bench, lantern_post, harmony_board,
  market_stall), palette-locked, staged, **all gated PASS** before
  placement. Also committed the user's editor swaps (well_v2/fence_v2 in
  village_green.tscn) + the web-generated QA overlay artifacts. ⚠️ well_v2
  was replaced in place (44×51 vs 54×60) — collider may need a nudge in the
  editor.
- **Projection canon close-out** (researcher's next-steps, same branch):
  lint extended to the `tile_view` key spelling (negative-tested);
  ratio-glance audit of the two legacy height-cue assets — terrace/cliff
  tileset PASS, chapel roof PASS (no depth-i2i rework needed, recorded in
  rule 5); canon reference crops pinned (`assets/reference/
  canon_view_character.png` = Rowan south idle cell, `canon_view_prop.png` =
  canon well) closing the imagine-prompts TODO. Remaining user tasks: editor
  pass (place candidates, item-7 audit) + QA overlay layer in Aseprite.
  Bitforge OpenAPI check deferred until the fallback is actually needed
  (captured in ideas). Next dev arc: structured playtest/feel pass — prop
  coherence is maintenance-mode behind the gate.
- **Projection canon integrated** (branch `feature/projection-canon`): new
  **Rule 5** in [[art/prop-coherence]] — one camera, **low top-down ~20°
  "Zelda perspective"**, cheated oblique, view ALWAYS explicit (PixelLab
  per-tool defaults differ: map tools 35°, character tools 20°). Local
  verification flipped the research's history: every production script
  already pinned low top-down — the only drift ever was MY same-day
  candidates (generated high top-down through the viewless item-6 recipe).
  Both regenerated at canon view + palette-locked + restaged (the canon well
  is visibly correct: flat rim ellipse, front face, verticals vertical).
  Enforcement: `CANON_VIEW` in pixellab_api.py + `check-brain.sh` lint
  (negative-tested) — off-canon views in tools/ now fail the drift check
  unless `# canon-override:`-commented. Workflow additions: variants via
  `create_object_state` (never fresh), depth-i2i geometry lock, canon ratio
  table + QA overlay gate. Prompt templates A/B/C in [[art/imagine-prompts]]
  (+ user TODO: pin reference crops). Ideas: QA overlay art task, bitforge
  fallback params unconfirmed. Rejected (vault stance upheld): edit_image
  prop extraction (rule-2 violation).
- **Prop-coherence items 4–6 + debug HUD** (branch
  `feature/coherence-pass-debug-hud`, 191/191): Debug readout moved off the
  world and onto a `CanvasLayer` (layer 101, above dialogue) anchored
  **top-right**, font 9 + black outline, grows leftward — always on screen
  now (it was a world-space label that scrolled away; verified with a real
  X11 game capture). Item 4 verified already covered (`PropShadows.apply`
  runs in both zones; village buildings on baked foundations — research
  screenshots were stale). Item 6 smoke test PASSED: `create_map_object`
  with a backdrop crop works (no 500); style/projection inherited, palette
  partial → palette-lock every result; size control = crop size × oval
  fraction; recipe recorded in [[art/prop-coherence]]. Item 5 partial:
  new well + fence candidates generated against real ground crops,
  palette-locked, staged in `assets/sprites/village/candidates/` for the
  user's editor placement pass (buildings deliberately NOT regenerated —
  the palette lock + baked foundations already ground them).
- **Prop-coherence fix plan items 2–3** (branch
  `fix/zone-coherence-camera-palette`, 189/189): (2) `ZoneRoot` now clamps the
  player Camera2D to the `GroundBackdrop` rect (+16px bleed) on zone enter —
  pure static funcs `sprite_world_rect`/`camera_limits`, unit-tested; zones
  without a backdrop reset limits so clamps can't leak across transitions.
  (3) New `tools/palette_lock.py`: all 10 village props were **100%
  off-palette** (confirming the research) and are now quantized to the
  backdrop's 48 colors — before/after on real ground verified visually; cool
  accents went warm (palette has no cool colors; item-5 regen if any prop
  reads muddy in-game). Test debugging: code-added Camera2D gets an @-mangled
  name (test must set `name`); ZoneRoot's deferred calls must be drained
  before autofree; ZoneManager state restored in before/after_each — an
  unflushed deferred had broken `test_zone_manager` mid-suite.
- **Art-tooling research integrated** (screenshot review + Grok cross-check):
  verdict — compositing gap, not tooling gap; whole stack reaffirmed. New
  [[art/prop-coherence]] (rules: palette hard-lock to zone backdrop, flat
  neutral light, scale chart, shadow-canon split; gated `create_map_object`
  workflow + PROPS-ONLY edit_image as benchmark-only) and prop authoring rules
  appended to [[art/imagine-prompts]] (lamp/fence/well ratios PROVISIONAL).
  Local verification corrected the plan: courtyard decals already gone from
  all scenes (screenshots were stale vintages) and Camera2D limits confirmed
  missing (the grey-void fix is real). Roadmap: next-arc 5 = village zone
  coherence conversion, with ordering note (camera clamp + palette pass
  arguably before the external playtest). Ideas-rejected: extra art vendors
  (Ludo/Leonardo/MJ). Lullaby-as-tense-motif was already canon — no action.
- **Research round 3 integrated** (outside-view audit + market/tech): new
  decision [[decisions/2026-06-12-adaptisound-rejected]] (README: no web
  export — re-verified locally; hand-rolled AdaptiveAudio canonical;
  [[mechanics/adaptive-audio]] status corrected planned→implemented) and new
  **proposed** decision [[decisions/2026-06-12-steam-timing]] (USER CALL:
  Coming Soon late 2026 + 2027 Next Fest demo if 2027 is plausible — wishlist
  lead time compounds). New [[design/market-positioning]] (draft): F&H-wave
  counter-positioning ("Undertale's mercy in Silent Hill's village — and you
  grow up inside it"), capsule rule (sell horror tone, never retro-RPG), demo
  ends on the stage 0→1 bell, platform split (Web=shop window, Android=mobile
  product, Steam=revenue) + verified Godot web-export facts. Roadmap gained
  "Next arcs" (playtest pass w/ external testers → audio content sprint →
  playground recontext authoring → Steam decision) + the scope rule:
  content-complete per zone before any new mechanic. Ideas: external-playtest
  cadence every arc. Round verdict: hold locks, stop building systems, start
  filling them.
- **First inbox round-trip (bridge verified)**: the §B4 verification answer came
  back grounded — every cited number/rule checked out against the vault, and it
  correctly treated the no-timer-UI presentation rule as locked. Librarian pass
  integrated its three new ideas into the docs: **doom legibility roadmap** in
  [[mechanics/hollowing-clock]] (bell pattern language, stage-keyed poster
  swaps, journal of observed signs, flagged anti-pattern: no always-on
  diegetic-skinned meter; corruption-spread stays parked), stage-keyed
  recontext-group variant noted in [[mechanics/zone-recontextualization]],
  observed-signs journal added to the Growth/Memory screen in
  [[mechanics/progression]]. Inbox file stamped with provenance and moved to
  `research/done/`; snapshots recompiled.
- **Research bridge built** (branch `feature/research-bridge`): adapted
  [[setup-guide]] from the space-game system to this project (no vault
  restructure, git stays active). New `tools/compile_snapshots.py` → 4
  replace-only snapshots in `docs/_compiled/` (story-compendium,
  mechanics-compendium, decisions, state-and-roadmap incl. AGENTS.md + latest
  journals) for upload as claude.ai project knowledge. Return path:
  `docs/research/` inbox (provenance frontmatter + [verified]/[training
  knowledge] markers, convention in `docs/research/README.md`) → librarian
  pass → `research/done/`. New **R7** in AGENTS.md anchors the loop;
  `check-brain.sh` now exempts the generated `docs/_compiled/` from stale-term
  checks. Decision: [[decisions/2026-06-12-web-research-bridge]].
  **User to-do**: create the claude.ai Project per setup-guide §B4 (instructions
  text ready there), upload the 4 snapshots, run the §B4 verification question.
- Pulled merged `chore/import-uids` into main; deleted the local branch.
  Established that the greenlit post-slice feature queue is complete — next-arc
  candidates: playtest/feel pass (recommended), story/content pass, Echo
  companion, inventory loop.

## Next session
- User: claude.ai Project setup (setup-guide §B4) + snapshot upload; first
  research run through the new loop as a smoke test.
- Then: structured playtest + feel pass (audio stem overlap, darker dread,
  bark visibility — slice-gate leftovers), which picks the next dev arc.

## Related
[[setup-guide]] · [[decisions/2026-06-12-web-research-bridge]] ·
[[sessions/2026-06-11]]


======================================================================
SOURCE: docs/sessions/2026-06-11.md
======================================================================

---
name: Session 2026-06-11
date: 2026-06-11
tags: [session, cycle-of-innocence]
branch: docs/session-close-2026-06-10
commits: []
---

# Session 2026-06-11

## Focus
Playtest fixes (dialogue input leak, stilled-child dig steal, Briar pronoun) + name entry at game start. Earlier: close-out of the long 2026-06-10 session (spanned midnight).

## What I did
*(newest first)*
- **Backdrop art direction LOCKED** (branches `feature/playground-backdrop` + terranigma-pass follow-ups, 184/184): user feedback killed tile-variant scatter ("stickers") and the courtyard scene-decal in favor of the production model that works — **painted ground backdrops + individually cropped collision props on top**. Pipeline: painter layout → geometry guide (building footprints darkened) → Grok `edit_image` repaint (GROUND ONLY) → LANCZOS fit + 48-color quantize → one backdrop Sprite2D above the tilemap. Both zones converted; village buildings sit on baked worn foundations (shadow ellipses removed ≥96px sprites — they caused floating; glow_radial has no alpha so shadows are procedural now). Playground east went cold-blue — the bible's warm/cold contrast for free. User now places props/hitboxes in the Godot editor (StaticBody2D=walls vs Area2D=detectors — terrace walls re-homed from the user's Area2D to Borders). Editor is source of truth for placement; mocks approximate from here.
- **Terranigma pass** (branch `feature/terranigma-pass`, 184/184): all four art-direction levers — (1) variation tiles via `create-tiles-pro` style-anchored on our OWN ground tiles (TilesProStyleImage = raw base64+w+h; results embedded as rgba_bytes in the job payload, storage URLs 403; curation filter keeps full-coverage palette-close tiles — wood-plank impostors rejected), 6 grass variants ~28% scatter + stones-only dirt ~7%; (2) terrace rim via grass→cliff tileset (transition-as-elevation as a FEATURE), yards shifted, DIRT/TERRACE separation tested; (3) organic lanes — sine wobble + hash-frayed edges; (4) painted set-piece: Grok scene → `image-to-pixelart-pro` → chapel courtyard ground decal (lanterns/flower beds/paving/bench — the quality benchmark). Also: prop blending fixes (desaturation toward ground palette + procedural contact-shadow ellipses — glow_radial has no alpha falloff, black-modulate = rectangle).
- **Village furnished + FF7 dialogue + tier-2 pipeline** (branches `refactor/pixellab-tier2`, `feature/village-polish`, `feature/ff7-responses`, 181/181): PixelLab upgraded to tier 2 → slot-aware job pool (`pixellab_jobs.py`, 8 in flight), parallel runner; village tilesets + all 10 props rendered. User reference (farming-village sheet) → ALL village paths are packed dirt (cobble shelved — create-tileset models transitions as ELEVATION; reference-image params 500 server-side, working style-ref path is generate-with-style-v2/bitforge). Village furnished via `place_village_props.py` (guarded one-shot) + `preview_village_map.py` mock. Caught-eavesdropping ×2.5 notice rate. Dialogue: choices now INSIDE the box FF7-style (box grows only for choices); bugfix — moving the menu left the `response_selected` [connection] on the old path, choices fired into the void (regression test asserts wiring + story-flag advance). Villagers-invisible-on-web fixed earlier the same way (frames as root @export — child overrides die in binary scene conversion). Local web workflow: `tools/serve_web.py` (NAS down).
- **Zone recontextualization v1** (branch `feature/zone-recontext`, 174/174): the knowledge-gated-world mechanism from [[mechanics/zone-recontextualization]] — `recontext_<revelation_id>` groups toggle visibility+collision+processing on zone enter and live on unlock (`recontext_not_*` inverts). New `WhisperSpot` (one-shot world line, story-flagged, optional dread). First authored moment: post-`monsters_are_children` the sandbox whispers about the handprints (+8 dread). Also: web build exported to `exports/web/` (NAS deploy awaits user go-ahead — permission gate).
- **Warden search detail** (branch `feature/warden-search`, merged): `STAGE2_STARTED` routines — Warden Oslo only exists from hollowing stage 2, sweeping playground markers with a wide lantern radius. The village comes looking.
- **Village green zone + real transitions** (merged): ZoneManager scene switching with `entry_from_<zone>` gate placement (return-gate + companion-teleport playtest fixes), Wang-painted village scene with markers/villagers/eavesdrops, placeholder ground atlases until renders land.
- **Village-life core + villager art** (branches `feature/village-art-bibles` + `feature/villager-sheets`, 162/162): Grok bibles for 4 human archetypes (farmer parent w/ head-swap corner, Warden, Elder "Father Aldwin" — rerolled European-rural, kept the embroidered lottery numbers — and the bright village child) + village-at-sunset mood anchor; prompts + moderation notes in [[art/imagine-prompts]]. PixelLab `create-character-pro` ×4 with the LIVE in-game Rowan cell as style ref (v1 adults had black backdrop slabs — `style_description` negative fixed it, same as the Briar redesign). While walk/idle anims rendered (trial tier = 2 slots; first 16-job flood failed server-side, requeued sequentially): built the village-life core — `VillageState` autoload (5 authored villagers × 4 slots, stage-2 hardening, stage-3 stopped routines, suspicion→alarm once per villager, time decay, stage-keyed gossip with intel lines, save round-trip), `Villager` NPC (walks slot markers via `marker_<name>` groups, notices Rowan → suspicion, absent when its marker isn't in the zone), `EavesdropZone` (floating ambient gossip, no input lock).
- **Interface horror v1 + plaza spawn** (branch `feature/interface-horror`, 150/150): the queued fourth-wall feature ([[mechanics/interface-horror]], status → implemented). (A) Control degradation: `DreadManager.interface_pressure()` (pure rule: dread ≥85 or morality ≥70 ramp ×intensity, HARD-off below 0.4 intensity); player spikes = 0.8–2s of 1–3 frame input lag + one eaten attack press + walk hitch, 9s cooldown, FPS<45 skip, frozen in cutscenes. (B) Dialogue distortion: Vessel-tier variants in escape_food — the spoken line comes out wrong (`[shake]`+violet cue, always visible), Briar reacts to what was said; mutations identical, agency intact. Also: spawn moved onto the ritual plaza (Rowan wakes at the site), and `PlayerData.spawn_position` is now actually set (scene spawn initially, hideout rest re-anchors it — death previously teleported to (0,0) on the path).
- **Playground cluster** (branch `fix/playground-prop-cluster`, playtest feedback): props were scattered across the map — now ONE scene. Sand patch enlarged into the plaza (vertex rect (-16,-9,10,5), still a full WARM row clear of the path band), all equipment stands ON it (swing/slide/roundabout), totems stake its SW/NE edges, the duck moved out of the fringe onto the sand — landing right beside the relocated `playground_buried_toy` dig spot (now at the sandbox, where the soothe-key story always said it was). Mock PROPS table kept in sync.
- **Zone art: props + y-sort** (branch `feature/zone-art-props`, 139/139 + headless boot smoke): 8 props via `create-image-pixflux` (~7¢, `tools/pixellab_props.py`): rusty swing set (one seat dangling), leaning slide, rusted roundabout, stitched bear/rabbit totems on stakes, two dead-tree variants, the wooden duck (kept innocently bright — toys stay saturated while the world drains). Placed as `StaticBody2D`+`Sprite2D` with base-anchored collision in a new y-sorted `World` container (Player/Briar/TwistedChild reparented; emergency-child spawn follows). Duck sits by the keepsake in the deep fringes. Mock preview now overlays props (`PROPS` table mirrors the tscn). Learned: pixflux minimum canvas is 32×32.
- **Zone art: real terrain tilesets** (branch `feature/zone-art-tilesets`, 139/139): replaced the 5 flat placeholder ground tiles with four PixelLab Wang transition tilesets (`/create-tileset`, 32px, 16 tiles each, ~6¢ total): playground grass→path, cold grass→dead floor, grass→ritual sand, and a warm→cold grass blend for the fringe seam. New `tools/pixellab_tilesets.py` (queue/status/download orders tiles by corner bitmask + sidecar corner map), `tools/gen_zone_tileset_tres.py` (builds the 4-source TileSet), `tools/preview_zone_map.py` (full-zone PNG mock = approval artifact, mirrors the GDScript painter exactly). `playground_fringes.gd` repainted via corner-vertex Wang fields (pure static funcs, unit-tested: no cell ever mixes terrains without a transition set; path dies 2 vertices before the fringe seam — village reach ends, a free dread beat). Learned: `create-tileset` reference images 500 server-side; color_image must be exactly 64×64; first grass_blend rendered the transition as dirt (rerolled with "no soil" wording); sin*cos blobs → periodic crosses, block-hash → 90° slabs, settled on smoothed value noise.
- **Animation audit + gap fill** (branch `feature/anim-gap-fill`): audited every animation the code can request vs the three sheets — all 37 existed, but two were never played and two quirks had no visual. Wired Rowan's `hurt` (was red-flash only) and the dominated thrall's `lunge` (was walking through its strikes, new `_thrall_lunge_anim` hold). Generated two new Briar animations via the PixelLab v2 pipeline (`animate-character` v3, character 372cf8d9): 4-dir `stare` (long-stare quirk now stares instead of sitting) and `dusk_press` (dusk bond quirk now leans into Rowan's legs; head_bump fallback). New `_pose_hold` keeps quirk poses from being overwritten by locomotion. Prompts documented in [[art/imagine-prompts]]. Also registered the PixelLab MCP server (`claude mcp add pixellab`) for future sessions.
- **Creature glued to player after lunge** (same branch, 130/130): at the 60%-recognition plateau the creature creeps to the standoff ring while the player is locked soothing; the post-release lunge always ends at body contact (player r10 + enemy r8 = 18px) which is INSIDE the standoff band (22.1px) — the old logic froze there and every following lunge was point-blank, so it never detached. `_chase_update` now backs out to the hover ring whenever closer than 0.8×attack_range before it may bite again (with a pinned-against-wall exception so it can't be cornered into harmlessness). Regression-tested both directions (backs out at contact / still attacks from the ring).
- **Compact dialogue balloon + ROWAN name bug** (branch `fix/name-replacement-and-balloon`, 128/128 tests): playtest follow-up — (1) custom name showed as ROWAN: the `{{PlayerData.custom_name}}` replacement itself works; my "verification" test had never actually run because GUT silently skips test scripts whose `class_name` isn't in the stale global class cache (headless runs don't reimport) **while still reporting all-green**. `tools/run-tests.sh` now runs `godot --headless --import` first and hard-fails on "Ignoring script"; new end-to-end test asserts the balloon's speaker label shows the chosen name. The in-game ROWAN was the same staleness: the compiled .dialogue from before the merge — self-heals once the editor reimports. (2) Dialogue box took half the screen: new project-owned compact balloon `scenes/ui/dialogue_balloon.tscn` (108px tall vs 219, font 14 vs 20, side insets, thin subclass of the addon's balloon script — addon untouched); `StoryDialogue` uses it and `dialogue_manager/runtime/balloon_path` makes it the project default.
- **Playtest fixes + name entry** (branch `fix/playtest-dialogue-dig-gender`, 120/120 tests): (1) post-dialogue punch — Space closes the balloon AND is bound to attack; added a 0.15s input-grace window when leaving CUTSCENE/DREAD_LOCK (`player_controller.gd`). (2) "dog refuses to dig" — root cause was the Stilled child's lead behavior calling `reveal()` itself on arrival at the keepsake; it now stops *beside* the spot (arrive distance 20) and waits, leaving the dig + bond reward to Briar; plus Briar answers a dig request on already-dug earth with a soft bark + hop (`signal_nothing_to_dig`) so silence never reads as a bug ([[mechanics/encounters-mercy]] updated). (3) Briar pronoun: last stray "she" code comment fixed — he's male everywhere ([[characters/companions]] already had him male). (4) Name entry at new-game start: `NameEntry` CanvasLayer (flag `player_named`, never asks twice, save round-trip tested), `StoryDialogue.wait_for_flag` gates the intro dialogue, and `escape_food.dialogue` speaker is now `{{PlayerData.custom_name}}` (Dialogue Manager character replacements, covered by test).
- **New sheets live in-game**: assembled 48px-cell sheets (60px pro canvas would amputate lunges at 32) via API-driven folder auto-mapping (`animation_type` + `animation_group_id[:8]` suffix = ZIP folder; `PRO_GROUP_PINS` disambiguates rerolls); Briar sit + lie_down rerolled (lying reads only in side view at this scale), growl west re-queued after a dropped render. Rowan 14 rows (real 4-dir idles), Briar 14 (growl ×4, lie_down, head_bump), Twisted 9 (hurt, crumble, duck-dragging walks). Verified with rendered X11 capture; 114/114; total PixelLab spend this pass ≈ $1.20.
- **Character redesign + animation expansion** (branch `feature/art-character-redesign`): rebuilt all three characters with PixelLab `create-character-pro` — Grok bible crop as concept + crisp Grok-pixel-sheet cell as style reference, 8 directions, ~$0.10 each (total spend so far ~$0.50 of $8 balance, no top-up needed). User approved all three. Queued full animation batch incl. NEW: Briar growl ×4-dir/lie_down/head_bump/sit, Twisted hurt/crumble. Game code already wired behind has_animation guards (directional growl on pings, lie-down calm anchor, head-bump, crumble). 114/114.
- **Companion quirks** (branch `feature/companion-quirks`, 114/114 tests): authored quirk catalogue + threshold acquisition on PlayerData; Briar's pool of 4 live (scent growl TRUE ping / long stare → head-bump when bond earned / phantom guard FALSE ping / dusk press comfort); Empath insight tell rule (Innocent+bond sees which growls are real, Vessel sees nothing); quirks freeze in dialogue, persist in saves, new growl SFX; debug label lists acquired quirks.
- **Hollowing clock** (branch `feature/hollowing-clock`, 101/101 tests): `HollowingClock` autoload — 5 stages, story milestones + Alarm noise (kills/betrayal/domination accelerate, stilling delays), queue rule (never mid-dialogue/hideout), bell+whimper+dread on each stage. Consequences: Frenzy un-stills all Stilled monsters (the designed mercy-undo, no betrayal cost), Alarm spawns the unsaveable emergency-ritual child in the deep fringes, night floor +5/stage, detection +10%/stage. Saved/loaded; debug key H; dialogue can gate on `HollowingClock.stage`.
- Session close: refreshed the stale "Next session" plan in [[sessions/2026-06-10]] (Yarn-Spinner / rpg-adventure-mirror era references removed), flagged the two redundant remote branches behind closed PR #35 for the user to delete on GitHub (`feature/art-pixellab-batch`, `feature/pixel3d-pipeline` — both fully cherry-picked/superseded on main), updated auto-memory with post-slice progress.
- Merged by user today/overnight: PR #37 (world-loop playtest fixes: action-driven time, betrayal-on-hit, real load/reset) and PR #38 (full mercy: soothe keys + plateau, Briar aura, Stilled leading, Domination). Suite at 89/89.

## Next session
- **Interface horror** (docs/mechanics/interface-horror.md) — next in the post-slice order; then village life → zone recontextualization.
- Zone art pass remains unblocked.

## Related
- [[sessions/2026-06-10]] · [[mechanics/encounters-mercy]] · [[mechanics/hollowing-clock]]
