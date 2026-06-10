---
name: Cycle of Innocence — Local Vault Home
tags: [home, cycle-of-innocence]
---

# Cycle of Innocence — Vault Home (docs/)

Dedicated Obsidian vault for the **Cycle of Innocence** 2D top-down horror-conspiracy RPG (per user request for vault "within this directory").

This is a focused sub-vault for detailed planning, bible, sessions, and assets specific to this title. High-level decisions and cross-project memory live in the parent `../docs/` (see [[../../docs/home]] and [[../../docs/decisions/2026-04-06-game-vision-echoes-verdant-realm]] etc.).

## Project Identity (from approved build plan)
- **Title**: Cycle of Innocence (working)
- **Genre**: 2D top-down action-adventure RPG (Zelda/Mana exploration + real-time combat + puzzles)
- **Tone**: Tense horror + atmospheric dread + epic conspiracy twists (AoT) + deep coming-of-age / Fable-style life progression
- **Key twist**: Protagonist is an escaped child sacrifice. Primary emotional bonds are with rescueable/raiseable **animal companions** (dog, bird, horse etc.) that can grow, form loyalty, or become corrupted.
- **Tech**: Godot 4.x, GDScript, Dialogue Manager (Yarn Spinner replaced 2026-06-10 — C#-only addon breaks Web export), 32×32 pixel art (Grok Imagine + Aseprite), cross-platform (Linux primary, Android, Web)
- **Root**: `test/` (current workspace / active dev root)

## Quick Links

### Local Indexes
- [[decisions/_index]] (create when needed)
- [[features/_index]]
- [[learnings/_index]]
- [[sessions/_index]]
- [[ideas]]
- [[art/imagine-prompts]]

### Parent / Monorepo
- [[../../docs/home]] — main project vault
- [[../../docs/decisions/2026-04-06-game-vision-echoes-verdant-realm]] — previous cozy Mote vision (explicitly **not** reused)
- 2D prototype patterns (player, rooms, autoloads, Imagine tools) were adapted from the old rpg-adventure prototype — removed 2026-06-10 (repo consolidation, see [[decisions/2026-06-10-repo-consolidation-game-only]]); history in git
- Parent [[../../CLAUDE.md]] rules (R1 branch, R3 consult Obsidian + save plans, R3c journals, R3d ideas, status.py)

### Templates (copied)
- [[_templates/decision]]
- [[_templates/session]]

## How to use this vault (local)
1. Work in `test/` on feature branch only.
2. Capture thoughts → this `ideas.md`
3. Major decision → `decisions/YYYY-MM-DD-....md` (use template) + promote key ones to parent `../../docs/decisions/`
4. Daily/ session work → `sessions/YYYY-MM-DD.md`
5. At end of session: update journal, triage ideas, run `python3 ../../scripts/obsidian/status.py` (or local equivalent), commit on branch.

**Full build plan**: See the approved plan in the Grok session artifacts (or the persisted decision doc).

**GROK.md** (Grok-specific memory): `../GROK.md` at project root.

Run status regularly. Never drop ideas.
