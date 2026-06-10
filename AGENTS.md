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

**Guardrails**: No reuse of the Mote/"Echoes of the Verdant Realm" cozy game (only low-level 2D patterns/pipelines). Every feature must serve story, a companion arc, a horror beat, or replay — otherwise cut/defer.

## Locked tech stack

- Godot **4.4.x standard build** (no .NET — C# breaks Web export), typed GDScript.
- **Dialogue Manager** (nathanhoad, `addons/dialogue_manager/`) for all branching dialogue — conditions/mutations read & write `PlayerData` directly. *(Replaced Yarn Spinner 2026-06-10; see `docs/decisions/2026-06-10-new-features-and-ai-setup.md`.)*
- **LimboAI** (`addons/limboai/`, v1.6.0 gdextension-4.4) for enemy/companion behavior trees + `NavigationAgent2D` pathfinding. **No runtime LLM calls in the shipped game** (offline mobile, latency, cost).
- **GUT** (`addons/gut/`, v9.4.0) for unit tests — run `bash tools/run-tests.sh` (headless). ⚠️ Addon versions are pinned to Godot 4.4; bump Godot and addons together.
- Art: 32×32 pixel (SNES/Zelda + horror), Grok Imagine → Aseprite cleanup → Godot nearest-filter import.
- Autoloads (current): `GameEvents`, `PlayerData`, `DialogueManager` (addon), `DreadManager`, `ZoneManager`; (planned): `CompanionManager`, `SaveManager`, `InputManager`.
- **PixelLab API** available for character/animation generation: key at `~/.config/pixellab/api_key` (NEVER in repo), client `tools/pixellab_api.py` (generate/rotate; free tier needs credits for generation). Decision: docs/decisions/2026-06-10-sprite-tool-pixellab.md.
- AI production stack: FOSS-first; see `docs/design/ai-production-setup.md`.

## Critical rules (R1–R6)

- **R1 — Branch first.** Never commit to main. `type/short-name` (`feature/…`, `fix/…`, `refactor/…`, `docs/…`). A PreToolUse hook blocks main commits.
- **R2 — Read before work.** This file + `docs/story/bible.md` + the relevant `docs/mechanics|design/*.md` before any feature work. Grep `docs/decisions/` for prior art; link findings with `[[backlinks]]`.
- **R3 — Vertical slices.** Every increment F5-playable. Slice definition below.
- **R4 — Imagine-first assets.** Character/companion bibles before sprite sheets; document every prompt in `docs/art/imagine-prompts.md`; Aseprite post-process; nearest-filter import.
- **R5 — Journal & capture.** Session journal `docs/sessions/YYYY-MM-DD.md` (newest first). Stray ideas → `docs/ideas.md` inbox, never dropped. Run `python3 ../scripts/obsidian/status.py` at checkpoints.
- **R6 — Commit & push.** After meaningful changes: commit on the feature branch and push to `origin` (github.com/tchintchie/**game** — the only repo; the rpg-adventure mirror was retired 2026-06-10, see `docs/decisions/2026-06-10-repo-consolidation-game-only.md`). The user merges to main. A public standalone repo will be split out when a demo is ready.

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
    ├── decisions/ · sessions/ · ideas.md · art/imagine-prompts.md
```

Conventions: typed GDScript; signals for decoupling (extend `GameEvents`); state machines for player/companions; no monolithic scripts; Resources for SpriteFrames/abilities. For Godot 4.4 typing: explicit types for Dictionary/Variant access (no `:=` inference there); don't access other scripts' vars by type — use signals.

## Working loop

1. Plan against the bible + mechanics docs (R2).
2. Implement in small F5-testable steps; agents are runtime-blind — run the game/tests, paste errors back, iterate.
3. Test: `bash tools/run-tests.sh`; manual F5 for feel. Humans tune balance/difficulty/dread — agents don't.
4. Asset work: prompts per `docs/art/imagine-prompts.md` style rules (32×32, limited palette, no AA, transparent bg; age/growth/corruption variants).
5. Close: journal, ideas, status, sync, commit (checklist above).
