---
name: Push-to-open doors
date: 2026-06-21
branch: feature/push-to-open-door
tags: [session, interaction, doors, dread, web-safe, physical-verb]
---

# 2026-06-21 — Push-to-open doors (goal item 2)

A door you have to *shove* open, not glide through — deliberate friction as a dread tool.

## What I built
`DoorTransition` gained an opt-in **PUSH** Mode (alongside INTERACT/ENTER):
- While the player leans in (held proximity + any movement input), `_accumulate_push`
  adds time; at `push_seconds` (≈0.6s) the door **gives** — plays a creak and runs the
  existing `trigger()` (same target/spawn wiring as any door). A **tap never opens it**.
- Stepping off the threshold **resets** the lean (`_on_body_exited`).
- The accumulation core (`_accumulate_push`) is pure/testable; the live "lean" reads
  movement input globally (`_player_pushing`) so the door stays decoupled from the
  player script. `_push_active()` is the testable gate — false for INTERACT/ENTER, so
  normal doors never enter the push path (regression-proof).
- Prompt: `"<prompt_text>  (hold)"`. SFX: the **toy-creak** stands in (no dedicated door
  sound exists yet — flagged).

## Placement (opt-in on a specific door)
Opted the **Hollow House ExitDoor** into PUSH (`mode = 2`, prompt "Shove it open"). It
reuses that door's already-working target (village_green) + spawn — so no spawn-mismatch
risk — and "shove the haunted house's door to escape" is a fitting dread beat. All other
doors stay instant.

## Tests — suite 330 green, check-brain green
`test_push_door.gd`: a tap stays shut; a sustained push opens it; releasing resets the
lean; INTERACT and ENTER doors never enter the push path (regression).

## ⚠ Flags
- No dedicated **door SFX** asset — using `stinger_toy` (toy-creak) as a stand-in; swap
  the file (keep the Sfx key) when a door sound is generated.
- The referenced physical-interaction **research note doesn't exist** in `docs/research/`
  (same as item 1) — built from the goal spec.
