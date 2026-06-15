---
name: Painted backdrops — manual scaling & path-alignment guide
date: 2026-06-15
tags: [guide, art, editor, zones]
---

# Manual guide: world scale + path alignment in the Godot editor

The painted backdrops are drawn large; the player/companions are ~32px sprites, so
they look small ("dwarf"). Everything below is **editor-only, no code**. The camera
clamp honours the `GroundBackdrop` `scale` *and* `position`, so moving/scaling it
"just works" with the camera.

> **If a change doesn't show:** FileSystem dock → right-click `assets/sprites` →
> **Reimport**, or close & reopen the scene, or restart the editor. Imported
> textures are cached.

## Method 1 — make the characters bigger (RECOMMENDED: one place, every zone)
The most direct fix for "I look like a dwarf".
1. Open `scenes/player/player.tscn` (double-click in FileSystem).
2. Scene tree → select **`AnimatedSprite2D`**.
3. Inspector → **Transform → Scale** → set X and Y to e.g. **2** (try 1.5–3). The
   sprite grows in the viewport.
4. Select **`CollisionShape2D`** (child of `Player`) → either set its Transform →
   Scale to the same value, or edit the shape's radius/extents ×2, so collision
   matches the bigger body. (Optional: do the same for `Hurtbox/CollisionShape2D`
   and `AttackHitbox/CollisionShape2D`.)
5. **Do NOT** scale the `Camera2D` node — that zooms the whole view.
6. Save (Ctrl+S).
7. Repeat in `scenes/companions/briar.tscn` (and echo/storm when they exist):
   select the sprite, set Scale to ~2.
8. Press **F5** — characters are now larger in *every* zone at once.

Tune the number until a character looks right next to a painted door/human.

## Method 2 — shrink one backdrop (per-scene alternative)
1. Open the zone, e.g. `scenes/zones/cottage_ground.tscn`.
2. Select **`GroundBackdrop`** → Inspector → Transform → **Scale** → lower it (e.g.
   0.5). The camera re-clamps automatically.
3. **Caveat:** the gameplay nodes (door, stairs, spawn, Marta) and the `Borders`
   collision do **not** move with the backdrop — drag each back onto the painting and
   resize the wall shapes. (This is why Method 1 is easier.)
4. Save, F5.

> Tip: avoid scaling a backdrop *below* viewport width (720px) or you get black bars
> on the sides. The church is already 720 wide — leave it at scale 1.

## Aligning the outdoor paths at transitions
So you walk out of one painted path and into the next.
For each connecting edge (playground↔fringes, playground↔village):
1. Open the zone → select **`GroundBackdrop`** → adjust **Position** to slide the
   painting so its path reaches the screen edge where the transition sits.
2. Select the transition `Area2D` (e.g. `FringesTransition`) → set **Position → Y**
   to the height of the path at that edge.
3. In the OTHER zone, select the matching entry `Marker2D` (e.g. the fringes
   `EntryFromPlayground`) → set its **Position → Y** to where that painting's path
   meets the entry edge. (They're currently paired at the same Y — keep them paired.)
4. F5, walk the seam, nudge. Keep transition X near the wall (±585) and the entry
   marker ~85px further in (±500) so you don't instantly re-trigger.

## Optional — smoother painted art when scaled
Project default texture filter is **Nearest** (crisp pixels). Painted backdrops
scaled up/down look blocky under Nearest. To smooth *just the painted backdrops*:
select a painted PNG in FileSystem → **Import** tab → **Filter → Linear** →
**Reimport**. Leave the 32px character/prop sprites on Nearest.
