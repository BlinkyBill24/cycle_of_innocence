---
name: Librarian pass — VillageState suspicion decay investigation
date: 2026-06-20
branch: docs/research-village-suspicion
tags: [session, research, librarian, villagestate, suspicion]
---

# 2026-06-20 — Research inbox: suspicion decay

## What I did
Processed a Grok investigation of VillageState suspicion decay. (The file first
arrived **truncated** — 18 lines, cut mid-code-block; the user re-pasted the full
59-line version, which I then processed.)

Mostly a **confirmation**: the documented current behaviour (`SUSPICION_DECAY_PER_PHASE
= 0.7`, report threshold 100 → +25 alarm, eavesdrop ×2.5) was checked against
`village_state.gd` and is accurate. **Verdict: keep the 0.7×/phase baseline — no
change.** One post-slice extension, which is a specific case of the already-captured
Terranigma authored-village-evolution idea.

- Filed verbatim → `docs/research/done/2026-06-20-villagestate-suspicion-decay.md`
  (`status: integrated` + integration log).
- **`docs/ideas.md`** — post-slice idea: companion/morality-aware decay (ruthless →
  slower; high Briar bond → small decay bonus / one authored distraction per phase),
  hand-written flags not procedural.
- **`docs/mechanics/village-life.md`** — extended the "Future direction" note with
  the decay-modulation case + a one-line "current decay reviewed, sound" confirmation.

## Notes
- Nothing reopens a locked decision; the research flagged that procedural-NPC
  behaviour or visible meters would fail the filter (kept as a guardrail).
- Two more research files landed in the inbox mid-pass (escape-room set-piece,
  warden-oslo search patterns) — handled separately.
- check-brain green; docs only.
