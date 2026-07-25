---
name: Multi-agent swarm (option C)
tags: [agents, swarm, workflow]
---

# Multi-agent swarm — option C

**One brain, many jobs, one coordinator.**  
Specialists never replace `AGENTS.md`. The project manager (PM) never replaces human taste.

## What “full swarm” means here

| Layer | What runs |
|-------|-----------|
| **Law** | `AGENTS.md` + [[shared-contract]] |
| **Coordinator** | `/project-manager` skill and/or workflow PM phase |
| **Crew** | 12 role skills (story, code, art, …) |
| **Pipeline** | Grok workflows `content-studio` and `project-swarm` |
| **Human** | F5 feel, merge, Sync now, difficulty/dread dials |

It is **not** twelve agents forever editing at once. Parallel work is limited to
**safe** panels (e.g. multiple reviewers read-only). Implementers run **in order**
so they do not stomp the same scene.

## Hard swarm rules

1. **One mission per run** — cut scope until it fits a vertical slice.  
2. **One implementer at a time** (sequential write path).  
3. **No isolation worktrees for implementers** unless you have an explicit merge step (default: shared workspace, sequential).  
4. **QA after code/zones** — `/playtest-qa` or smoke script.  
5. **Human gates are mandatory** for dread, bond, readability, merge.  
6. **Budget** — keep agent counts small (plan + a few roles + QA + review ≈ under 20).  
7. **Patent / flute / two-companions / no Storm** still apply to every child agent.

## Default role order (Content Studio)

```text
PM plan
  → story-writer        (if story lane on)
  → programming         (if code lane on)
  → level-design        (if level lane on)
  → combat / companion  (if those lanes on)
  → creative-art        (if art lane on)
  → animation           (if anim lane on)
  → audio + dread       (if those lanes on)
  → playtest-qa
  → reviewer
  → HUMAN F5 gate
  → report (+ /reflect when session ends)
```

Skip lanes that the mission does not need. **Never** enable every lane “just because.”

## When to use what

| Goal | Call |
|------|------|
| Single craft task | Role slash only (`/programming`, …) |
| Coordinate by hand in chat | `/project-manager` |
| Automated bite pipeline | Workflow `content-studio` |
| “What should we do next?” then maybe build | Workflow `project-swarm` |
| End of day | `/reflect` |

Details and copy-paste commands: [[how-to-use]].
