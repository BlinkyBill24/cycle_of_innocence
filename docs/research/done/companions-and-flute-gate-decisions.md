---
name: companions-and-flute-gate-decisions
date: 2026-06-21
source: design conversation (Steffen)
prompt: "Record two-companion design, push-to-open / bare-fists / run-until-flute mechanics, flute-as-soothe-gate story rule, and the cut of Storm the mount."
status: integrated
---

> **Librarian pass — integrated 2026-06-21** (branch `docs/companions-flute-gate`). These
> are Steffen's OWN design decisions, so they become canon (not external research to vet).
> Recorded as a decision: [[decisions/2026-06-21-companions-and-flute-gate]]. Applied to the
> canonical brain (`AGENTS.md`) and live docs: [[characters/companions]], [[story/bible]],
> [[design/game-features]] (roster → two; Storm CUT with history kept), [[mechanics/combat]]
> (bare-fists + run-only), [[mechanics/encounters-mercy]] (flute gates all interaction). The
> CODE consequences (bare-fists no-damage, flute-gate, run-only, build Echo, traversal flag)
> are captured as tasks in [[ideas]] — NOT implemented in this pass. Archived `research/done/`,
> `sessions/`, and `_compiled/` Storm mentions left as history.

# Companions & Flute-Gate Decisions

All items below are Steffen's own design intent recorded verbatim from a design
conversation. They are tagged `[design decision]`, not `[verified]` — these are
choices, not externally checkable facts.

## Mechanics

- **Push to open doors.** [design decision] Doors must be actively pushed open,
  not walked through. Consistent with the existing "push to open" door rule.
- **Bare fists cannot harm monsters.** [design decision] Unarmed Rowan cannot
  damage a monster. Harming a monster requires a real tool/weapon, never hands.
- **Run-only before the flute.** [design decision] Until Rowan finds the flute,
  the only valid response to a monster is to flee. No fighting, no soothing
  pre-flute.

## Story

- **Flute is the single gate to all monster interaction.** [design decision]
  Rowan must find a flute (or some other instrument) before *any* monster
  interaction — soothing or allying — becomes possible. The instrument is the
  one key that unlocks the entire mercy/soothe system. This resolves a prior
  consistency question: soothe-combat and the "glow when fully allied" indicator
  both assume Rowan can win monsters over; the flute is what makes that possible,
  and nothing in that system is reachable before it.

## Companions — two, by design

Decision: the game uses **two** companions. A third animal was considered and
rejected as unnecessary; the two below already cover separate lanes (ground/air,
close/far) without overlap. [design decision]

- **Briar (dog) — owns the ground.** [design decision] Points to dig spots and
  secret doors; defends Rowan from attacks. Matches the Hollow House micro-quest,
  where Briar points to a hidden book/dig spot.
- **Echo (bird) — owns the air.** [design decision] Attacks from above; scouts;
  warns about monsters from afar; finds hidden treasure. Defends Rowan from
  attacks.

Shared role: both companions' core job is to **defend Rowan from attacks**.
[design decision]

## Cut

- **Storm (the mount) is cut.** [design decision] The third companion slot is
  removed entirely; the animal was negotiable and no specific need pulled toward
  keeping a mount (or any third animal).
  - **Flagged consequence:** [FLAG] any traversal that was implicitly leaning on
    a mount — crossing water, spanning gaps, covering long distances — now has no
    animal solution. Traversal becomes a **level-design problem** (paths, bridges,
    gated routes) rather than a **companion** problem. Worth confirming before
    any zone layout assumes mounted movement.
  - **System impact:** the companion bond/corruption system now maintains **two**
    tracks instead of three — less content to author, which fits the current
    content-drought reality.

## Notes for the librarian

- Cross-check the two-companion decision against any existing vault doc that still
  references Storm or a third/mount companion; those references are now stale.
- The flute-gate rule should be reconciled with the mercy/soothe combat doc and
  the "glow when fully allied" goal prompt so the unlock timeline is unambiguous.
