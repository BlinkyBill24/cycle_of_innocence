---
name: 2026-06-28-godot-runtime-diagnostics
date: 2026-06-28
tags: [session, tooling, mcp, godot, diagnostics, briar, doors]
---

# 2026-06-28 — First live-runtime diagnostics with godot-mcp-runtime

Follow-through on [[2026-06-28-adopt-godot-mcp-runtime]]. The runtime MCP server
(`godot-mcp-runtime` v3.1.2) is now **live in-session** after the Claude Code
restart, so the three jobs that adoption unlocked were finally runnable: drive the
*running* game, walk the live scene tree, read autoload state. All three done.

Method that worked: `run_project` (background mode — window hidden, physical input
blocked, but `run_script`/`take_screenshot` still work) → `run_script` (extends
RefCounted, `func execute(scene_tree)`) to poke the live tree → `take_screenshot`.
Gotcha: `run_script` is statically typed, so reading an off-class member like
`briar.hsm` throws a compile error — use `node.get("prop")` / `node.call("method")`
to stay dynamic.

## Job 1 — Briar "yellow blob": **WIRING IS FINE. It's a legibility/art problem.**
Drove the real seek path live in `playground_fringes` (Briar at
`/root/PlaygroundFringes/World/Briar`, bond 25, corruption 0):
- `command_seek(target)` returned **true**; state machine went **follow → seek**,
  ran LEAD → TELL, spawned the exclaim mark, played "dig", returned to follow.
  Every phase fired. Nothing is broken in the behaviour wiring.
- The tell itself is the culprit: `_show_exclaim()` (companion_base.gd:351) renders
  `assets/sprites/ui/exclaim.png` — a **6×8-pixel, 90-byte pale-yellow placeholder
  "!"** — at scale 2× = **12×16 px on screen**. A tiny pale speck above the dog.
  That *is* the "yellow blob." It loads fine (not a failed-texture box); it's just
  placeholder art that's far too small and low-contrast to read.
- **Verdict:** the open "wiring vs legibility" question is settled — **legibility**.
  Fix is art, not code: a real, readable point-tell (bigger, higher-contrast "!" or
  a clearer pointer/beacon over the target spot). Whether it reads stays a playtest
  question, but the behaviour is sound.

## Job 2 — Locked door "no feedback": **WIRING IS FINE. It's silent + non-reactive.**
Ran `hollow_house.tscn` and tested the canonical locked door (`InnerDoor`,
item-gated on `hollow_key`, reason "Locked. Something small is missing."):
- `is_locked()` → **true** (no key); `trigger()` → **false** (correctly blocked);
  it created a **visible, readable** white floating Label with the right text
  (font size 10, on its own camera-following CanvasLayer so dark interiors can't
  crush it). Screenshot confirms the text is legible against the graybox interior.
- So "no feedback" is **not** an invisible/mispositioned label. Two real gaps:
  1. **No sound at all** on a locked interact (contrast the push-open at
     door_transition.gd:109, which plays `stinger_toy`). Silence reads as "nothing
     happened."
  2. **No change on press.** The same label is *already* shown on `_on_body_entered`
     (door_transition.gd:67) while you stand on the door, so pressing interact
     re-shows the identical static text — nothing on screen changes, no acknowledgement.
- **Verdict:** add a reactive cue on the locked-interact attempt — a "locked"
  audio thunk/rattle (no dedicated SFX yet; `stinger_toy` could stand in) plus a
  small label nudge/flash so the press registers. Small code change, but it's
  game-*feel* — leaving the call to the human (AGENTS.md: agents don't tune feel).

## Job 3 — Autoload spot-check: all healthy.
Live values: `DreadManager` tier **0 (calm)**; `HollowingClock`, `VillageState`
(`effective_notice_rate` present), `PlayerData` all loaded and responding. Note:
`Inventory` is a **static `class_name` class** (scripts/items/inventory.gd),
accessed as `Inventory.has()` — *not* a node autoload, so `get_node("Inventory")`
returns null. That's expected, not a bug.

## Side findings
- Boot still emits the 2 stale-UID warnings in `playground_fringes.tscn`
  (campfire_frames.tres, fog_frames.tres → fall back to text path). Harmless;
  part of the captured cleanup-tail chore (`update_project_uids`).

## Not done (deliberate)
- Did **not** implement the art/feel fixes — both are human-call (legibility art for
  Briar's tell; feel/audio for the locked door). Captured as proposals for sign-off.
- Untracked Briar art (`assets/companions/`) on the parallel `art/briar-puppy-versions`
  branch is untouched — separate work.
