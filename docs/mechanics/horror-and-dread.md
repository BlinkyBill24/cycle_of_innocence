---
name: Horror & Dread Mechanics
tags: [mechanics, horror, design, atmosphere]
status: draft
related:
  - "[[design/game-features]]"
  - "[[mechanics/combat]]"
  - "[[story/bible]]"
---

# Horror & Dread Mechanics

## Core Vision
Horror is not just "scary enemies." It is systemic, psychological, and deeply tied to the story of the cycle and the player's choices.

The game should make the player feel:
- Vulnerable as a child.
- Increasingly powerful but more alone/corrupted as an adult.
- That every bond with a companion is both a source of strength and a potential new vector for tragedy.

## The Dread System

**Dread Meter** (0-100):
- Rises in:
  - Dark or ritual-heavy zones.
  - Proximity to Hunger manifestations or corrupted beings.
  - After major revelations (knowledge makes the world scarier).
  - When companions are low on bond or high on corruption.
- Falls slowly in safe, well-lit areas or after successful care actions with companions.

**Effects of High Dread** (stacking):
- Visual: Increasing vignette, desaturation, film grain, occasional color shifts or "memory bleed" overlays.
- Audio: Heartbeat, distant whispers, muffled or distorted music, companion vocalizations become anxious or pained.
- Gameplay:
  - Slower stamina/dodge recovery.
  - Companions hesitate or cower (lower assist reliability).
  - Occasional false positives (sounds or brief enemy silhouettes that aren't real).
  - On very high dread: Rowan may experience brief "visions" or loss of control moments that tie into their personal guilt/morality.

**Technical**:
- Global or zone-based DreadManager.
- Multiple layered post-process effects (shaders) that can be toggled by intensity.
- Audio bus routing for dynamic mixing.
- Companion AI states that react to current dread level.

## Body Horror & Corruption

This is the most personal form of horror and is directly tied to the morality and companion systems.

**On Rowan**:
- High ruthlessness or repeated exposure slowly "marks" them (glowing veins, wrong-colored eyes, posture changes, small physical mutations).
- These are visible on the sprite and can affect dialogue ("You look more like one of them every day").
- At extreme levels, some abilities become permanently corrupted (stronger but with side effects or companion disapproval).

**On Companions**:
- The most emotionally devastating vector.
- High corruption changes their appearance (matted fur, wrong eyes, exposed Hunger-stuff, hunched aggressive stance).
- Behavior changes: A once-loyal Briar may growl at Rowan, refuse commands, or even attack during a moment of stress.
- In extreme cases, a companion can fully turn and become a recurring horror or a required boss-like encounter.

**Thematic Purpose**:
- Punishes ruthless "power at any cost" playthroughs in a way that hurts.
- Makes the kind/empathetic path feel like active resistance against the cycle.
- Gives the player something precious (their only family) that they can lose or twist through their own choices.

## Psychological & Revelation Horror

- Some threats only exist or become aggressive after the player has learned certain truths (you can't un-see the cycle).
- Guilt manifestations: After particularly cruel choices, Rowan may be haunted by visions or voices of the people/animals they failed.
- The "monsters" having familiar elements (a scrap of clothing, a mannerism) that only become obvious after revelations.
- Companion reactions to revelations can be as horrifying as any enemy (watching Briar realize what the "monsters" really are).

## Accessibility & Player Control

**Horror Intensity Slider** (0-100%):
- 100% = full intended experience (recommended for first playthrough).
- Lower values reduce or remove:
  - Heavy visual distortion and body horror details.
  - Jump-scare style audio stingers.
  - Some psychological vision sequences.
- **Important**: Mechanical consequences (bond loss, corruption gain, combat difficulty from dread) remain. The story and choice weight are never compromised.

Additional options:
- Color-blind friendly dread cues (patterns + color).
- Option to reduce companion fear animations if they become too stressful.
- "Story mode" combat assist that makes real-time combat slightly more forgiving without removing tension.

## Atmosphere Tools (Godot)

- 2D lighting + occluders for pools of safety vs oppressive darkness.
- CanvasModulate for global color shifts.
- Multiple post-process shaders (pixelate + horror-specific: grain, vignette, chromatic aberration, "memory" distortion).
- Adaptive music system (layers that fade in/out based on dread + zone + companion state).
- Environmental storytelling: ritual remnants, old child-sized footprints, scratched warnings that only make sense after certain revelations.

## Small-interior dread toolkit (cheap, transferable) `[verified 2026-06-13]`

For an authored interior beat ([[design/hollow-house-quest]]), dread is built
from layered low-cost techniques that map onto existing systems:

- **Fear emitter (audio-first).** Scale the [[mechanics/adaptive-audio]] dread
  stem (and stinger readiness) by **proximity to the threat or the hidden truth**
  — Dead Space's tools scaled music/SFX by distance to threats/key events. A low
  drone under the bed reads as unease better than a melodic score.
- **Darkness defines legibility.** A dark interior where Briar + a small light
  radius reveal what's legible ([[mechanics/vision-and-darkness]]) — the dark
  hides the clue *and* the dread; chiaroscuro lets the player project fear into
  the unlit negative space.
- **Companion fear as foreshadowing.** Briar refusing a room / staring at an
  empty corner ([[mechanics/companion-quirks]]) is a free diegetic amplifier —
  and *foreshadows* a [[mechanics/zone-recontextualization]] reveal (she fears
  the room before the player learns why; pays off again on NG+).
- **Stinger reserved for the turn.** Hold the single audio stinger for the
  recontextualization beat (the truth reframing the space), not for cheap scares.

## How Horror Serves the Story

Every horror element should ultimately point back to the central conspiracy:
- The cycle creates the monsters.
- The "protectors" are complicit.
- Your bonds are the only thing keeping you human — and the cycle wants to take them too.

See [[mechanics/combat]] for how dread and corruption specifically affect fighting, and [[design/game-features]] for the broader vision. Horror here is a feature of the world and the player's soul, not just set dressing.