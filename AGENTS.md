# AGENTS.md — Cycle of Innocence (Canonical Project Brain)

**This is the single source of truth for ALL AI tools** (Claude Code, Codex CLI, Grok CLI, Cursor) working on this project. Per-tool files (`CLAUDE.md`, `GROK.md`, `AGENT_RULES.md`) are thin shims pointing here. Rules live ONLY in this file; project *knowledge* lives in the Obsidian vault at `docs/` (story bible, mechanics, decisions, sessions). If you change a rule here, change it nowhere else.

## Communication style (every answer, every tool)

**Explain everything in plain language for a non-developer.** The reader has almost no coding or Godot knowledge — write so a smart beginner understands on the first read.

- **Lead with plain meaning**: what changed, what it means, and what to do next — in everyday words, before any detail.
- **Avoid jargon.** When a technical term is unavoidable, define it in a few plain words the first time (e.g. "the autoload — a script that's always running in the background").
- **Short sentences, concrete analogies** over implementation detail. Use small bullet lists, not walls of text.
- Keep deep technical detail **brief and clearly optional** — a short "Details" aside at the end, never the headline.
- Be honest in plain terms about what's done, what isn't, and what needs the human (e.g. "I can't see it run in the browser — you'll need to click it and tell me what you see").

This applies on **all** surfaces alike: Claude Code, the **claude.ai web Project**, Grok, and Codex. *(Mirror this into the web Project's custom-instructions field so it holds there too — the web side reads this file as knowledge, but its own instruction box is the most reliable place.)*

## Project identity

**Cycle of Innocence** — 2D top-down horror-conspiracy action-adventure RPG (Godot 4.4.x).

- Protagonist **Rowan**: escaped child sacrifice (selected via lottery / Community Harmony Score; ritual at the village playground with creepy clown "Playtime Guardians", stitched stuffed animals, living toys). Villagers initially believe the ritual succeeded — the "delayed alarm" drives escalation.
- **Animal companions are the found family and the mechanical party** — **TWO, by design** (decision 2026-06-21): Briar (hound, emotional heart, **owns the ground** — points to dig spots & secret doors, defends Rowan) and Echo (bird, knowledge, **owns the air** — scouts, warns of monsters from afar, aerial attack, finds hidden treasure, defends Rowan). Both companions' core job is to **defend Rowan**. **Storm (the mount) is CUT** — traversal is now a level-design problem, not a companion one. Bond/corruption per companion (two tracks). Human NPCs are secondary and untrustworthy.
- **The flute gates ALL monster interaction** (decision 2026-06-21): Rowan must find a flute/instrument before *any* soothing or allying is possible — it is the single key to the mercy/soothe system. Before the flute the only response to a monster is to **flee**, and **bare fists cannot harm monsters** (a real tool/weapon is required). See `docs/decisions/2026-06-21-companions-and-flute-gate.md`.
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
- **R5 — Journal & capture.** **Each session writes its OWN journal file** `docs/sessions/YYYY-MM-DD-<slug>.md` (slug = your branch/feature, e.g. `2026-06-13-footstep-surface.md`); newest entries first within your file. **NEVER append to a shared daily file or edit another session's file** — that shared-file append is what kept causing parallel-session merge conflicts (per-session files never collide). Read a whole day with `python3 tools/session_digest.py [YYYY-MM-DD]`. Convention: `docs/sessions/README.md`. Stray ideas → `docs/ideas.md` inbox, never dropped. Run `python3 tools/status.py` at checkpoints.
- **R6 — Commit, push & merge.** After meaningful changes: commit on the feature branch and push to `origin` — the **Forgejo** repo `home/cycle_of_innocence` (the single source of truth). Forgejo **auto-mirrors** every push to the private GitHub repo (off-box backup + what the claude.ai web Project reads). **Claude Code now merges to `main` itself** via the Forgejo API — `tools/merge_branch.sh <branch> "<title>"` (opens the PR if needed, waits until mergeable, merges; token at `~/.config/forgejo/token`, repo read/write, never in the repo). **Never commit to `main` locally** (R1) — the merge happens server-side via the PR, so `main`'s protection and clean PR history stay intact; after merging, sync local `main` (`git checkout main && git merge --ff-only origin/main`) and delete the merged branch. *(Workflow change 2026-06-20: previously the human clicked merge on the web UI. The human still owns the R7 web "Sync now".)* *(This repo was split from the `tchintchie/game` monorepo `test/` on 2026-06-17; see `docs/handbook.md` for the loop.)*
- **R7 — Research bridge & web sync.** The claude.ai web Project "Cycle of Innocence" reads the **GitHub mirror via the official GitHub integration** (the only sanctioned path — never ClaudeSync/session-key tools). Keep it current at session close via `/reflect`: refresh `STATE.md` (root) + the session journal, push to Forgejo, then click **Sync now** in the Project and verify the commit hash in `STATE.md` matches your push. Curate the Project's knowledge to **< 13 files** (STATE.md first) so it stays in precise mode, not RAG. Web research returns ONLY via the `docs/research/` inbox → librarian pass (propose-first; locked decisions get flags, not edits). Convention: `docs/research/README.md`. *(Legacy: `docs/_compiled/` snapshots + manual upload are superseded by the GitHub integration.)*

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
