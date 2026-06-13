---
name: Session Journals — convention
tags: [meta, sessions]
---

# Session Journals

**One file per session, never a shared file.** Parallel agent/editor sessions
kept colliding on a single `YYYY-MM-DD.md` (everyone appended to the same "What
I did" list → merge conflict on every sync). Per-session files never collide.

## Naming

`docs/sessions/YYYY-MM-DD-<slug>.md` — `<slug>` is your session's branch or
feature, e.g.:
- `2026-06-13-footstep-surface.md`
- `2026-06-13-bark-volume.md`
- `2026-06-13-secrets-research.md`

## Rules (R5)

- Write **only your own** file. Never append to another session's file, and
  never to a bare `YYYY-MM-DD.md` (those are legacy/pre-2026-06-13).
- Newest entries first within your file.
- Use the template `docs/_templates/session.md` (its `name`/`branch` fields
  identify the session).
- Commit your journal file on your feature branch like any other change.

## Reading a whole day

```bash
python3 tools/session_digest.py            # today, all sessions
python3 tools/session_digest.py 2026-06-13 # a specific day
```

It concatenates every `YYYY-MM-DD-*.md` (and any legacy bare file) into one
read, newest-modified first.

## Legacy

Bare `YYYY-MM-DD.md` files (≤ 2026-06-13) predate this convention — left as
history, not edited further. The parent-vault pointer journals in
`../../docs/sessions/` (monorepo root) stay as-is.
