---
name: Kept (permanent) items category + flute icon
date: 2026-06-21
branch: feat/kept-items-category
tags: [session, inventory, ui, flute, pixellab, playtest]
---

# 2026-06-21 — A "Kept" category for permanent items (+ flute icon)

## The report
"No indication the flute was found — we should have a separate category for permanent
items (e.g. key, flute)."

## What I built
A **"Kept"** section in the satchel for permanent **KEY** items (the flute, a key) —
shown as icon+name chips above the detail panel, so a permanent unlock reads as a thing
you HAVE, not lost among the consumable pockets. Read-only (KEY items have no slot
action; equippable weapons stay in the bag grid where their click-to-equip lives).
`InventoryPanel.is_kept(def)` (= category KEY) is the pure classifier; the section
hides when empty. The main 10-slot bag grid is **unchanged** (low risk — additive only).

## Flute icon (PixelLab)
The flute had no icon. Generated a 32x32 carved-wooden-flute icon via
`tools/pixellab_api.py` and wired it into `flute.tres` — so the Kept chip and the bag
slot now show a real flute. Placeholder-quality; refine later if desired.

## Tests — suite 365 green, check-brain green, Web export builds
`test_kept_items.gd`: `is_kept` flags KEY items only (a weapon is NOT kept); the Kept
strip shows held KEY items and hides when empty.

## Note
`project.godot` got an auto-edit (Dialogue Manager adding the new throw-reaction
.dialogue files to the localization POT list) — left UNCOMMITTED (it's the protected
file, and the change is benign/regenerated).
