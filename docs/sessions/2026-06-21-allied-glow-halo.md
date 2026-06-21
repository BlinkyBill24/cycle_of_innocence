---
name: Allied glow — add a visible halo
date: 2026-06-21
branch: feat/allied-glow-halo
tags: [session, monster, lighting, mercy, diegetic, playtest]
---

# 2026-06-21 — Allied glow: add a halo (the bare light was too subtle)

## The report
The `PointLight2D` allied glow "is almost not noticeable" — it only reads against a
dark `CanvasModulate`. Wanted a clearer read: a colour change or a halo.

## The fix
Added a **warm halo Sprite2D** (`AlliedHalo`) to the monster — reuses the same
`glow_radial.png`, behind the sprite (`z_index = -1`), warm gold, **always visible**
regardless of scene lighting. It **gently pulses** (alpha 0.85↔0.45 over ~1.8s) so it
draws the eye. The subtle `PointLight2D` stays (adds depth in the dusk).

Both follow the same persisted `stilled` state via `_refresh_allied_glow()` — halo
visible + pulse-tween on when allied, killed/hidden on revert. So it still survives
save/load and turns off on betrayal / hollowing re-aggro, exactly like before.

## Tunable
`AlliedHalo` `modulate`/`scale` and the pulse timings are placeholders — tune the
warmth/size to the final palette. The sprite stays its calm cool tint; the halo is the
warm "restored innocence" read.

## Tests — suite 349 green, check-brain green, Web export builds
`test_allied_glow.gd::test_allied_halo_follows_the_state`: hostile = no halo; soothed =
halo shows; betrayal = halo hides. (Sprite2D + tween — no shader; Web-safe.)
