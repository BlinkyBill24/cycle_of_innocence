---
name: Repo consolidation — develop in tchintchie/game only
date: 2026-06-10
tags: [decision, tooling, git]
status: active
related_features: []
related_bugs: []
supersedes: null
superseded_by: null
---

# Repo Consolidation — `tchintchie/game` Only

## Context
The project lived in two places: the `game` monorepo (actual development in `test/`) and `tchintchie/rpg-adventure` (a standalone mirror, force-overwritten via rsync + `git subtree split` per old rule R6). Costs observed: every commit doubled (~1000+ files when synced), force-pushes destroyed mirror history, and the duality caused real confusion — work pushed to `game` was invisible to the user looking at `rpg-adventure`. All tooling (parent Obsidian vault, `scripts/obsidian/`, hooks, AGENTS.md brain) is path-anchored in the monorepo.

## Decision
Develop **only** in `github.com/tchintchie/game`. Retired: the `rpg-adventure/` monorepo subdir (542 files removed; history preserved in git), `tools/sync-to-rpg-adventure.sh`, and the publish workflow. **R6 rewritten** in [[../../AGENTS.md|AGENTS.md]]: commit on feature branch + push to origin; user merges. The drift guard (`tools/check-brain.sh`) now also fails if living docs reinstate the sync/publish workflow.

A public standalone repo will be created **when a demo is ready** — freshly named for the locked title (e.g. `cycle-of-innocence`), produced via `git subtree split` at that point. The GitHub `rpg-adventure` repo can be archived by the user (left frozen until then).

## Alternatives
- **Keep dual setup**: rejected — ongoing sync overhead and confusion for no benefit while the project is solo/pre-demo.
- **Migrate to standalone now**: rejected — breaks vault/hooks/script paths today; the split is a one-command operation later, and the repo name should match the final title anyway.

## Consequences
- + Commits halve in size; one repo to look at; no force-push churn; normal branch/PR flow.
- + Old prototype sources remain available via git history (`git log -- rpg-adventure/`).
- − github.com/tchintchie/rpg-adventure goes stale until archived/replaced (user action).
- − Old journals/decisions referencing the sync workflow are now historical (exempt in the drift guard).

## Implementation
- **Branch**: `refactor/central-brain-agents-md`
- **Files**: `AGENTS.md` (R6, checklist, tree), `tools/check-brain.sh` (mirror guard), removed `tools/sync-to-rpg-adventure.sh` + `../rpg-adventure/`, `docs/home.md`, `docs/art/imagine-prompts.md`, auto-memory.
- **Verified**: `check-brain.sh` green after cleanup; `status.py` no RED; pushed to origin.

## Lookback Questions
- When the demo ships: did we split a clean `cycle-of-innocence` repo and archive rpg-adventure?
- Did anything still depend on the removed prototype files?

## Related
- [[2026-06-10-central-brain-agents-md]] · [[2026-06-10-new-features-and-ai-setup]]
