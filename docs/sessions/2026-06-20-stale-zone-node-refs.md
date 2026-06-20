---
name: Fix stale Ground / DuskTint zone-node refs
date: 2026-06-20
branch: fix/stale-zone-node-refs
tags: [session, bugfix, zones, startup-noise]
---

# 2026-06-20 — Stale Ground / DuskTint node refs

## Root cause
`village_green.gd` + `playground_fringes.gd` predate the **painted-backdrop
re-wire** (2026-06-11, commits `0fe2c5a`/`be54f46`). That pass replaced the
procedural `Ground` TileMapLayer with a painted `GroundBackdrop` Sprite2D and
never carried a `DuskTint` CanvasModulate into these two scene files — but the
scripts still drove both. `git log -S 'name="DuskTint"'` shows the node never
existed in these `.tscn` files. Booting `village_green` (now the placeholder
test build's boot scene) ran the broken `_ready()` at startup → the noise.

## Per-ref diagnosis & fix
1. **`$Ground` (TileMapLayer) — TRULY DEAD.** Superseded project-wide by the
   painted `GroundBackdrop` (no `Ground` node in any zone); `_paint_ground()`
   painted nothing (`set_cell` on null). → Removed the `ground` var +
   `_paint_ground()` call + method in **both** scripts. **Kept** the static
   terrain-field functions (`cell_tile`/`wang_tile`/`vertex_terrain`/…) —
   they're unit-tested (`test_zone_paint`, `test_village_zone`) and mirrored by
   the preview tools. No behavior lost: the painted backdrop IS the ground.
2. **`$DuskTint` (CanvasModulate) — LOAD-BEARING → restored the node.** It was
   the **only** thing applying the time-of-day atmosphere tint (`WorldState.palette()`
   is called by nothing else; default time = DUSK `Color(0.38,0.34,0.44)`).
   Per the "flag, don't fake" rule I did **not** strip it. → **Restored the
   `DuskTint` CanvasModulate node** to both scenes (authored at the DUSK
   palette). Scripts resolve it; the dusk tint works again, in-engine and clean.
3. **`get_node("Ground").get_used_cells()` in `tests/test_zone_manager.gd` —
   RENAMED/MOVED (a THIRD stale ref the goal didn't name).** The test asserted
   the removed procedural painting; it had been erroring at runtime but GUT
   still counted it "passing" (its one earlier assert passed before the crash).
   → Repointed to assert the painted `GroundBackdrop` + its texture; renamed
   `test_zone_scene_loads_with_painted_ground`.

## ⚠ One thing for you to confirm (design call)
Restoring `DuskTint` re-applies a dynamic dusk **multiply over the painted
backdrops**. The script intent (set palette + tween on `time_changed`), the live
time-of-day system, and the interiors' `DarkTint` precedent all say this is
intended. **But** if the painted-backdrop direction meant to *bake* atmosphere
statically (no dynamic CanvasModulate), you'd instead want the tint logic
stripped from the scripts — tell me and I'll flip it. How dark dusk reads over
the art is a human F5 tuning check either way.

## Verify
- **Zero** Ground/DuskTint/`set_cell`/null errors — full GUT suite (**280
  pass**) AND headless boot of `village_green`, in placeholder mode **ON and
  OFF**. The benign `resources still in use at exit` line is Godot's
  `--quit-after` shutdown message, unrelated.
- All scene-instantiation + static-terrain tests still pass.
- typed GDScript, no new addons, Web-safe; no unrelated code/nodes touched.
