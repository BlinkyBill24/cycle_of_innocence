---
name: reflect
description: End-of-session ritual for Cycle of Innocence. Refreshes the STATE.md auto-header, captures the hand-written narrative + the per-session journal, runs health checks, and reminds the user to push to Forgejo and click "Sync now" in the claude.ai web Project. Invoke at the end of a work session (e.g. "/reflect" or "reflect and wrap up").
---

# /reflect — end-of-session ritual

Goal: leave the repo + the web side in sync. Do these in order. Keep it tight.

1. **Refresh STATE.md auto-header:** run `python3 tools/refresh_state.py`. (Updates only
   the `<!-- auto:start -->..<!-- auto:end -->` block — branch, latest commit, doc counts.)

2. **Update the STATE.md narrative** between `<!-- narrative:start -->` and
   `<!-- narrative:end -->`: 4–6 lines — **Focus / Last shipped / Next / Watch out for**.
   Draft it from what happened this session, then show the user and let them edit. Keep
   STATE.md lean (~40–60 lines total); it is the web Project's primary file.

3. **Write the session journal** `docs/sessions/YYYY-MM-DD-<slug>.md` (slug = the
   branch/feature). Newest entries first: what changed, why, decisions made, follow-ups.
   This is R5 — never append to a shared daily file.

4. **Persist + triage:** new decisions → `docs/decisions/` (template `_templates/decision`);
   reusable fix/technique → `docs/learnings/{bugs-solved,patterns-that-work}.md`; stray
   thoughts → `docs/ideas.md`. Never drop an idea on the floor.

5. **Health check:** `python3 tools/status.py` (want GREEN) and `bash tools/check-brain.sh`.

6. **Commit** STATE.md + the journal (+ any remaining work) on the **feature branch**
   (the pre-commit hook regenerates the digest into the commit). Never commit to `main`.

7. **Remind the user — do NOT do these for them** (they require the browser / their hands):
   - `git push` to **Forgejo** (`origin`). The server push-mirror carries it to GitHub.
   - In the **claude.ai web Project** → click **Sync now**.
   - **Verify**: the commit hash in STATE.md (as seen on the web) matches the latest push
     before planning the next session.

Hard rule: the official **GitHub integration is the only** sanctioned path to the web —
never ClaudeSync or any session-key tool (violates Anthropic's Consumer Terms).
