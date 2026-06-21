# Session — Eat-vs-feed choice ("share or keep")

Branch: `feat/eat-vs-feed-choice`. Resolves the dual-use dispatch flag from the
food-healing work.

## What this adds (plain language)

Two foods — **Forest Berries** and **Dried Meat** — can either heal Rowan OR be
given to Briar (raising the bond). Before, tapping them always ate them and you
couldn't give them to Briar from the menu at all. Now:

- Tapping a **dual-use** food opens a small prompt: **Eat** (heal Rowan) or
  **Give to Briar** (+bond). You choose at the moment of use — the "share your
  scarce food, or keep it for yourself" tension the story bible is built around.
- **Single-purpose** items act instantly, no prompt: Hearty Meal / Honeycomb are
  eaten; the Buried Bone is given to Briar; keys/notes are inspect-only.
- The satchel detail line now tells you what tapping will do ("Tap: eat to heal,
  or give to Briar"), so the action is never a mystery.

Nice touches: if Rowan is already at full health, the **Eat** button is greyed out
and the prompt lands on **Give** instead — so you're never handed a button that
does nothing. The prompt is keyboard/gamepad/touch friendly (Left/Right to pick,
Esc to cancel).

## Why this design (decision)

The bible wants food **shared** between Rowan and Briar as a deliberate resource
dilemma — not split into "human food" vs "dog food". So we kept the dual-use items
and added an explicit choice rather than a hidden modifier key or a guess based on
how close Briar is standing. Predictable beats clever. See
`docs/decisions/2026-06-21-food-heal-values.md` (now marked resolved).

## What feeding does for a companion (for the record)

Companions have **no health bar** — feeding doesn't heal them. It raises **bond**
(the relationship score), which unlocks loyalty "quirks". Dried Meat also nudges
Rowan's morality (−3, current placeholder tuning). Feeding is love, not nutrition.

## Verification

- **388 tests pass** (11 new in `tests/test_eat_vs_feed.gd`). `check-brain` clean.
  **Web/HTML5 export builds.**
- Two adversarial review passes (5 dimensions, then a focused re-check). They
  caught and I fixed:
  - **Captive-modal bug (blocker):** keyboard/gamepad focus could slip onto a bag
    slot *behind* the prompt and act on the world. Fixed by guarding the slot
    handler while the choice is up and making bag slots unfocusable. Re-verified closed.
  - **Full-health "dead Eat" (minor):** Eat now disables at full health.
  - **Web-font glyph (minor):** a stray `·` in the hint → plain ASCII (heart glyphs
    don't render in the web export's fallback font).
  - Added modal-level tests (Give feeds, cancel consumes nothing, full-health,
    focus-captivity, dynamic companion naming).

## Scope kept clean

Only `inventory_panel.gd` + tests + the three flag docs changed. No heal/bond/
morality values touched. No HUD change. `project.godot` and the obsidian workspace
deliberately kept out of the commit.

## Known follow-ups (not done here)

- A feed item for **Echo** (every feed item currently targets Briar).
- The Dried Meat **−3 morality** has no narrative justification yet — placeholder.
- Pre-existing em-dash in `weapon_affordance` is a web-font nit (out of scope here).
