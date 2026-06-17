---
name: TradeForge workflow setup (Forgejo source-of-truth → GitHub mirror → web)
date: 2026-06-17
branch: chore/workflow-setup
tags: [session, workflow, infra]
---

# 2026-06-17 — TradeForge workflow setup

Split this repo out of `tchintchie/game` `test/` (subtree, full history → Forgejo
`home/cycle_of_innocence`), then bootstrapped the colleague's TradeForge loop on top of
the existing AGENTS.md brain.

## What I did
- **Phase 1:** cloned Forgejo repo to `~/cycle_of_innocence` (origin → Forgejo SSH,
  identity tchintchie/seitanist@tutanota.com); git `pre-commit` branch guard
  (`.githooks/` + `core.hooksPath`). Set up the **server-side Forgejo→GitHub push
  mirror** (manual) — explained why it beats per-machine dual-push.
- **Phase 2:** docs additions (`learnings/`, `features/`, `_digest/`, `handbook.md`);
  `tools/status.py` + `tools/digest.py` (fixed dangling `../scripts/obsidian/status.py`
  refs); pre-commit also auto-regens the digest into the commit; `.claude/`
  settings/hooks/rules; AGENTS.md R6/R7 rewired to the Forgejo→mirror→web loop. Kept
  AGENTS.md canonical (did NOT duplicate rules into a competing CLAUDE.md).
- **Phase 3:** `STATE.md` (auto header via `tools/refresh_state.py` + hand narrative);
  `/reflect` skill (refresh STATE → narrative → journal → triage → health → commit →
  remind push + Sync). GitHub integration is the only sanctioned web path (never ClaudeSync).
- GitHub mirror account switched tchintchie → **BlinkyBill24** (user-side; local repo
  unaffected — GitHub is only the downstream mirror).

## Next
- **Merge `chore/workflow-setup` → `main` on Forgejo** → mirrors to BlinkyBill24 → Sync the
  web Project. Then the loop is live.
- Resume game work: player/companion sprite scaling, in-editor path/transition tuning.

## Notes
- Any fresh clone needs `git config core.hooksPath .githooks` to arm the hooks.
- Web Project: keep < 13 curated files, STATE.md first.
