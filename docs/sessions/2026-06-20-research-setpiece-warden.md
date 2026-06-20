---
name: Librarian pass — escape-room set-piece + Warden Oslo patrol
date: 2026-06-20
branch: docs/research-village-suspicion
tags: [session, research, librarian, set-piece, villagestate, warden]
---

# 2026-06-20 — Research inbox: escape-room set-piece + Warden Oslo

Two files that landed in the inbox mid-pass; processed into the **same** branch/PR
as the suspicion file (folded together → one merge, no conflict risk).

## Escape-room set-piece — buildable feature (→ mechanics doc)
A bespoke single locked-room at the conspiracy reveal, fusing locked-in horror +
lore-by-solving + a Briar-cooperation climax. Same treatment as the equipment spec.
- Filed → `docs/research/done/2026-06-20-escape-room-set-piece-research.md` (integrated).
- **`docs/mechanics/escape-room-setpiece.md`** (new) — distilled spec (single
  signature room, 2–3 layered steps, companion-cooperation without an escort trap,
  dread-without-a-timer, story-by-solving via witnessed Journal, Three-Clue-Rule
  fairness, save simple step flags by ID, 4-phase build order).
- `docs/ideas.md` queued + pointer in [[design/secrets-and-discovery]].

## Warden Oslo patrol — confirmation (→ ideas + pointer)
Mostly confirmatory (like the suspicion file): the documented stage-2 marker-patrol
+ LOS notice matches `village_state.gd` / `villager.gd`. **Verdict: keep as-is.**
- Filed → `docs/research/done/2026-06-20-warden-oslo-search-patterns.md` (integrated).
- `docs/ideas.md` + [[mechanics/village-life]] "Future direction": two post-slice
  companion-aware extensions (bond → notice-rate cut / early warning; multi-phase
  evasion → authored recontext), hand-written not procedural.

## Notes
- All three of today's village/research files (suspicion · set-piece · warden) are
  in one branch `docs/research-village-suspicion` → one PR, one merge.
- Zero locked decisions reopened; guardrails respected. check-brain green; docs only.
