---
name: Fix the allied halo's black box
date: 2026-06-21
branch: fix/allied-halo-black-box
tags: [session, monster, lighting, bugfix, web, playtest]
---

# 2026-06-21 — Allied halo: kill the black box (additive blend)

## The report (screenshot)
The new halo drew a hard-edged **black square** around the monster.

## Cause
`glow_radial.png` is a white radial on a **solid black background** (an RGB light
texture, no alpha). A `PointLight2D` treats it as an intensity mask (black = no light),
but a plain `Sprite2D` with the default Mix blend draws that black background **opaque**
— hence the box.

## The fix
Gave `AlliedHalo` a `CanvasItemMaterial` with **`blend_mode = 1` (Add)**: black pixels
add nothing (invisible), the warm centre adds light. No box — just a soft additive glow
that blends with the dusk. No shader; Web export builds.

## Tests — suite 349 green, check-brain green, Web export builds
The halo toggle test is unchanged (blend mode doesn't affect visibility).

## ⚠ Pre-existing flaky test (noted, not caused here)
`test_hitbox_tokens.gd::test_deactivate_cancels_pending_window` flaked twice then passed
3/3 on re-run — it asserts a 0.05s hitbox window is still open one physics frame after
`activate()`, a tight real-time race. Unrelated to this change; worth hardening separately
(e.g. a longer window or a deterministic check).
