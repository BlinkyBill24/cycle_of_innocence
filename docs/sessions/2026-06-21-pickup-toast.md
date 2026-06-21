---
name: Pickup notification toast
date: 2026-06-21
branch: feat/pickup-toast
tags: [session, ui, inventory, pickup, playtest]
---

# 2026-06-21 — "Found: <item>" pickup toast

## The report
"No indication that the flute was found" — pickups were silent.

## What I built
`PickupToast` (`scripts/ui/pickup_toast.gd`, a CanvasLayer) listens to
`GameEvents.item_acquired` and shows a brief centred **"Found: <display name>"** label
(×N for a stack) that fades. Newer replaces older.

**Player-owned**, added in `player_controller._ready` next to SoothePrompt/JournalPanel —
deliberately NOT an autoload (that would touch the protected `project.godot`) and NOT the
HUD (the HUD isn't in the interiors — the hollow house, where the flute/key are, has none).
The player is in every zone, so the toast reaches everywhere a pickup can happen.

Fires for ALL pickups (key, flute, forage), so the dug-up `hollow_key` and the flute both
announce themselves.

## Tests — suite 363 green, check-brain green
`test_pickup_toast.gd`: toast text names the item (+ stack count, + id fallback); emitting
`item_acquired` raises the toast.
