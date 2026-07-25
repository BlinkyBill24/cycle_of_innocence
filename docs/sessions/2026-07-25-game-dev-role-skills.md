---
name: "Session 2026-07-25 — Game-dev role skills roster"
date: "2026-07-25"
tags: [session, agents, skills, docs]
branch: "docs/game-dev-role-skills"
commits: []
---

# Session 2026-07-25 — Game-dev role skills roster

## Focus

Stand up **12 specialized role skills** (job contracts) so agents stay in lane
while sharing one brain (`AGENTS.md` + `docs/agents/shared-contract.md`).

## What I did
*(newest first)*

- **Option C swarm:** `/project-manager` skill + workflows `content-studio` and
  `project-swarm` (smoke-validated). Docs: `how-to-use.md`, `swarm.md`.
- Linked roster from `AGENTS.md` (Tool roles → game-dev role skills table).
- Wrote 12 role skills + PM under `.claude/skills/*/SKILL.md` (Claude + Grok both load).
- Added `docs/agents/README.md`, `shared-contract.md` (R1–R7, bans, proof).

### Coordinator + core five

`project-manager` · `level-design`, `creative-art`, `programming`, `animation`, `story-writer`

### Support seven

`dread-director`, `companion-designer`, `combat-designer`, `audio`,
`playtest-qa`, `librarian`, `reviewer`

### Workflows

`.grok/workflows/content-studio.rhai` · `.grok/workflows/project-swarm.rhai`

## Decisions made

- Roles are **skills/playbooks**, not separate models or stacks.
- Single skill home: `.claude/skills/` (no duplicate `.grok/skills` copies).
- Canon/process still only in `AGENTS.md` + vault; skills cannot override bans.

## Bugs fixed

- None (docs/skills only).

## Files touched

**New**: `docs/agents/*`, twelve `.claude/skills/*/SKILL.md`, this journal.

**Modified**: `AGENTS.md` (discovery table only).

## Next session

- Try a Content Studio Loop bite with role hand-offs.
- Optional: workflow script that chains story → code → art → playtest-qa.

## Related

- [[agents/README]]
- [[agents/shared-contract]]
- [[design/agentic-playtest-smoke]]
