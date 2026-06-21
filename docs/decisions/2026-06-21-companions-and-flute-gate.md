---
name: Companions (two), the flute gate, and monster-interaction rules
date: 2026-06-21
status: decided
deciders: Steffen
supersedes: three-companion roster (Briar/Echo/Storm)
source: "[[research/done/companions-and-flute-gate-decisions]] (design conversation)"
tags: [decision, companions, combat, mercy, story]
---

# Companions, the Flute Gate & Monster-Interaction Rules

Authoritative record of Steffen's design decisions (2026-06-21). These are choices,
not externally checkable facts. Live docs point here; this file is the source of truth.

## Companions — TWO, by design
A third animal was considered and **rejected as unnecessary**; the two below cover
separate lanes (ground/air, close/far) without overlap.

- **Briar (dog) — owns the GROUND.** Points to dig spots and secret doors; defends
  Rowan. (Matches the Hollow House micro-quest, where Briar points to a hidden book/dig spot.)
- **Echo (bird) — owns the AIR.** Attacks from above; scouts; warns about monsters from
  afar; finds hidden treasure; defends Rowan.
- **Shared core job:** both companions **defend Rowan from attacks.**

### Cut: Storm (the mount)
The third companion slot is removed entirely. The animal was negotiable and no specific
need pulled toward keeping a mount (or any third animal).
- **`[FLAG]` traversal consequence:** anything implicitly leaning on a mount (crossing
  water, spanning gaps, covering long distances) now has **no animal solution**.
  Traversal becomes a **level-design problem** (paths, bridges, gated routes), not a
  companion problem. Confirm before any zone layout assumes mounted movement.
- **System impact:** bond/corruption now maintains **two** tracks, not three — less
  content to author (fits the current content-drought reality).

## The flute gates ALL monster interaction
Rowan must find a **flute** (or some other instrument) before *any* monster interaction
— soothing or allying — becomes possible. The instrument is the single key that unlocks
the entire mercy/soothe system; **nothing in that system is reachable before it.**
- This resolves a prior consistency question: soothe-combat and the "glow when fully
  allied" indicator both assume Rowan can win monsters over — the flute is what makes
  that possible.

## Combat / response rules
- **Bare fists cannot harm monsters.** Unarmed Rowan cannot damage a monster; harming
  one requires a real tool/weapon, never hands.
- **Run-only before the flute.** Until Rowan finds the flute, the only valid response to
  a monster is to **flee** — no fighting, no soothing pre-flute.
- **Push to open doors.** Doors are actively pushed open, not walked through (already
  implemented — `DoorTransition` PUSH mode).

## Code implications (future tasks — NOT done here)
Recorded as flags in [[ideas]]; these contradict current code and are separate features:
1. Bare-fists deal **no** damage (today an unarmed swing hurts monsters).
2. **Flute-gate**: block combat AND soothe until the flute is found (today both work immediately).
3. **Run-only pre-flute** behaviour.
4. **Build Echo** (the bird companion is not implemented yet).
5. Traversal-without-a-mount is a level-design concern (the `[FLAG]` above).
