---
name: 2026-06-28-wire-briar-v2-art
date: 2026-06-28
tags: [session, art, briar, companions, spriteframes]
---

# 2026-06-28 — First-pass wiring of the V2 Briar art

Wired the chosen **V2 (simple/compact)** puppy art into the game so Briar renders
as the new sprite instead of the old `briar_pup_frames`.

## How
New tool `tools/build_briar_v2_spriteframes.py`:
1. finds ONE global content bbox across every used V2 frame (keeps the dog at a
   consistent scale + anchor — no size jitter between animations),
2. crops each 124px frame to that bbox, scales the dog (79×91 → 36×42) into a 48px
   cell (matching the old briar cell size), packs a grid sheet
   `assets/sprites/companions/briar_v2_pup.png`,
3. emits `assets/resources/companions/briar_v2_frames.tres` with animation NAMES
   the code plays: `idle_/walk_/trot_/stare_/growl_` × 4 dirs (south=down,
   north=up, east=right, west=left; seek→stare, run→trot), plus `dig/bark/sit`.

`scenes/companions/briar.tscn` now points at the V2 frames (one-line; old frames
kept for a trivial revert).

True drop-in: V2 didn't draft `cower/dusk_press/head_bump/lie_down`, so those are
added as **single-frame idle stand-ins** (the old sheet had them; a test asserts
`dusk_press`). 27 animations total. **388/388 tests green.**

## Verified live (runtime MCP server)
Booted playground_fringes, dismissed the intro, disabled placeholder mode, and
Briar renders as the new V2 puppy beside Rowan — on-model (fawn coat, black mask,
bell collar), correctly sized, facing the right way per direction.

## Caveats / next
- The walk/run/seek/growl animations are the **rough text-to-animate drafts** —
  motion is subtle. `cower/dusk_press/head_bump/lie_down` are identical idle
  stand-ins. All want the **manual pixel-editor polish** (the reserved hand pass).
- **The build defaults to placeholder mode** (`DEFAULT_ENABLED=true` in
  `scripts/debug/placeholder_mode.gd`), so normal play shows abstract shapes, not
  sprites. To see Briar's art in play, placeholder mode must be turned off
  (project setting `debug/placeholder_mode=false`) — a game-wide call, left to the
  human (surfaced, not flipped).
