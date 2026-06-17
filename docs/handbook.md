---
name: Handbook — how this project runs
tags: [handbook, meta]
---

# Handbook

Operational quick-reference. The **rules + identity + architecture** are in
[[AGENTS.md]] (the canonical brain) — this is just the day-to-day map.

## The loop (source of truth → web)
1. **Forgejo** (`home/cycle_of_innocence`) is the single source of truth; you push here.
2. Forgejo **auto-mirrors** every push to the private GitHub repo (server-side push mirror).
3. **Claude.ai web** reads that GitHub repo via the official GitHub integration → always
   has current state for research/planning.
4. **Claude Code** builds; at session end the `reflect` skill refreshes `STATE.md` + writes
   the session journal so the web side stays current.

## Where things live
- **Brain / rules:** `AGENTS.md` (R1–R7). `CLAUDE.md` is a thin shim → it.
- **Decisions:** `docs/decisions/YYYY-MM-DD-<slug>.md` (template: `_templates/decision`).
- **Features:** `docs/features/<slug>.md`. **Learnings:** `docs/learnings/{bugs-solved,patterns-that-work}.md`.
- **Sessions:** `docs/sessions/YYYY-MM-DD-<slug>.md` (per-session, never shared — R5).
- **Ideas inbox:** `docs/ideas.md`. **Digest (auto):** `docs/_digest/`.
- **Status file for the web:** `STATE.md` (lean; auto header + hand-written narrative).

## Common commands
```
git switch -c feature/x        # always branch first (R1; hooks enforce it)
python3 tools/status.py        # repo/vault health snapshot
python3 tools/digest.py        # regenerate docs/_digest/ (also runs on commit)
bash tools/check-brain.sh      # brain↔docs drift check
/reflect                       # end-of-session: refresh STATE.md + journal + push reminder
```

## Branches
`feature/ fix/ refactor/ docs/ chore/`. Never commit to `main`. Merges to `main`
happen on the Forgejo web UI; the mirror then carries them to GitHub.
