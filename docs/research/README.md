---
name: Research Inbox
tags: [research, inbox]
---

# Research Inbox — claude.ai → vault

Landing zone for research produced in the claude.ai Project **"Cycle of
Innocence — Design & Research"**. Files arrive here verbatim, get integrated by
the librarian pass (Claude Code), then move to `done/`.

## Convention

- One file per research result: `YYYY-MM-DD-topic.md`.
- Body is the claude.ai output **verbatim** — provenance frontmatter on top:

```markdown
---
name: <topic>
date: YYYY-MM-DD
source: claude.ai Research | claude.ai chat
prompt: <the question asked, one line>
status: inbox  # inbox | integrated
---
```

- Reliability markers inside the body are required from claude.ai:
  `[verified YYYY-MM-DD]` (web-checked) vs `[training knowledge]` (unverified).
  The librarian preserves them when integrating.

## Librarian pass (in Claude Code)

> Process the inbox: read docs/research/<file>. Propose integrations — new or
> updated mechanics/design docs, decision records, ideas-inbox entries, story
> bible flags. Show me the full proposal before applying anything.

Rules during integration (mirror of AGENTS.md R2/R7):

- Locked decisions and the locked tech stack are **not** reopened by research;
  conflicting findings become a flagged note in the relevant doc, not an edit.
- Patent guardrails apply to incoming ideas too (no nemesis-like systems, no
  radial emotion dialogue wheel).
- Every finding is filtered through: does it serve story, a companion arc, a
  horror beat, or replay? Otherwise → `docs/ideas.md` rejected section.
- After integration: set `status: integrated`, move the file to
  `docs/research/done/`, journal the change.

## Related

[[design/feature-candidates-2026-06]] (pre-bridge research rounds) ·
[[../setup-guide]] · [[ideas]]
