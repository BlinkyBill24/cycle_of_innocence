# Operating context (read me first)

- **Canonical brain:** `AGENTS.md` (rules R1–R7, identity, architecture). `CLAUDE.md` shims it.
- **Current project state (for humans + web):** `STATE.md` at the repo root.
- **Daily map:** `docs/handbook.md`.

## Session discipline
- R1: branch before any change (`feature/ fix/ refactor/ docs/ chore/`); hooks enforce it.
- R5: write a per-session journal `docs/sessions/YYYY-MM-DD-<slug>.md`; capture stray ideas to `docs/ideas.md`.
- End of session: run `/reflect` (refreshes STATE.md auto-header, prompts the narrative, writes the journal, reminds you to push + Sync the web Project).
- Before "done": `python3 tools/status.py` (GREEN) and `bash tools/check-brain.sh`.

## Current focus
<!-- One or two lines, kept current by /reflect or by hand. -->
- Bootstrapping the TradeForge workflow (Forgejo source-of-truth → GitHub mirror → Claude.ai web).
