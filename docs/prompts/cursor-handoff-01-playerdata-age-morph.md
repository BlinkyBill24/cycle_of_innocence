# Cursor Hand-off Prompt: PlayerData + Age/Morality/Companion States + Basic Visual Morph

**Context for Cursor (paste this entire block at the start of your prompt in Cursor/Continue.dev):**

You are an expert Godot 4 GDScript developer working on "Cycle of Innocence", a 2D top-down horror-conspiracy RPG.

**Mandatory References (read these files first using your tools):**
- AGENT_RULES.md (root of project)
- docs/story/bible.md (especially the revised Background section with lottery/Community Harmony Score, playground ritual using creepy clowns/stuffed animals/living toys, villagers believe the ritual "succeeded" and do not notice the escape initially, and escalation creating more monsters)
- docs/characters/companions.md (Briar the hound as first companion, emotional heart; Echo and Storm planned)
- docs/design/game-features.md (sections on Character Creation, Protagonist Progression (Age + Morality), Companion System, Progression Systems)
- docs/mechanics/progression.md (detailed age stages, morality tiers, companion bond/corruption as core progression)
- docs/mechanics/companion.md (if exists) or the companions section in game-features.md
- scripts/autoload/player_data.gd (current basic implementation)
- scripts/player/player_controller.gd (current implementation with age_stage enum stub and apply_age_visuals)
- The player.tscn and any existing visual setup

**Project Rules (strict):**
- Vertical slice scope ONLY: Child Rowan (age 9-10) + Briar (hound pup) in one small semi-open playground/fringes zone.
- Keep everything modular and signal-driven.
- Reference the full story bible for flavor (Rowan as escaped sacrifice, animal companions as found family, morality with visible consequences).
- No scope creep beyond the tiny playable core defined in AGENT_RULES.md.
- Use typed GDScript where possible.
- All progression must tie to story (age progression visuals change silhouette/animations; morality affects appearance + companion states + world reactivity).

**Task:**
Extend the existing PlayerData autoload and create a basic visual morph system for age + morality + companion states.

1. **PlayerData (scripts/autoload/player_data.gd)**:
   - Expand to fully support:
     - age_stage: enum AgeStage { CHILD, TEEN, ADULT }
     - morality: float (-100 to +100)
     - companions: Dictionary (keyed by StringName like &"briar", with sub-dict: bond: float, corruption: float, growth: float, alive: bool)
   - Add signals:
     - age_advanced(new_stage: int)
     - morality_changed(new_value: float, delta: float)
     - bond_changed(companion_id: StringName, new_bond: float)
     - corruption_changed(companion_id: StringName, new_corruption: float)
     - revelation_unlocked(revelation_id: StringName)
   - Add helper methods (with proper clamping and signal emission):
     - set_age_stage(stage: AgeStage)
     - change_morality(delta: float)
     - set_companion_bond(id: StringName, bond: float)
     - set_companion_corruption(id: StringName, level: float)
     - unlock_revelation(id: StringName)
     - is_revelation_known(id: StringName) -> bool
     - reset_to_defaults() (keep existing behavior)
   - Persist custom_name, gender, chosen_accent_color if not already present.
   - Ensure reset_to_defaults handles the new fields.

2. **Basic Visual/Age-Morph System**:
   - Create a new script: scripts/player/age_morph.gd (or extend existing player visual).
   - This should be attachable to the player scene or called from player_controller.
   - On age_stage or morality change (listen to PlayerData signals or poll), update:
     - Swap or modulate the AnimatedSprite2D frames (use existing player_sprite_frames.tres patterns; for now stub different "child" vs "teen" variants via modulate or simple scale/offset for silhouette).
     - Apply visual effects for morality (e.g., slight color shift toward warmer for positive/innocent, darker/colder + subtle "marked" overlay for negative/ruthless).
     - For companions (start with Briar only for vertical slice): basic state that can later drive companion visuals (e.g., a signal or exported method to apply bond/corruption tint or animation speed).
   - Keep it simple for vertical slice: focus on child Rowan + Briar. Use modulate + shader param stubs (reference existing horror shaders if present). No full new sprite sheets yet — use placeholders or the current sprites with visual tweaks.
   - Expose a method like apply_visual_state(age: AgeStage, morality: float, companion_states: Dictionary)

3. **Integration**:
   - Wire PlayerData signals in player_controller.gd (or a new visual handler).
   - Update the existing player.tscn if needed to include the age_morph node/script.
   - In the small test zone (playground/fringes), add a temporary test node (e.g., a Area2D or button) that calls PlayerData.set_age_stage or change_morality to demo the visuals.
   - Ensure companion state (Briar) is initialized on game start (bond high, corruption low for child section).
   - Update autoload registration if any new files.

**Output Requirements (strict format):**
- Complete, ready-to-paste GDScript for player_data.gd (full updated file) and age_morph.gd (new file).
- Exact step-by-step integration instructions (file paths, what to add where in existing player_controller.gd, scene edits, resource updates).
- A clear test plan:
  - Load the small playground/fringes zone.
  - Verify child visuals on start.
  - Trigger a test morality shift (positive and negative) and observe visual changes.
  - Trigger age-up stub and verify silhouette/animation feel change.
  - Verify companion (Briar) state can be read/written and would affect visuals later.
  - F5 test: movement + basic attack still works; no errors in console.
  - Bonus: Check that signals fire and can be listened to (e.g., in a debug HUD).

**Constraints:**
- Vertical slice only — child Rowan + Briar. No full adult sprites or other companions yet.
- Do not change combat, puzzles, or dialogue yet (those are separate hand-offs).
- Preserve all existing code/comments in player_data.gd and player_controller.gd.
- Follow Godot 4 best practices and the modular architecture in AGENT_RULES.md.
- Make it feel narrative: comments should reference story (e.g., "Age progression reflects Rowan's loss of innocence per bible").

After you generate the code and steps, I (or the user) will test in Godot and paste any errors/logs back for fixes. Keep scope extremely tight.

Reference the vertical slice definition in AGENT_RULES.md for the exact exit criteria of this slice.

Generate the output now.