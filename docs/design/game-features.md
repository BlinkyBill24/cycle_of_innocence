---
name: Game Features & Systems Overview
tags: [design, features, mechanics, scope]
status: draft
related: [[story/bible]], [[characters/companions]], [[mechanics/progression]], [[mechanics/combat]], [[design/customization]]
---

# Cycle of Innocence — Game Features & Systems Overview

This document captures brainstormed features for the 2D top-down action-adventure RPG. All features are designed to support the core vision from the story bible:

- Coming-of-age amid conspiracy and loss of innocence.
- Found family through **animal companions** (Briar the hound, Echo the bird, Storm the mount).
- Real-time action combat with light companion assists (Zelda + Secret of Mana feel).
- Branching narrative, morality system with visible consequences (appearance, bonds, world reactions, endings).
- Horror atmosphere that escalates with revelations (body horror, psychological dread, isolation).
- Replayability via choices, companion fates, multiple endings, and NG+.

**Scope Philosophy (Indie Solo-Friendly)**:
- Focused single-player campaign (6-10 hours v1).
- Vertical slice first: one zone as child Rowan + Briar, basic real-time combat, one companion-assisted puzzle, one meaningful Yarn choice, light horror beat.
- Prioritize emotional impact and replay over breadth.
- Cut anything that doesn't serve story, companions, or horror.
- Pixel art 32x32 limits (age/morality variants via sprite swaps + shaders, not hundreds of outfits).
- Leverage Godot strengths: AnimationPlayer, 2D lights/shaders for dread, Yarn for branching, signals for systems.

**Key Pillars**:
1. **Age & Life Progression** (Fable-inspired): Child → Teen → Adult. Visuals, reach, dialogue options, and world perception change.
2. **Morality / Alignment**: Numeric or tiered (Innocent / Wounded / Hardened / Vessel). Affects appearance (scars, glow, posture), companion bonds/corruption, NPC reactions, available abilities, and endings.
3. **Animal Companions as Core "Party"**: Rescue, name, raise, bond, use in exploration/combat/puzzles. Corruption is a major horror vector.
4. **Real-time Action + Horror Tension**: Fluid movement/combat that gets scarier as dread rises or corruption spreads.
5. **Branching Truths**: Yarn-driven dialogue where revelations change everything. Choices have delayed, compounding consequences.
6. **Atmosphere First**: Dynamic lighting, shaders, adaptive audio, and companion behavior sell the dread.

---

## 1. Character Creation & Customization

**Protagonist (Rowan)**:
- **Name**: Player can pick a custom name (default "Rowan" — gender-neutral to fit story). Name appears in dialogue, journals, and some companion reactions.
- **Gender**: Selectable at start (Male / Female / Non-binary / Custom). 
  - Mostly cosmetic for pixel art (base sprite silhouette + minor hair/clothes tint variations per age).
  - Narrative impact: Some elders/NPCs have gendered biases or different dialogue (e.g., "the girl who got away" rumors). Companions react slightly differently (Briar more protective of "sister" figure, etc.). Keeps core story universal.
  - Appearance changes with age + morality (see below).
- **Starting Appearance**: Fixed base (simple tunic with ritual tear) but player can choose a small color accent (cloak trim, ribbon) that persists or shifts with morality.
- **Later Customization**: Limited. Morality and age drive the biggest visual shifts. High kindness = cleaner, warmer palette + small protective tokens. High ruthlessness = scars, darker tones, "marked" glow. No heavy character creator to keep art scope manageable.

**Companions**:
- **Naming**: Player can rename each companion when they join (or later at a "rest" point). 
  - Affects immersion and some Yarn lines ("Briar" vs custom name).
  - Default names: Briar (hound), Echo (bird), Storm (mount).
- **Visuals**: Growth stages (puppy → adult) + corruption variants are the main "customization." Minor bond-based details (handmade collar color chosen by player? simple accessory).
- **Personality Flavor**: Fixed core personalities from story bible, but bond level changes behavior (fearful vs brave, loyal vs resentful).

**Technical**:
- SpriteFrames resources per age stage + morality tier (or base + shader params + overlay sprites for scars/glow).
- PlayerData stores custom name, gender flag, chosen accent color, companion custom names.
- Yarn variables: `$player_name`, `$player_gender`, `$companion_name_briar`, etc.

**Scope Note**: Full character creator is out of v1 scope. Focus on age/morality as the "customization" that matters thematically.

---

## 2. Protagonist Progression (Age + Morality + "Growth")

Not traditional RPG levels. Progression is narrative and systemic, tied to story beats.

- **Age Stages** (unlocks via story milestones):
  - Child: Small hitbox, lower reach (can't climb high ledges alone), innocent dialogue options, vulnerable in combat.
  - Teen: Taller sprite, better reach, new abilities (e.g., throw items farther), more "adult" conversation options.
  - Adult: Full capabilities, leadership options with companions, but also more "marked" if corrupted.
  - Visuals + animation changes (walk cycle weight, idle breathing, attack windup).

- **Morality System**:
  - Range: -100 (Innocent/Empath) to +100 (Ruthless/Vessel).
  - Tiers: Innocent, Wounded, Hardened, Vessel.
  - Effects:
    - Appearance (as above + companion visual feedback).
    - Dialogue availability (kind options close off at high ruthlessness).
    - World reactivity (villagers fear or revere you; animals approach or flee).
    - Companion bond vs corruption curves.
    - Ability branches (see Skills below).
    - Ending flags.

- **"Experience" Sources** (light, story-focused):
  - Story milestones & revelations (biggest).
  - Companion bond milestones.
  - "Defeated" or calmed threats (not grindy combat XP).
  - Care actions for companions.

- **Technical**: PlayerData.age_stage, .morality. Signals on change (age_advanced, morality_changed). Sprite/animation swap logic in player controller + visual components. Shader params for "marked" corruption look.

---

## 3. Companion System (The Heart of Found Family & Horror)

See [[characters/companions]] for deep story arcs. Here are the gameplay features.

- **Rescue & Joining**: Story-driven (Briar in escape, others later). No "recruit any animal."
- **Raising / Care Mechanics**:
  - Feed (foraged or bought items — light inventory).
  - Soothe / rest after dread events (reduces corruption, increases bond).
  - Protect in combat (player can take hits for them or vice versa).
  - Play / bond moments (mini cutscenes or quick interactions).
- **Bond & Corruption**:
  - Bond: 0-100+. High bond = better assist performance, unique dialogue, willingness to take risks for you.
  - Corruption: 0-100. High corruption = powerful but dangerous abilities, risk of refusal or turning on player, body horror visuals.
  - Balance: Kind playthroughs keep high bond/low corruption (companions stay "themselves"). Ruthless playthroughs gain power but risk losing or perverting the only family you have.
- **Abilities & Assists** (real-time, not menu heavy):
  - Contextual (press interact near diggable spot → Briar digs).
  - Quick commands (radial or hotkey for "Briar, attack!" or "Echo, scout!").
  - Special moves that cost bond or risk corruption (e.g., "Briar's Last Stand" — powerful but injures him).
  - Puzzle integration: Briar digs, Echo carries small keys or triggers distant switches, Storm charges barriers or provides elevated vantage.
- **Visual & Behavioral Feedback**:
  - Growth sprites.
  - Posture, ear position, eye glow change with bond/corruption.
  - In combat: loyal dog fights beside you; corrupted version may attack wildly or ignore commands.
- **Fates**: Companions can die, be lost, be corrupted into enemies, or survive in different states across endings. NG+ carries "echoes" (they remember previous runs in subtle ways).

**Technical**: CompanionManager autoload. Each companion is a scene with its own state machine (bond, corruption, current abilities). Signals to PlayerData and Yarn. Dedicated companion visual nodes that swap sprites based on state.

**Scope**: 3 main companions max in v1. Deep systems for them > shallow systems for many.

---

## 4. Combat (Real-Time Action with Tension)

Locked to real-time (Zelda/Mana inspired), not the old pause-and-command prototype.

- **Core Loop**:
  - 8-direction movement (from existing player_controller).
  - Basic attack (melee or simple projectile) with facing.
  - Dodge / i-frames (costs stamina or just timing).
  - Companion assists (as above).
- **Horror Layer**:
  - Dread meter (rises in dark zones, after revelations, near corrupted things). High dread = screen effects, slower stamina regen, companion fear behaviors, distorted audio.
  - Body horror: On high personal or companion corruption, attacks may have secondary effects (player or companion takes self-damage, or gains temporary power at cost).
  - "Unknown Threats": Some enemies only appear or become aggressive after certain revelations (psychological).
- **Enemy Types** (tied to story):
  - Corrupted previous offerings (body horror, familiar tragic elements).
  - "Wardens" / human hunters (more tactical, dialogue before/after fights).
  - Hunger manifestations (abstract, terrifying, change based on morality).
- **Death & Recovery**: Not permadeath for story. "You wake at the edge of the woods" or with companion aid, but with consequences (bond drop, new rumor, time passes = age or event advance?).
- **No Traditional Leveling**: Power comes from age, morality branches, companion upgrades, and story items.

**Technical**: Real-time hitboxes (Area2D), state machine in player (already stubbed), companion AI states, global DreadManager that affects multiple systems. Screenshake, hitstop, sound stingers for juice.

**Scope**: Keep enemy variety focused. Polish 4-6 enemy types well rather than many shallow ones. Companion assists are the "party" depth.

---

## 5. Inventory & Items

Light, purposeful (classic action-adventure, not RPG bloat).

- **Categories**:
  - Key Items (ritual fragments, companion care tools, story objects that unlock new dialogue or zones).
  - Consumables (food for companions or self, temporary dread reducers, simple healing).
  - "Memory" / Journal items (collectible lore that feeds revelations).
- **Companion "Inventory"**: Care items are shared but some are companion-specific (e.g., a special whistle for Echo).
- **Limits**: Small grid or list (8-12 slots). No selling or complex crafting in v1.
- **Morality Flavor**: Some items have different effects or descriptions based on current morality (a "kind" herb soothes; a "ruthless" version poisons or empowers).

**Technical**: Simple Inventory resource or array in PlayerData. UI that feels retro but readable. Items can trigger Yarn commands or companion state changes.

---

## 6. Skills, Abilities & "Leveling"

Avoid grindy levels. Progression feels earned through life and bonds.

- **Age Unlocks**: Passive (reach, speed, dialogue) + active (new basic moves).
- **Morality Branches** (visual tree or grid in a "Growth" or "Memory" menu):
  - Empath path: Calming abilities, companion healing, non-lethal options, better puzzle solutions via understanding.
  - Ruthless path: Aggressive power moves, intimidation, corrupted companion specials, faster combat.
  - Hybrid / middle path: Balanced or unique "wounded" abilities.
- **Companion Abilities**: Unlock/upgrade via bond milestones. Some are always available, some risk corruption to use.
- **Revelation Abilities**: Knowing certain truths literally gives new options (e.g., a song that calms a specific horror because you learned its origin).

**Technical**: Ability resource database. Unlocks stored in PlayerData. Context-sensitive use (or hotbar for a few). Visual feedback on player/companion sprites when new power is active.

---

## 7. Exploration, Puzzles & World

- **Semi-Open Zones**: Connected areas (woods → village edge → deeper ritual sites → heart of the conspiracy). Backtracking with new age/abilities/companions.
- **Puzzles**: Environmental (push, light/shadow, timing) + companion-gated (Briar digs, Echo scouts from above, Storm charges weak walls). Some puzzles change or become solvable only after revelations.
- **Secrets & Collectibles**: Lore fragments that feed the conspiracy story and unlock extra dialogue/endings. Hidden companion bond moments.
- **World Reactivity**:
  - NPCs remember your age, morality rumors, and whether you've been seen with "monsters" (companions).
  - Some areas are only accessible or safe with high bond companions.
  - Time pressure is narrative (the next Hollowing approaches) rather than strict timer.

---

## 8. Horror & Atmosphere Systems

- **Dread Meter**: Global or zone-based. Rises with proximity to Hunger, after twists, when companions are corrupted or low bond. Effects: vignette, color desaturation, heartbeat audio, companion anxiety behaviors, occasional hallucinations (false enemies or voices).
- **Body Horror Progression**: Visual + mechanical on high corruption (player or companions). Can be partially resisted with high bonds/kindness.
- **Psychological**: Some "enemies" are memories or guilt manifestations that only appear after certain choices.
- **Accessibility**: Horror intensity slider (0-100%) that reduces visual/audio effects but keeps story and mechanical consequences. Color-blind friendly palettes + alternative cues.

**Technical**: CanvasModulate + multiple 2D lights for pools of safety vs dread. Post-process shader (grain, vignette, pulse). Audio buses with low-pass/distor for high dread. Companion state machines react to dread level.

---

## 9. Narrative & Dialogue (Yarn)

- Branching conversations with heavy use of variables ($age_stage, $morality, $bond_*, $revealed_*, custom names).
- Choices have delayed payoffs (a kind choice early can save a companion or open a better ending path much later).
- Companions as active participants in dialogue (they comment, argue, support, or break).
- Multiple playthroughs feel different because of carried knowledge in NG+ and companion memory echoes.

---

## 10. Save, NG+ & Replayability

- **Saves**: Multiple manual slots + auto on zone transitions or major story beats. Cloud-agnostic (local files).
- **NG+**: Unlocks after any ending. Carries: morality, known revelations, companion bond/corruption states (as "echoes"), custom names. New dialogue, slightly altered events, and the ability to pursue different paths with foreknowledge.
- **Replay Hooks**: Different morality playthroughs, different companion survival combinations, hidden "perfect" vs "tragic" routes, speedrun-friendly modes later.

---

## 11. UI, Accessibility & Presentation

- **HUD**: Clean retro-modern. Minimalist in exploration, more info in combat or menus. Evolves visually with age/morality (warmer vs harsher icons).
- **Menus**: Growth/Memory menu (age, morality, abilities, companion status). Journal (revealed truths, companion notes). Inventory (light).
- **Accessibility**:
  - Remappable controls (KB, gamepad, touch).
  - Subtitles + text size.
  - Horror intensity slider.
  - Color blind modes.
  - Reduced motion / simplified effects options.
- **Touch Support**: Virtual stick + context action buttons (from existing godot/ patterns). Auto-detect.

---

## 12. Audio & Music

- Adaptive layers (exploration whimsy → creeping dread → combat tension → horror stingers).
- Companion vocalizations that change with bond/corruption (happy barks vs pained whimpers vs corrupted growls).
- Dynamic mixing based on dread and proximity to Hunger.

---

## 13. Technical & Scope Guardrails

- **Godot 4.x Features to Leverage**:
  - AnimationPlayer + state machines for age/companion visuals.
  - 2D lights + CanvasModulate + custom shaders for atmosphere.
  - Signals everywhere (GameEvents expanded for age, morality, bond, dread, revelations).
  - Yarn Spinner for all branching.
  - Export pipeline (Linux primary, Android touch, Web for itch demo).
- **What We're Cutting for v1**:
  - Deep crafting or economy.
  - Many human party members (animals only).
  - Full open world (focused zones).
  - Voice acting.
  - Heavy multiplayer or co-op.
- **Risk Mitigation**: Every new feature must answer "How does this serve the story, a companion arc, or a horror beat?" If it doesn't, defer or cut.

---

## 14. Greenlit Additions (2026-06-10 research pass)

Four features greenlit after comparative analysis of Darkwood, Fear & Hunger, Undertale, OMORI, World of Horror, Children of Morta, Moonlighter, Eastward, The Last Guardian, and Black & White (see [[decisions/2026-06-10-new-features-and-ai-setup]]). Each has a full mechanics doc:

1. **[[mechanics/encounters-mercy]]** — Soothe/spare resolution for monster encounters (monsters are former sacrificed children; mercy is the Empath combat verb, Domination its Vessel mirror).
2. **[[mechanics/hollowing-clock]]** — Event-driven doom escalation mechanizing the "delayed alarm": the village slowly realizes the ritual failed; the world worsens in 5 stages.
3. **[[mechanics/day-night-hideout]]** — Day/night two-mode loop + hideout safe-camp where companions are tended and saves happen; natural mobile session boundary.
4. **[[mechanics/vision-and-darkness]]** — Line-of-sight facing-cone fog via 2D lights/occluders; companion senses (scent, overwatch, steadiness) extend perception.

All four pass the §13 guardrail test (serve story, a companion arc, or a horror beat) and interlock: night shrinks the vision cone, the clock scales night danger, mercy states can be undone by escalation, and the hideout is the contrast that makes dread legible.

---

## Next Steps for Features

1. Lock story bible (user review in progress).
2. Flesh out individual mechanics docs (see linked files in this vault).
3. Prototype in code: PlayerData + age/morality/companion state first, then real-time combat with one assist, then basic Yarn integration.
4. Generate art bibles for Rowan variants + companions using the new story details.
5. Iterate in vertical slice: one zone that demonstrates age feel, one companion bond choice, one morality-reactive moment, one dread beat.

**Related Documents** (create or expand as we go):
- [[mechanics/progression]]
- [[mechanics/combat]]
- [[mechanics/companions]] (see also characters/companions.md)
- [[design/customization]]
- [[mechanics/horror-and-dread]]
- [[mechanics/inventory]]
- [[mechanics/encounters-mercy]]
- [[mechanics/hollowing-clock]]
- [[mechanics/day-night-hideout]]
- [[mechanics/vision-and-darkness]]
- [[design/ai-production-setup]]
- Story bible and choice matrix for narrative integration.

This feature set keeps the game focused, emotionally resonant, and true to the themes while remaining achievable for a passionate solo or small-team effort. 

*Document created during Phase 0 pre-production. Update as we prototype and playtest.*