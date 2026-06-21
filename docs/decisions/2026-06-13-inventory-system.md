---
name: Inventory System (Vertical Slice)
date: 2026-06-13
tags: [decision, mechanics, inventory, vertical-slice]
status: accepted
related:
  - "[[mechanics/inventory]]"
  - "[[design/game-features]]"
  - "[[mechanics/interface-horror]]"
  - "[[characters/companions]]"
---

# Inventory System (Vertical Slice)

> Produced by a multi-agent workflow (understand → 3 competing designs + judge →
> implement → adversarial verify). The reviewer caught a UI self-pause soft-lock
> (blocker) + 3 minors; all fixed before commit. See [[sessions/2026-06-13]].

## Context
The vertical slice needs a light, purposeful inventory ([[mechanics/inventory]] design goals: classic Zelda/Mana feel, no heavy RPG/crafting/economy) that serves companion care first. Chosen defaults: 10 slots; data-driven `ItemDef` resources tracked in `PlayerData`; one demo care-food fed to Briar for a bond payoff; Memory/Lore items and the Journal stay OUT of this slice (the Journal autoload already exists and owns witnessed lore per [[mechanics/interface-horror]] and the secrets work — inventory must not duplicate it). The slice must stay F5-playable and honor the [[mechanics/interface-horror]] hard rule: **menus never degrade**.

Prior-art consulted (R3b): `escape_food.dialogue` already ships and its choice branches already apply morality/bond/story-flags; `PlayerData` already persists `known_revelations`/`story_flags` via a clean StringName-re-wrap save/load idiom; `journal_panel.gd` + `soothe_prompt.gd` establish the code-built CanvasLayer + exploration_paused/resumed modal pattern; `CompanionQuirkDefs` establishes the stateless static-catalogue pattern.

## Decision
- **Storage on PlayerData.** Add `var inventory: Array[Dictionary] = []` (each slot `{id: StringName, quantity: int}`, max 10) plus a deferred `var lore_items: Array[StringName] = []` stub, mirroring `known_revelations` exactly (duplicate on save, StringName re-wrap on load, clear on reset). No dedicated Inventory resource, no SaveManager change — PlayerData is already the save snapshot.
- **Verbs in a stateless `Inventory` static class** (`scripts/items/inventory.gd`) that operates on `PlayerData.inventory` and emits via `GameEvents`. Keeps PlayerData pure progression-state and keeps inventory logic unit-testable without a node.
- **Definitions are data-driven `ItemDef` .tres** (`scripts/items/item_def.gd`), loaded once and cached by an `ItemRegistry` autoload. New item = drop a `.tres`. Effects dispatch on a small `use_kind` enum (now `NONE`, `FEED_COMPANION`, `EQUIP`, `THROW`; **`HEAL`/`REDUCE_DREAD` are NOT in the enum yet** — adding them is future work, see [[decisions/2026-06-21-food-heal-values]]).
- **Five signals on GameEvents:** `item_acquired`, `item_used`, `item_discarded`, `item_add_failed(id, reason)`, `inventory_changed`. UI listens only to `inventory_changed`; gameplay/companions key off the others. No silent discard — a full satchel returns false and fires `item_add_failed`.
- **UI: a code-built CanvasLayer panel** (`scripts/ui/inventory_panel.gd`, layer 60) cloning `journal_panel.gd`, toggled with **I**. It emits `exploration_paused`/`resumed` (strict pairing) and **force-closes on a *foreign* `exploration_paused`** so dialogue/cutscene always wins. A `_self_pause` re-entrancy flag stops it from force-closing on its own pause emission (the soft-lock the reviewer caught). It NEVER tints/distorts/degrades — only item description text swaps to `distorted_description` at HARDENED/VESSEL (texture only). Touch: a Control "BAG" button in `touch_controls.gd` (not action-injection, so degradation can't reach it).
- **Demo = a new care item `dried_meat`,** granted in the playground slice via a `ForageSpot` Area2D and fed to Briar from the satchel: `FEED_COMPANION` → `+8` bond, `-3` morality, consumed. The existing **bread stays a dialogue-only scripted beat** (it already owns its deltas) to avoid double-counting. A `ritual_fragment` Key item proves the non-discardable guard.

## Alternatives
- **Methods directly on PlayerData (Proposal 1).** Smallest file count, but grows PlayerData past pure-progression scope and couples run-state to inventory verbs. Rejected the verb placement, kept its storage decision.
- **Dedicated Inventory autoload/resource with its own save key.** A second persistence path and reset surface for zero gain at 10-slot scope. Rejected. (Also: `Inventory`/`ItemRegistry` carry `class_name`, so they can't *also* be autoloads — Godot rejects an autoload name equal to a `class_name`. They stay static-only globals; only `InventoryPanel` is an autoload.)
- **Generic `effect_magnitude` + per-item `dialogue_resource` (Proposal 2), gamepad focus-grid + contextual feed-prompt (Proposal 3).** Good extensibility, scope creep for a slice. Deferred; the `use_kind` enum leaves the seam.
- **Reuse the bread as the mechanical demo.** Rejected: `escape_food.dialogue` already applies bond/morality, so `Inventory.use` would double-count. A separate `dried_meat` exercises the real path cleanly.

## Consequences
- (+) Zero new save plumbing; rides the PlayerData snapshot. (+) Inventory logic unit-testable in isolation (15 GUT tests; full suite 226 green headless). (+) New content = pure data. (+) Honors the never-degrade contract by construction (Control nodes, not the input-buffer path).
- (-) Convention to learn: "data lives in PlayerData, verbs live in `Inventory`." (-) `Array[Dictionary]` needs explicit typing on load (Godot 4.4 strict; StringName/int JSON coercion) — covered by a save/load test.
- Watch-outs: run `godot --headless --import` after adding `class_name` scripts + `.tres` (the GUT silent-skip trap; `run-tests.sh` already does this). Keep the bread's deltas in the dialogue ONLY. Both Journal and Inventory panels sit at layer 60 — force-close-on-foreign-pause is the v1 mitigation; a shared "one modal at a time" guard is a likely v1.1 follow-up.
- **Pending human verification (R3 F5):** the satchel open/close pause loop and the forage→feed→bond payoff must be confirmed in-engine (agents are runtime-blind for UI). Reserves design space: `lore_items` + the `LORE` category are stubbed but unexposed for the future Journal/Memory integration.
