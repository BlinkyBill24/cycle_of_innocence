---
name: "Web research bridge — claude.ai Project as shared brain"
date: "2026-06-12"
tags: [decision, process, research]
status: active
related_features: []
related_bugs: []
supersedes: null
superseded_by: null
---

# Web Research Bridge — claude.ai Project as Shared Brain

## Context

Design research so far ran ad hoc (research rounds 1–2 lived in
[[design/feature-candidates-2026-06]]). The user runs a proven design system on
another project (space game): an Obsidian vault as source of truth, compiled
snapshots as project knowledge in a claude.ai Project (web research + Research
feature), and a research inbox + librarian loop back into the vault. Goal:
the same shared brain here — claude.ai for outward research/planning, Claude
Code for implementation/integration — without disturbing what already works
(AGENTS.md canonical brain, git/R1–R6, existing vault layout).

## Decision

Adopt the bridge, adapted to this project's existing structure:

- **No vault restructuring** — keep `story/ mechanics/ design/ decisions/ plan/
  sessions/`; no numbered folders. Git stays active (unlike the space system).
- **`tools/compile_snapshots.py`** generates four replace-only files in
  `docs/_compiled/` (committed): story-compendium, mechanics-compendium,
  decisions, state-and-roadmap (includes AGENTS.md + latest 2 journals, so
  claude.ai always knows what's actually built).
- **claude.ai Project** "Cycle of Innocence — Design & Research": knowledge =
  the four snapshots, nothing else; project instructions carry identity, locked
  stack, patent/Mote guardrails, the story/companion/horror/replay filter, and
  the inbox output format ([verified]/[training knowledge] markers).
- **Return path**: `docs/research/YYYY-MM-DD-topic.md` inbox (convention in
  `docs/research/README.md`) → librarian pass in Claude Code (propose-first,
  locked decisions get flags not edits) → integrated files move to
  `research/done/` → recompile at milestones.
- **New rule R7** in AGENTS.md anchors the loop for all tools.

## Alternatives

- **MCP/live connection from claude.ai to the repo**: rejected — snapshots are
  deliberate (curated, milestone-stable ground truth; no half-finished branch
  state leaking into research grounding), and the space-game system proved the
  replace-only bridge works.
- **Numbered-folder restructure to mirror the space vault 1:1**: rejected —
  churn with no benefit; conventions transfer, structure doesn't need to.
- **Letting claude.ai write Claude Code instructions directly**: rejected
  (same as space system) — vault conventions govern integration; research
  output is data, not commands.

## Consequences

- Web research is grounded in the real, current design (incl. implementation
  status per mechanics frontmatter) instead of chat memory.
- Two manual sync points the user owns: uploading snapshots after milestone
  merges, and saving research output into the inbox.
- `docs/_compiled/` adds ~250 KB of generated content to the repo (accepted:
  enables upload-from-anywhere and survives machine loss).

## Implementation

- **Commits**: branch `feature/research-bridge` — compile script, inbox README,
  adapted [[setup-guide]], AGENTS.md R7.

## Related

[[setup-guide]] · [[design/feature-candidates-2026-06]] ·
[[2026-06-10-central-brain-agents-md]] · [[2026-06-10-patent-risk-review]]
