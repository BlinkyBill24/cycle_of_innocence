---
name: Place the flute in the Hollow House
date: 2026-06-21
branch: feat/flute-in-hollow-house
tags: [session, flute, content, hollow-house, placement, mercy]
---

# 2026-06-21 — Place the flute in the Hollow House (back room)

## Placement
The flute (the gate that unlocks soothing) is now a **findable pickup in the Hollow
House BACK ROOM** — by the broken cabinet, with a glint to draw the eye. Finding it is
the payoff of the hollow-house micro-quest: enter the house → Briar digs the `hollow_key`
→ push/open the inner door → the back room (Ledger/truth) → **the flute**.

## ForageSpot persistence (small fix)
`ForageSpot.granted` was runtime-only, so the pickup would reappear (and re-grant) on
revisit. Added a persistence path for **gate items**: on `_ready`, if the item's
`ItemDef.grants_flag` is already set (e.g. `flute_found`), the spot marks itself taken
(hidden + not monitoring). So once you've found the flute it never reappears. Refactored
`grant()` to share `_mark_taken()`.

## Tests — suite 357 green, check-brain green
`test_flute_gate.gd`: the flute is placed as a pickup in `hollow_house_back`; an
already-found flute pickup is inert (won't reappear); an unfound one is live.

## ⚠ Flag — gating depth (confirm)
The flute is behind THREE steps: reach the hollow house, **Briar digs the hollow_key**,
open the inner door. Since the flute is THE gate to all soothing, that's a meaningful
dependency — earned, but deep. If it should be easier to obtain, move the `FlutePickup`
to the **front room** (`hollow_house.tscn`) — a one-node move. Left in the back room as
the "secret at the heart of the house" per the request to find it there.

## Out of scope (unchanged)
Final melody/audio; soothe resolution; the combat-side flute gate (tracked in [[ideas]]).
