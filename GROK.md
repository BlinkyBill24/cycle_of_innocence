# GROK.md — Cycle of Innocence (Grok shim + session memory)

**Canonical project rules, identity, tech stack, and architecture live in [AGENTS.md](AGENTS.md)** — read it first (Grok CLI also picks it up natively). Consolidated 2026-06-10; see `docs/decisions/2026-06-10-central-brain-agents-md.md`. Do not add rules here.

This file keeps only what is Grok-specific: the Imagine art pipeline, the slice-progress table, and session history.

## Grok's role
High-level vision, story consistency (against `docs/story/bible.md`), Grok Imagine prompt batches + image generation, review of other agents' output. Implementation belongs to Claude Code/Cursor (see tool roles table in AGENTS.md).

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

Document every prompt + chosen output in `docs/art/imagine-prompts.md`.

## Slice progress (update after every milestone)

| Slice | Status | Notes |
|-------|--------|-------|
| 0 — Branch + local vault (docs/) + brain files | ✅ | docs/ + templates + AGENTS.md consolidation done |
| 1 — Core player movement + real-time attack + age stub | 🟡 Partial | player_controller + age_morph + PlayerData implemented; combat hitboxes pending |
| 2 — First animal companion (escape) + basic bond + dialogue integration | ⬜ | Phase 2 vertical slice target; Dialogue Manager installed |
| 3 — One semi-open zone + 1 combat + 1 puzzle + 1 horror seed + age-up teaser | ⬜ | Phase 2 exit criteria |
| ... (see approved plan for full 0–6 phases) |

---

# Session history (journal extracts — newest first)

## Brain consolidation (2026-06-10)
- AGENTS.md created as canonical brain for all CLIs (Claude Code, Codex, Grok, Cursor). CLAUDE.md/GROK.md/AGENT_RULES.md became shims. Stale Yarn references in design docs fixed; `tools/check-brain.sh` drift guard added.

## Feature greenlight + tooling (2026-06-10)
- 4 features greenlit from genre research: encounters-mercy, hollowing-clock, day-night-hideout, vision-and-darkness (docs/mechanics/).
- Yarn Spinner → Dialogue Manager (C#-only addon breaks Web export). Installed: dialogue_manager v3.10.4, LimboAI v1.6.0, GUT v9.4.0 (+ tests/, tools/run-tests.sh). FOSS-first AI production stack documented in docs/design/ai-production-setup.md.

## Cursor hand-off (2026-06-10)
- Cursor installed (AppImage). First hand-off prompt: docs/prompts/cursor-handoff-01-playerdata-age-morph.md (PlayerData + AgeMorph — since implemented and unit-tested).

## Agent workflow (2026-06-10)
- Hybrid adopted: Grok = vision/story/art prompts; Claude Code/Cursor = implementation; Codex = review/rescue. Originally codified in AGENT_RULES.md, now in AGENTS.md.

## Story bible revision (2026-06-09)
- Selection via lottery / Community Harmony Score (no marked families). Ritual at village playground; "Playtime Guardians" clowns, stitched stuffed animals, living toys (no white robes). Villagers believe the ritual succeeded — no alarm at first; failed feeding → escalating emergency sacrifices → more monsters. Affects zone design, art prompts, early dialogue.

## Feature design docs (2026-06-09)
- Created design/game-features.md, mechanics/progression.md, mechanics/combat.md, design/customization.md, mechanics/horror-and-dread.md, mechanics/inventory.md — all cross-linked with the bible.
