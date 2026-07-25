---
name: Game-dev role agents — index
tags: [agents, skills, index]
---

# Game-dev role agents

Specialized **job contracts** for AI tools on Cycle of Innocence. Same model, same brain
([[shared-contract]]), different mission / file rights / proof.

Skills live under `.claude/skills/<name>/SKILL.md` (Claude Code hub + Grok both load these).

## Shared rules

→ [[shared-contract]] (always) + root `AGENTS.md` (R1–R7).

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

## How to use

1. Branch first (R1) if work will edit files.
2. Invoke the role (`/level-design`, or say “act as level design”).
3. Agent loads shared contract + that skill’s card, then only that lane.
4. Close with journal (R5); big sessions end with `/reflect`.

## Content Studio Loop (multi-role)

For a small content bite (from the one-person-studio research):

1. `/story-writer` — brief + flag  
2. `/programming` — code against existing systems  
3. `/creative-art` or `/animation` — only missing assets  
4. `/playtest-qa` — smoke + optional MCP walk  
5. Human — dread / bond / readability gate  
6. `/reflect` when the session ends  

## Related

- [[design/agentic-playtest-smoke]]
- [[design/ai-production-setup]]
- [[art/imagine-prompts]]
- [[art/grok-reference-workflow]]
