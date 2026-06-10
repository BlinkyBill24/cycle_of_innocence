# Cycle of Innocence — Grok Build Project Memory

Persistent context for **Grok Build** sessions on this Godot 4.x 2D top-down horror-conspiracy action-adventure RPG.

**Parent monorepo rules**: see `../CLAUDE.md` (branching `feature/...`, Obsidian vault at `../docs/` + this local `docs/`, R3 consult before design, session journals, ideas capture, `python3 ../scripts/obsidian/status.py`).

**Approved build plan**: See the full phased plan in the active Grok session (or the decision doc created from it in `docs/decisions/` or promoted to `../docs/decisions/`).

## Project identity

| Field              | Value |
|--------------------|-------|
| Title              | Cycle of Innocence (working title) |
| Theme              | Escaped child sacrifice grows up inside a generational conspiracy; raises animal companions that can be nurtured, broken, or corrupted |
| Folder             | `test/` (active dev root per clarification) |
| Godot              | 4.x (4.4+), GDScript (typed) |
| Tiles / Art        | 32×32 base, retro pixel (SNES/Zelda + horror atmosphere), Grok Imagine + Aseprite |
| Movement           | 8-direction `CharacterBody2D` real-time action |
| Combat             | Real-time action (Zelda + Secret of Mana inspired) with light companion assists |
| Companions         | Animal only (dog/hound, bird/raptor, horse/stag etc.) — rescue, raise, bond, possible corruption |
| Progression        | Age stages (child → teen → adult) + morality/alignment + companion bond/growth/corruption |
| Narrative          | Yarn Spinner (branching, variables for age/morality/bonds/revelations) + deep AoT-style twists |
| Structure          | Semi-open zones (not strict small rooms) |
| Difficulty         | Fair but tense; child sections feel vulnerable |
| Platforms          | Linux (primary), Android (touch), Web/HTML5 |

**Explicit guardrails** (from user revision + plan):
- **No re-use of the Mote / Echoes of the Verdant Realm** game (cozy 3D puzzle). Only low-level 2D engine patterns, touch/export/pixel pipeline, autoloads, and Imagine import tools are adapted.
- Protagonist **is an escaped child sacrifice** (inciting incident + core of all reveals).
- **Animal companions are the primary emotional and mechanical "party"** (raising, loyalty, care mechanics, growth stages, corruption paths). Human NPCs are secondary and untrustworthy.

## Publishing / GitHub Sync Requirement (MUST ALWAYS DO)

The game must also live on (and overwrite) https://github.com/tchintchie/rpg-adventure .

- Active dev root is currently `test/`.
- **Before or as part of any commit of game changes**: sync/overwrite the content from here into the `../rpg-adventure/` subdir of the monorepo (old prototype files are intentionally replaced).
- Commit the monorepo on the feature branch (this updates the subdir in tchintchie/game).
- Run the publish script (`../rpg-adventure/tools/publish-standalone.sh` or the wrapper) — it uses `git subtree split --force` push to the rpg-adventure GitHub.
- See the new `tools/sync-to-rpg-adventure.sh` (created in this session) and the updated `../rpg-adventure/GROK.md` (which now lives in the published location).

**Always update your memory** (edit this GROK.md + `../rpg-adventure/GROK.md` + relevant `docs/` files) when architecture, slice progress, or rules change. Create new Claude hooks (in ~/.claude/hooks/) for enforcement if needed (e.g. memory-update hook, sync reminder).

Failure to sync means the GitHub rpg-adventure will be out of date.

## Slice progress (update after every milestone)

| Slice | Status | Notes |
|-------|--------|-------|
| 0 — Branch + local vault (docs/) + GROK.md | ✅ In progress (this session) | On `feature/cycle-of-innocence`; docs/ + templates created |
| 1 — Core player movement + real-time attack + age stub | ⬜ | Port/adapt from rpg-adventure |
| 2 — First animal companion (escape) + basic bond + Yarn integration | ⬜ | Phase 2 vertical slice target |
| 3 — One semi-open zone + 1 combat + 1 puzzle + 1 horror seed + age-up teaser | ⬜ | Phase 2 exit criteria |
| ... (see approved plan for full 0–6 phases) |

## Architecture (target, evolving from siblings)

```
autoloads: GameEvents, PlayerData (age, morality, bonds, revelations), ZoneManager, CompanionManager, YarnGlobals, SaveManager, InputManager
main: world or zone container + persistent player + companions + UI
player: CharacterBody2D (extended from rpg-adventure/scripts/player/player_controller.gd) with age_stage + morality visuals + real-time combat states
companions: scenes/companions/ + scripts/companions/ (base + dog/bird/horse; follow, assists, care, corruption)
dialogue: Yarn Spinner addon + resources/dialogue/*.yarn (variables + commands sync to PlayerData)
horror: DreadManager + shaders (vignette, grain, pulse, corruption) + dynamic audio buses
render: pixel post-process + resolution (from godot/)
```

**Key files to adapt** (see approved plan for full list + line references):
- Player controller + anim lock (rpg-adventure/scripts/player/player_controller.gd)
- Autoloads GameEvents / PlayerData / Room/ZoneManager (rpg-adventure/scripts/autoload/)
- Touch + input + save + pixel pipeline (godot/scripts/globals/ + rendering/ + scenes/ui/)
- Imagine import tools (rpg-adventure/tools/)

## 🔴 Critical rules (local + parent)

- R1 — Branch before code changes (`feature/cycle-of-innocence` etc.). check-branch hook will block main commits.
- R2 — Read this GROK.md + approved plan + consult `docs/` (and parent) before proposing work.
- R3 — Incremental vertical slices — each F5-playable.
- R4 — Use Grok Imagine (via image_gen or imagine skill) for bibles/sheets first; Aseprite for cleanup/anim. Document prompts in `docs/art/imagine-prompts.md`.
- R5 — Session journal in `docs/sessions/YYYY-MM-DD.md` (local or parent). Capture ideas to `ideas.md`.
- R6 — At completion of any session/phase: run status, triage, commit on branch only.
- New: Animal companions carry emotional weight — every bond/corruption choice is a potential tragedy or redemption. Track in PlayerData + Yarn.
- New: Horror is psychological + implication first. Provide intensity/accessibility options.

## Key paths (initial)

| What                  | Path (or sibling source) |
|-----------------------|--------------------------|
| Player controller     | `scripts/player/player_controller.gd` (adapt from `../rpg-adventure/...`) |
| Companion base        | `scripts/companions/` + `scenes/companions/` (new) |
| Yarn / dialogue       | `resources/dialogue/` + addon |
| Autoloads             | `scripts/autoload/` |
| Shaders (horror)      | `assets/shaders/` (extend godot/ pixelate) |
| Art bibles            | `assets/reference/` (Imagine first) |
| Tools                 | `tools/import_imagine_assets.py` (extend for animals/growth/corruption) |

## Design locked (from approved plan + clarifications)
- Real-time action combat (Zelda/Mana feel) with companion assists.
- Yarn Spinner for all branching (age, morality, $bond_*, revelations, companion reactions).
- Age stages + visible morality + animal growth/corruption as core progression.
- Protagonist = escaped sacrifice. First companion escapes with them.
- 3–4 endings driven by alignment + which animals lived / were corrupted / sacrificed.

## Image generation (Grok Imagine) — locked pipeline
**Default**: Use image_gen / imagine skill (or chat) for concept bibles and sprite sheets. Post-process in Aseprite. Never rely only on procedural for final.

### Style rules (every prompt)
- retro pixel art, top-down, **32×32** pixels per frame (or reference sheet grid), limited palette (16–32 colors)
- SNES / Zelda aesthetic with creeping horror atmosphere (desaturated + wrong highlights)
- Transparent background, crisp pixels, no anti-aliasing
- For protagonist: multiple ages (child / teen / adult) + morality variants (innocent glow vs scarred / marked)
- For animals: growth stages (pup → adult) + corruption variants (subtle body horror, glowing eyes, etc.)

### Asset workflow
1. Character / companion bible first (A-pose + angles + palette + notes on age/growth/corruption) → `assets/reference/`
2. Generate sprite sheets (idle/walk/attack/hurt/special per direction or 4-dir, growth/corruption rows).
3. Aseprite: grid 32×32, cleanup, animate (walk with weight/height shift per age, fear/courage in animals), export.
4. Godot: SpriteFrames (or logic that selects by age + bond + corruption state). Modulate/shader for final horror tint.
5. Update resources/ and scenes.

Document every prompt + chosen output in `docs/art/imagine-prompts.md` (extend the one from rpg-adventure).

## Useful commands

```bash
# Branch (always)
git checkout -b feature/...

# Local vault hygiene
python3 ../scripts/obsidian/status.py
python3 ../scripts/obsidian/digest.py

# Art (after Imagine)
# python3 tools/import_imagine_assets.py ... (extend as needed)

# Godot
# godot (or godot --headless for exports)
# Export presets for Linux / Android / Web (adapt from ../godot/export_presets.cfg)
```

## Next immediate actions (from approved plan)
- Finish local vault (home.md, ideas.md, first decision/session stubs).
- Persist high-level decision to parent docs/decisions/ with backlinks.
- Phase 0 engine spike (player + zone + age stub).
- Phase 0 art spike (first bibles via Imagine).
- Yarn first nodes (escape ritual + first bond choice).

Update this file's slice table after every vertical slice ships. Re-read the full approved plan before major work.

**This is the single source of truth for Grok in this project.** Read it + the plan before touching code or art.

## Feature Design Work (added this session)
While the story bible is under user review, a full set of game systems documentation was created in the local vault and synced/published:

- [[docs/design/game-features.md]] — Overview of all major features with philosophy, scope guardrails, and ties to story/companions/morality.
- [[docs/mechanics/progression.md]] — Age stages, morality system, companion bond/corruption as core progression, revelation abilities, NG+.
- [[docs/mechanics/combat.md]] — Real-time action design with horror layers (dread, body horror via corruption, psychological threats).
- [[docs/design/customization.md]] — Name picking (protagonist + companions), gender selection with narrative flavor, appearance driven by age + morality.
- [[docs/mechanics/horror-and-dread.md]] — Dread meter, body horror, accessibility (horror intensity slider), atmosphere tools.
- [[docs/mechanics/inventory.md]] — Light, purposeful inventory focused on companion care, story keys, and lore fragments.

All documents are cross-linked with the story bible and approved plan. They emphasize keeping scope realistic for solo dev while making choices (especially around companions and morality) feel visible and consequential.

These docs live in the published rpg-adventure/ repo after sync + publish.

## Story Bible Revision (this session)
User review feedback incorporated into docs/story/bible.md and docs/characters/companions.md:

- Selection is now a random lottery or based on a "Community Harmony Score" earned (or lost) by parents through work, loyalty, volunteering, etc. No "marked families" or old blood requirement.
- Ritual location changed from stone circle in the woods to the village playground (a place children are supposed to feel safe and happy).
- Atmosphere elements changed: no white robes. Instead, "Playtime Guardians" — creepy clowns in bright but faded costumes, oversized stitched stuffed animals, and living toys that move wrong.
- Villagers do **not** notice the escape. They believe the ritual was completely successful and everything is fine. The village carries on normally at first.
- Because the Hunger was not fed, strange things begin happening (withering crops, restless dead, more monster sightings). Villagers start running the lottery more frequently and sacrificing additional children in panic, which creates even more monsters and accelerates the breakdown of the cycle.

These changes make the conspiracy feel more systemic, random, and insidious. The initial "everything is okay" lie from the village's perspective heightens the horror and isolation for Rowan. Updated Act 0 description, Background, Cycle section, and relevant twists/companions rescue details.

The new details will affect early zone design (playground as ritual site), art prompts (toys/clowns), and the "delayed alarm" in the story.

## Session 2026-06-10 Start
- New session initialized per project rules (journal in docs/sessions/2026-06-10.md).
- Branch: feature/cycle-of-innocence (confirmed not main).
- Obsidian consulted: grep on docs/ for story/features/prototype/asset/yarn/companion/playground/lottery/ritual (extensive prior art in bible, features docs, mechanics, art prompts – no conflicts with revised ritual details).
- Focus: Asset bibles (image_gen for updated playground ritual/clowns/toys context + companions), Yarn prototypes (revised escape + bond), core prototype (PlayerData states, real-time combat/assists, playground/fringes zone).
- Memory updated; will sync/publish journal + any changes; run status/hook.
- Pre-action checklist satisfied.
