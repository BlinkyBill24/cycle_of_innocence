---
name: Progression Systems (Age, Morality, Bonds, Abilities)
tags: [mechanics, progression, design]
status: draft
related:
  - "[[design/game-features]]"
  - "[[story/bible]]"
  - "[[characters/companions]]"
---

# Progression Systems

## Overview
Progression in *Cycle of Innocence* is deliberately **narrative and relational** rather than grind-based. The player grows up (age stages), is changed by choices (morality), and forges (or breaks) bonds with animal companions. Power feels earned through life experience and relationships, not arbitrary numbers.

This directly supports the themes of coming-of-age, loss of innocence, and the cost of the cycle.

## Age Stages

Unlocked via major story milestones (not XP).

| Stage   | Approx. Age | Visual Changes                  | Mechanical Unlocks                          | Narrative Feel                  |
|---------|-------------|---------------------------------|---------------------------------------------|---------------------------------|
| Child   | 9-11       | Small sprite, big eyes, light movement | Limited reach, vulnerable, innocent dialogue options | Powerless but hopeful / scared |
| Teen    | 13-16      | Taller, leaner, more confident posture | Better reach, new basic abilities, "adult" conversation branches | Starting to understand the lies |
| Adult   | 18-22+     | Full height, hardened or protective silhouette | Full capabilities, leadership options with companions, "vessel" powers if pursued | The person the cycle tried to prevent |

**Implementation Notes**:
- SpriteFrames or AnimationPlayer swaps + shader parameters (height scaling, posture).
- Some zones/puzzles only solvable after certain ages.
- Dialogue and companion reactions change (elders treat a child differently than an adult "threat").

## Morality / Alignment

Numeric value (-100 to +100) with tiers. Changes through meaningful choices, not every action.

**Tiers**:
- **Innocent / Empath** (-100 to -40): Kind, protective. Better bonds, calming abilities, some NPCs open up.
- **Wounded** (-39 to +39): Pragmatic middle. Balanced but no strong bonuses.
- **Hardened** (+40 to +80): Ruthless survivor. Power-focused abilities, intimidation, companions used as tools.
- **Vessel** (+81 to +100): Deeply marked by the Hunger. Unique corrupted powers, high risk of companion loss or turning.

**Consequences** (visible and mechanical):
- Appearance (scars, glow, posture, "wrong" details on high corruption).
- Companion bond curves (kindness makes bonds stronger and more resilient; ruthlessness makes them more powerful but fragile/corruptible).
- World reactivity (fear, respect, or recognition as "the one who escaped").
- Available dialogue and puzzle solutions.
- Ending eligibility (some paths close or open).

**Sources of Change**:
- Major story choices (see choice-matrix).
- How you treat companions (care vs exploitation).
- Revelations accepted or rejected.
- Actions during horror events (protecting the innocent vs sacrificing them).

## Companion Bond & Corruption

See [[characters/companions]] for narrative depth. Gameplay layer:

- **Bond** (0-100+): Trust and love. High bond = reliable assists, willingness to take risks for you, unique positive scenes.
- **Corruption** (0-100): The Hunger's influence. High corruption = stronger but dangerous abilities, risk of refusal, body horror, potential betrayal or tragic fate.

**Care vs Use**:
- Positive actions (feed, soothe, protect, play) raise bond and can reduce corruption.
- Negative actions (force into danger, ignore fear, use as weapon) raise corruption and can lower bond.

**Upgrades**:
- Bond milestones unlock new companion abilities or passive bonuses.
- Some powerful moves are "corruption abilities" — use them too much and the companion (or Rowan) pays a permanent price.

## Ability / Skill Progression

No traditional skill trees or XP levels. Unlocks come from:

1. **Age** (core physical/social growth).
2. **Morality Branches** (Empath vs Ruthless paths + middle "Wounded" options).
3. **Companion Bonds** (each companion brings 2-4 unique abilities that improve with bond).
4. **Revelations** (knowing the truth literally gives you new tools — e.g., a song or gesture that works on a specific horror because you learned its origin).

**Example Ability Categories**:
- **Empath**: Calm lesser horrors, heal minor companion wounds, non-lethal takedowns, better information from NPCs.
- **Ruthless / Vessel**: Corrupted strikes, intimidation that breaks enemy morale, force companions into high-risk moves, temporary power boosts at personal cost.
- **Hybrid**: Creative or tragic combinations (e.g., using a corrupted companion's power in a redemptive way).

**Menu**: "Growth" or "Memory" screen showing current age, morality, companion status, and unlocked abilities. Simple and thematic. **Journal of observed signs** (research 2026-06-12; ✅ v1 built 2026-06-13 — `Journal` autoload + `JournalPanel`, toggle **J**): entries appear only when the player witnessed the corresponding world change — Rowan's inference, not game state ([[mechanics/hollowing-clock]] doom legibility); NG+ pre-seeds via `$knew_it_was_coming` (hook reserved, not yet auto-populated). LORE entries (dug keepsakes) and DOOM entries (observed signs of the net closing) share one witnessed-only, idempotent, save-round-tripped store. **The panel is now the Growth/Memory menu** (2026-06-13): a stats header (name · morality tier · Briar bond) over the observed-signs list, toggle J. **Hard rule** (secrets research 2026-06-13, [[design/secrets-and-discovery]]): this is a **memory aid for witnessed things, never a quest log / checklist** — the Outer Wilds ship-log / Obra Dinn logbook line (logbook only inscribes a fate once deduced; Lorelei's "photographic memory" stores what you saw but never solves for you). Hold that line. `[verified 2026-06-13]`

## NG+ & Knowledge Carry-Over

- Morality, known revelations, and companion "echo" states carry over.
- New playthroughs have altered dialogue, some events play differently with foreknowledge, and you can pursue "what if" paths (e.g., trying to save a companion you lost before).
- This is a major source of replayability alongside different morality/ending combinations.
- **Loop-memory dialogue** (research round 2, In Stars and Time): companion echoes surface as *fractional* remembered details, not full recall — Briar hesitates at the spot where he died last run; Echo repeats one word from a timeline that didn't happen. Small authored moments per echo state; see [[design/feature-candidates-2026-06]]. NG+ also starts zones pre-recontextualized via carried revelations ([[mechanics/zone-recontextualization]]).
- *Design-language note*: NG+ echoes are **authored scripted moments** keyed to saved flags — never procedural NPC evolution or hierarchies ([[decisions/2026-06-10-patent-risk-review]]).

## Technical Implementation Priorities (Godot)

- PlayerData as the single source of truth for age_stage, morality, companion states, unlocked abilities.
- Signals on every change (age_advanced, morality_changed, bond_changed, ability_unlocked, revelation_unlocked).
- Visual system: player + companion visual nodes listen to state and swap sprites / apply shaders.
- dialogue integration: all progression variables exposed so dialogue can react immediately.
- Persistence: SaveManager handles the full state (including custom names from character creation).

**Scope Guardrails**:
- Keep ability count small and impactful (10-15 total meaningful abilities across all sources in v1).
- Every progression element must have clear visual, mechanical, *and* narrative feedback.
- No grinding. If a player feels they need to "farm" to progress, the design is wrong.

See also the high-level features in [[design/game-features]] and companion details in [[characters/companions]]. Update this document as we prototype and discover what feels best in play.