---
name: Librarian pass — companions (two) + flute gate
date: 2026-06-21
branch: docs/companions-flute-gate
tags: [session, research, librarian, canon, companions, mercy, decision]
---

# 2026-06-21 — Integrate the companions + flute-gate decisions (canon)

Processed `research/companions-and-flute-gate-decisions.md` — Steffen's OWN design
decisions, so they become canon (not external research to vet). Recorded + propagated.

## Decision record (source of truth)
`docs/decisions/2026-06-21-companions-and-flute-gate.md`: two companions (Briar=ground,
Echo=air, both defend Rowan); **Storm/mount CUT**; **the flute gates ALL monster
interaction**; **bare fists can't harm monsters**; **run-only before the flute**; push-to-open
(already shipped).

## Canon + live docs updated
- **AGENTS.md** (the brain): companion line → two; Storm CUT; added the flute-gate +
  bare-fists + run-only rule with a pointer to the decision.
- **characters/companions.md**: roster banner (two); Storm section marked CUT (history kept);
  fixed the gaze-hint line that referenced Storm.
- **story/bible.md**: Storm section struck through + CUT note; "third companion" line updated.
- **design/game-features.md**: 4 Storm references updated (roster, default names, two puzzle lines).
- **mechanics/combat.md**: bare-fists-no-harm + run-only-pre-flute (Locked Design).
- **mechanics/encounters-mercy.md**: flute-gate banner (all soothe/ally is post-flute;
  reconciles the allied-glow timeline).

## Code consequences → ideas.md (NOT implemented here)
Bare-fists no-damage · flute-gate combat+soothe · run-only pre-flute · build Echo ·
`[FLAG]` traversal-without-a-mount is now level-design. Each is its own future `/goal`.

## Left as history
`research/done/`, `sessions/`, `_compiled/` Storm mentions — historical/auto-generated.

## Verified
check-brain green (AGENTS.md canonical); 349 GUT tests still pass (docs-only). Inbox clear.
