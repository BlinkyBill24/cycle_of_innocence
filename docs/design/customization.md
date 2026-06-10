---
name: Customization & Character Design
tags: [design, customization, characters, art]
status: draft
related:
  - "[[design/game-features]]"
  - "[[story/bible]]"
  - "[[characters/companions]]"
  - "[[mechanics/progression]]"
---

# Customization & Character Design

## Philosophy
Customization exists to increase player investment and replayability, **not** to create a full character creator that would explode our pixel art scope.

The most important "customization" in the game is **how the player chooses to live** (morality, how they treat companions, which truths they accept). Visual and mechanical changes should primarily reflect those choices and the passage of time (age).

## Protagonist (Rowan)

### Name
- Player can enter a custom name at the start (or change it later at certain rest points).
- Default: "Rowan" (gender-neutral, fits the story).
- The name is used in dialogue, the journal, companion reactions, and some environmental text.
- Custom names make the found-family moments feel more personal ("Briar only listens to *you*, [Name]").

### Gender
- Selectable: Male / Female / Non-binary / Prefer not to say (or custom text).
- **Visual Impact**: Limited but present.
  - Base sprite silhouette is mostly the same (hooded cloak + tunic works across genders).
  - Minor variations in hair length/style and body shape per age stage.
  - Morality overlays (scars, posture, "marked" details) are the dominant visual change.
- **Narrative Impact** (subtle but meaningful):
  - Some elders and villagers have old-fashioned or fearful views ("the girl who escaped," "the boy who was marked").
  - Certain dialogue lines and rumors change.
  - Companion bonds can have slight flavor differences (Briar might be more protective of a "little sister" figure, etc.).
  - Keeps the core story and all major beats universal while adding replay texture.
- **Technical**: Store as a flag or string in PlayerData. Use it for Yarn variables (`$player_gender`, `$player_name`) and a few conditional sprite layers if needed.

### Appearance Progression (Age + Morality)

This is the **real** customization system.

**Age Stages** drive major silhouette and animation changes:
- Child: Small, rounder, big eyes, lighter step.
- Teen: Taller, gangly, more angular.
- Adult: Full height, weight in the stance.

**Morality / Corruption** drive palette, details, and "wrongness":
- High kindness (Innocent/Empath): Cleaner colors, small protective tokens (flowers, handmade items), warmer lighting on the sprite.
- Middle (Wounded): Mixed — some wear, some resolve.
- High ruthlessness (Hardened/Vessel): Scars (including ritual marks that spread), darker/dirtier palette, glowing "marked" eyes or veins, hunched or aggressive posture. Companions may start mirroring the corruption visually.

**Player Influence**:
- Early choice of a small color accent (cloak trim, ribbon, etc.) that can persist or get corrupted.
- How you treat companions can influence small details on Rowan (e.g., wearing a token Briar brought you only appears on high bond paths).

**Art Scope**:
- 3 age stages × 3-4 morality tiers per gender option = manageable sprite work.
- Use base sprites + recolor + overlay layers + shaders for efficiency (glow, dirt, vein effects).
- Companions get similar treatment (growth + corruption variants are higher priority than protagonist variants because they carry more emotional weight).

## Companion Customization

### Naming
- Player names each companion when they join (or renames later).
- This is one of the most important immersion features.
- A custom-named Briar that you've raised from a terrified pup to a loyal (or corrupted) adult feels *yours*.

### Visual / Personality Flavor
- Main visuals are driven by growth stage + bond/corruption (see [[characters/companions]]).
- Minor player expression:
  - Choosing a simple accessory or color for a "collar" or token during a bond moment.
  - These are mostly cosmetic but can appear in certain cutscenes or the journal.

**No deep pet creator**. The story and corruption arcs are the customization.

## Other Customization

- **Difficulty / Accessibility "Customization"**:
  - Horror intensity slider (0-100%). Reduces visual/audio horror effects and some body horror visuals while preserving mechanical and story consequences.
  - Color blind modes.
  - Control presets (including single-stick or auto-assist options for accessibility).
- **Playstyle Expression** (via Morality + Companion Choices):
  - This is the deepest form of "build." An Empath playthrough plays and looks very different from a Vessel playthrough.
  - Different companion survival combinations in NG+ create very different "teams."

## Technical & Art Pipeline Notes

- PlayerData holds: custom_name, gender, chosen_accent_color, age_stage, morality.
- Visual system listens to these values and applies the correct SpriteFrames / modulate / shader.
- Yarn exposes the same values so dialogue can react ("Even after everything, you still call yourself [Name]?").
- All major visual changes must be readable at the target internal resolution (426x240 or whatever the pixel pipeline uses).

**Scope Warning**: If a customization idea requires new full sprite sheets for every age/morality combination, it is probably too expensive. Prioritize shader + overlay solutions and story-driven changes.

See [[design/game-features]] for the broader feature vision and [[mechanics/progression]] for how these visual choices tie into actual gameplay systems. The goal is that by the end of a playthrough, the player should look at their Rowan and companions and immediately feel the weight of every choice they made.