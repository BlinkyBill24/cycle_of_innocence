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

1. **Structured playtest/feel pass**: clock pacing ("urgency without anxiety treadmill"), interface-horror frustration ceiling, suspicion→alarm tuning, plus slice-gate leftovers (stem overlap, darker dread, bark visibility). Recruit 3–5 outside testers via the NAS/itch web build.
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
