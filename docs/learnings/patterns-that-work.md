---
name: Patterns that work — rolling log
tags: [learnings, patterns]
---

# Patterns that work

Newest first. Reusable techniques/approaches proven on this project (the "do it this
way" shortlist). Each: the pattern, when to use it, why it works. Full write-ups can
use [[_templates/pattern]].

<!-- Add new entries directly under this line, newest first. -->

### 2026-07-25 — One brain, many role skills (+ thin PM)
**Pattern:** Job contracts in `.claude/skills/<role>/SKILL.md` (mission, may-edit,
must-not, done-when) + `docs/agents/shared-contract.md`; coordinator is
`/project-manager` or workflows `content-studio` / `project-swarm`. Specialists
stay in lane; humans keep dread/bond/feel.
**When:** Multi-role content bites without inventing a second lore/stack.
**Why:** Vertical slices stay F5-able; hand-offs are explicit.

### 2026-07-25 — Secrets off-repo, trial before stack adopt
**Pattern:** API keys at `~/.config/<vendor>/api_key` (chmod 600); thin
`tools/*_api.py` clients; bake-off folders under `assets/reference/`; only promote
to production bank/stack after human score (e.g. Sorceress stinger yes, PixelLab
grids keep).
**When:** New art/SFX vendors (PixelLab, ElevenLabs, Sorceress, …).
**Why:** No secrets in git; avoid ripping a working pipeline on one pretty sample.
