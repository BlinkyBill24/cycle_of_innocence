---
name: Central brain via AGENTS.md for multi-CLI AI workflow
date: 2026-06-10
tags: [decision, tooling, ai-workflow]
status: active
related_features: []
related_bugs: []
supersedes: null
superseded_by: null
---

# Central Brain (AGENTS.md) for Multi-CLI AI Workflow

## Context
The user asked: (a) is it possible/sensible to work with multiple CLI AIs (Grok, Claude, Codex) sharing one central, always-current project brain ("Karpathy-like"); (b) pros/cons of Cursor-agent-as-coordinator vs switching between CLIs.

Audit found all four tools installed (Claude Code, Grok CLI 0.2.38, Codex CLI 0.133.0, Cursor 3.7.21) but the brain fragmented across `game/CLAUDE.md`, `test/GROK.md`, `test/AGENT_RULES.md` and two vaults — with rules duplicated 3–4× and **live divergence**: the 2026-06-10 Yarn→Dialogue Manager switch missed ~28 references across 11 design docs within a day.

Research (June 2026): `AGENTS.md` is the Linux Foundation open standard (60k+ projects), read **natively** by Codex CLI, Cursor, and Grok CLI; Claude Code consumes it via a one-line `@AGENTS.md` import in CLAUDE.md. Karpathy's "one brain" pattern = behavior file (agents.md) + synthesized markdown wiki — the Obsidian vault already is the wiki half.

## Decision
1. **Yes to multi-CLI with one brain.** Architecture: **`AGENTS.md` holds behavior** (rules, stack, roles, slice definition); **the Obsidian vault holds knowledge** (bible, mechanics, decisions, sessions); per-tool files are thin shims.
2. **Claude Code is the day-to-day hub**: it already drives Codex (`codex:rescue` plugin) and Grok (MCP), and hooks enforce R1. Cursor stays the IDE, reading AGENTS.md natively — no Cursor-specific rules maintained.
3. Implemented: canonical `test/AGENTS.md`; `test/CLAUDE.md` = `@AGENTS.md` + Claude notes; `AGENT_RULES.md` = pointer shim (kept for old prompt references); `GROK.md` = Grok-specific (Imagine pipeline) + slice table + session history; ~28 stale Yarn references fixed; `tools/check-brain.sh` drift guard (verified: catches an injected stale term); sync script now ships the brain files to the published repo.

## Alternatives
- **Cursor agent as coordinator** — rejected as hub (kept as IDE). Pros: one UI, multi-model (Claude/GPT/Grok), background agents, built-in review UI. Cons: vendor lock-in (Cursor-specific rules/workflows), credit-based unpredictable cost, aggressive context truncation vs Claude Code's 1M window, and the existing investment (hooks, skills, Grok MCP, codex plugin, auto-memory) doesn't carry over.
- **Manual CLI switching, no hub** — viable *because of* AGENTS.md (every tool reads the same brain), but adds per-task coordination overhead the user doesn't need given the Claude hub exists. Available anytime as fallback — that's the point of the standard.
- **rulesync-style generated configs** — overkill for a solo dev with 4 tools; symlink/import + drift guard suffices.
- **Symlinking CLAUDE.md → AGENTS.md** — rejected in favor of `@AGENTS.md` import: allows Claude-specific additions and avoids symlink issues.

## Consequences
- + One edit updates every tool; yesterday's divergence class is now structurally prevented and mechanically detected (`check-brain.sh` in the completion checklist).
- + Codex/Grok/Cursor sessions started in `test/` are automatically up to date with zero per-tool config.
- − Old prompts referencing AGENT_RULES.md content now land on a pointer (one hop).
- − GROK.md history was condensed; full prior text remains in git history.

## Implementation
- **Branch**: `refactor/central-brain-agents-md`
- **Files**: `AGENTS.md` (new), `CLAUDE.md` (new), `AGENT_RULES.md`, `GROK.md`, `tools/check-brain.sh` (new), `tools/sync-to-rpg-adventure.sh`, `../CLAUDE.md` (pointer note), ~11 docs de-Yarned (`docs/design/game-features.md`, `docs/story/bible.md`, `docs/characters/companions.md`, …)
- **Verified**: `check-brain.sh` passes (and fails correctly on injected drift); GUT 7/7 still green; Codex smoke test reads AGENTS.md.

## Lookback Questions
- Did any tool ignore AGENTS.md in practice (esp. Grok CLI version drift)?
- Did Claude Code gain native AGENTS.md support (issue #34235), making CLAUDE.md shim removable?
- Is the drift guard catching enough, or should it diff rule sections semantically?

## Related
- [[2026-06-10-new-features-and-ai-setup]] · [[../design/ai-production-setup]] · ../AGENTS.md
