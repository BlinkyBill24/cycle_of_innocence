---
name: "Session 2026-07-25 — Village collision nudge (C2)"
date: "2026-07-25"
tags: [session, level, collision]
branch: "feature/village-collision-nudge"
commits: []
---

# Session 2026-07-25 — Village collision nudge

## Focus

Bite C2: building footprints match paint better; well/bench/trees block;
doors stay approachable.

## What I did
*(newest first)*

- Nudged/shrunk `BldMarta` / church / smith / cottages against door markers + paint.
- Smith is a **thin roof footprint** so the central path is not a full wall.
- `WorldSolids`: well, green bench, market crate, four corner trees.
- GUT: footprints present; door centers outside building rects; eavesdrop stays Area2D.

## Human gate

F5 village: bounce off houses; enter Marta / church / hollow-house doors; walk
paths; still eavesdrop at well/bench/market.

## Next

- C3 optional backdrop art pass if village still reads flat.
- Fringes more tree solids if needed.
