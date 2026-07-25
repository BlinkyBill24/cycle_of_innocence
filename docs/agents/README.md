---
name: Game-dev role agents — index
tags: [agents, skills, index]
---

# Game-dev role agents

Specialized **job contracts** for AI tools on Cycle of Innocence. Same model, same brain
([[shared-contract]]), different mission / file rights / proof.

**Start here to call them:** [[how-to-use]]  
**Swarm (option C) rules:** [[swarm]]

Skills live under `.claude/skills/<name>/SKILL.md` (Claude Code hub + Grok both load these).  
Workflows live under `.grok/workflows/*.rhai` (Grok multi-agent runs; dashboard `/workflows`).

## Shared rules

→ [[shared-contract]] (always) + root `AGENTS.md` (R1–R7).

## Coordinator

| Slash / skill | Mission (one line) |
|---------------|--------------------|
| `/project-manager` | Plan one bite, order roles, enforce gates — no craft |

## Core five

| Slash / skill | Mission (one line) |
|---------------|--------------------|
| `/level-design` | Place that walks, collides, transitions, one beat |
| `/creative-art` | Engine-ready still art matching style + bible |
| `/programming` | One vertical feature with tests |
| `/animation` | Motion that reads at game scale |
| `/story-writer` | Canon + player-facing beat with a flag/hook |

## Support roster

| Slash / skill | Mission (one line) |
|---------------|--------------------|
| `/dread-director` | One horror beat that lands |
| `/companion-designer` | One Briar/Echo assist or bond beat |
| `/combat-designer` | One combat/mercy verb that is fair and gated |
| `/audio` | SFX/music cue wired to the right key |
| `/playtest-qa` | Prove boot + critical path (evidence, not feel) |
| `/librarian` | Research inbox → decision/reject; no silent canon |
| `/reviewer` | Second-opinion risk review (prefer Codex rescue) |
| `/reflect` | End-of-session ritual |

## Swarm workflows (option C)

| Workflow | When |
|----------|------|
| `content-studio` | You know the mission; auto crew + human gates |
| `project-swarm` | PM picks next bite from STATE/ideas, then builds |

Call: `/workflow content-studio` or `/workflow project-swarm` (see [[how-to-use]]).

## Quick decision tree

```text
Need one craft job?          → /role-name
Need a plan + order?         → /project-manager
Know mission, want auto crew → /workflow content-studio
Don't know next work?        → /workflow project-swarm
Session over?                → /reflect
```

## Related

- [[design/agentic-playtest-smoke]]
- [[design/ai-production-setup]]
- [[art/imagine-prompts]]
