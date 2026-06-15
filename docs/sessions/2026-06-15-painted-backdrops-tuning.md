---
name: Painted backdrops — transition fixes, world-scale first pass, scaling guide
date: 2026-06-15
branch: feature/painted-backdrops / docs/scaling-guide
tags: [session, art, zones, fixes]
---

# 2026-06-15 (cont.) — Painted backdrop tuning

Follow-up to wiring the 6 Grok painted backdrops (merged: PR #107).

## What I did
- **Fixed broken zone transitions** (player couldn't reach fringes/village): the
  re-wire moved perimeter walls to ±616 but left edge transitions outside them →
  unreachable. Moved transitions to ±585 (inside walls).
- **Fixed instant-retrigger** on return (fringes→playground bounced back): arrival
  entry markers sat ~25px from the destination's own edge transition, so the player
  body overlapped it on spawn. Moved entry markers to ±500 (85px clearance).
- **First-pass world scale**: scaled cottage_ground + cottage_basement backdrops to
  0.6 (+ node positions + collision sizes). User reported little visible change —
  0.6 only shrinks furniture modestly; the direct fix is enlarging the character
  sprite. Church left native (already viewport-width).
- **First-pass path alignment**: set each transition + paired entry marker onto its
  painting's path (rough y from edge strips).
- **Wrote [[guides/painted-backdrop-scaling]]** — manual editor guide (character
  scaling = Method 1/recommended; backdrop scaling; path alignment; reimport note;
  optional Linear filter for painted art).

## State / next
- All 6 painted scenes + church + playground/fringes split merged to main (#107).
- Remaining is **manual editor tuning** by the user (per the guide): character size,
  per-scene path alignment, collision/marker nudges.
- Open option: scale the player/companion *sprites* up (~2x) in player.tscn/briar.tscn
  for an immediate, consistent size fix everywhere — offered.
