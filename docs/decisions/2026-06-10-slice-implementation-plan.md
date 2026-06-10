---
name: Vertical slice implementation plan with AI agent task distribution
date: 2026-06-10
tags: [decision, plan, vertical-slice, agents]
status: active
related_features:
  - "[[plan/slice-implementation-roadmap]]"
related_bugs: []
supersedes: null
superseded_by: null
---

# Vertical Slice Implementation Plan + Agent Distribution

## Context
Design pre-production is complete: story bible, 13 documented systems (9 greenlit this week), AGENTS.md central brain, full tooling (Dialogue Manager, LimboAI, GUT, godot-mcp, Grok MCP, Codex plugin). Code: progression core only (PlayerData, controller, age morph, tests). The user asked for an actual implementation plan that distributes tasks across the AI agents. Builds on [[2026-06-09-cycle-of-innocence-build-plan]] (Phases 0–2 concretized).

## Decision
Adopt the milestone roadmap in [[plan/slice-implementation-roadmap]]:
- **M0** art/audio as a parallel track owned by Grok Imagine (+ human Aseprite/ACE-Step/ChipTone) that never blocks code.
- **M1** core systems by Claude Code (DreadManager → Combat v1 → Briar companion → Zone framework), one branch per system, GUT tests each, **Codex review gates** after combat and companion AI.
- **M2** narrative & persistence (first Dialogue Manager scene with "The Food" choice — Grok reviews voice; SaveManager; scripted dread beat).
- **M3** assembly (mercy v1, touch input, adaptive audio v1, web export) ending in the human **slice gate** from AGENTS.md.
- Post-slice order fixed: vision cone → day/night+hideout → mercy full → hollowing clock → quirks → interface horror → village life → recontextualization.
- This session: plan documents only (user decision) — no art runs, no code.

## Alternatives
- **Cursor-led implementation**: rejected — hub topology already decided ([[2026-06-10-central-brain-agents-md]]); Cursor stays the human's in-editor tool.
- **Art-first sequencing** (wait for sprites before systems): rejected — placeholder-driven development keeps the critical path on code; art is async.
- **Feature-parallel implementation** (multiple systems at once via worktrees): deferred — sequential branches until the first systems prove the patterns; revisit worktree parallelism post-slice.

## Consequences
- + Every agent has an explicit lane and interface; hand-offs reference specs by wikilink instead of re-explaining.
- + Codex gates add a second model's eyes exactly where solo-dev blind spots live (physics layers, AI structure).
- − Sequential M1 is slower than parallel worktrees — accepted for pattern stability.
- − Art quality risk stays human-gated (Aseprite cleanup is the bottleneck by design).

## Implementation
- **Branch**: `docs/slice-implementation-plan`
- **Files**: `docs/plan/slice-implementation-roadmap.md` (new), this doc, `docs/art/imagine-prompts.md` (A3–A5 prompts appended), `GROK.md` (slice table → M0–M3), task board entries.
- **Verified**: check-brain + status green; frontmatter valid; pushed to origin.

## Lookback Questions
- Did the Codex gates catch real issues, or add ceremony?
- Did the art track keep pace with code without blocking?
- Was the slice gate verdict honest (re-scope actually considered)?

## Related
[[plan/slice-implementation-roadmap]] · [[2026-06-09-cycle-of-innocence-build-plan]] · [[2026-06-10-recent-games-research-greenlight]] · AGENTS.md
