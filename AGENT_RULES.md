# AGENT_RULES.md — Cycle of Innocence (Godot 4 + AI Agent Workflow)

**Project**: 2D top-down horror-conspiracy action-adventure RPG.  
**Core Vision** (from approved plan + story bible):  
- Protagonist Rowan (escaped child sacrifice via lottery/Community Harmony Score).  
- Ritual at village playground with creepy clowns/stuffed animals/living toys.  
- Villagers believe rituals "succeed" initially; escalation of sacrifices creates more monsters when Hunger unsatisfied.  
- Animal companions (Briar the hound first, Echo the bird, Storm the mount) as primary found-family and mechanical "party".  
- Real-time action combat (Zelda/Mana style) + light companion assists.  
- Age progression (child → teen → adult) + morality system with visible consequences (appearance, bonds, world reactions, endings).  
- Themes: Coming-of-age amid systemic horror, loss of innocence, cycles of violence (AoT-style twists), found family via animals.  
- Platforms: Linux primary, Android (touch), Web (HTML5). Pixel art 32x32, retro SNES/Zelda + creeping horror atmosphere.  
- Scope: Focused single-player campaign (6-10h v1), replay via choices/morality/companion fates/multiple endings/NG+. Vertical slice first.

**Tech Stack (locked)**:
- Godot 4.x (latest stable, 4.4+), GDScript (typed preferred).
- Dialogue Manager (nathanhoad, pure GDScript, MIT) for branching dialogue — conditions/mutations read & write PlayerData directly (age_stage, morality, bond_*, revelations, custom names). *(Replaced Yarn Spinner 2026-06-10: official Godot addon is C#-only and .NET cannot export to Web in Godot 4.4 — see docs/decisions/2026-06-10-new-features-and-ai-setup.md.)*
- Autoloads: GameEvents, PlayerData (age, morality, companions dict with bond/corruption/growth/alive, revelations, appearance_flags), ZoneManager, CompanionManager, SaveManager, InputManager, DreadManager.
- Structure: test/ as active dev root (modular: scenes/{player,companions,zones,ui,cutscenes}, scripts/{player,companions,autoload,combat,progression,horror,puzzles}, resources, assets/{sprites,shaders,audio}, tools/{sync-to-rpg-adventure.sh, import scripts}).
- Cross-platform: Virtual stick + touch buttons (from godot/ sibling), pixel post-process + resolution manager, export_presets for Linux/Android/Web.
- Art: Grok Imagine first for bibles/sheets (32x32, limited palette, crisp, no AA), Aseprite polish, Godot SpriteFrames + shaders (age/morality/corruption variants, dread effects).
- Audio: Godot AudioStreamPlayer + buses (adaptive layers, companion vocalizations that shift with bond/corruption).
- Versioning: Git (feature/cycle-of-innocence branch only — never main). Monorepo at /home/seitanist/game/. Always sync/overwrite changes into ../rpg-adventure/ then publish via tools/publish-standalone.sh (force allowed per user rule) to https://github.com/tchintchie/rpg-adventure.
- Memory & Docs: 
  - Local Obsidian vault: test/docs/ (home.md, story/bible.md + characters/companions.md + choice-matrix.md + endings.md, design/game-features.md + mechanics/*.md, art/imagine-prompts.md, sessions/, ideas.md, decisions/).
  - Parent: ../docs/ (consult before design; run python3 ../scripts/obsidian/status.py; update handbook if needed).
  - GROK.md (this root + rpg-adventure/GROK.md): Project identity, slice progress table, architecture, critical rules (R1–R6 + publishing/sync + "always update memory"), Imagine pipeline, useful commands.
  - AGENT_RULES.md (this file): Reference in every agent prompt for consistency.
  - Always: Update GROK.md + relevant docs/ at start/end of chunks. Capture to ideas.md. Journal in docs/sessions/YYYY-MM-DD.md (newest first). Run status.py. Use hooks (e.g. ~/.claude/hooks/update-memory-and-rpg-sync.sh).

**Critical Rules (enforced for all agents/you/me)**:
- R1: Branch before changes (feature/cycle-of-innocence). Commit on feature only.
- R2: Read GROK.md + AGENT_RULES.md + story bible + relevant feature docs BEFORE any work.
- R3: Incremental vertical slices — each F5-playable. Prioritize tiny playable core first (child Rowan + Briar in one small playground/fringes zone: movement, basic real-time combat, one companion-assisted puzzle, one dialogue choice with morality impact, simple horror/dread moment).
- R4: Grok Imagine first for assets (bibles before sheets). Document prompts in docs/art/imagine-prompts.md. Aseprite post-process, Godot nearest-filter import.
- R5: Session journal + ideas capture + status.py at checkpoints.
- R6 (new): **Publishing/Sync Always**: After any meaningful changes (even docs/code), run test/tools/sync-to-rpg-adventure.sh (or equivalent), commit monorepo, then rpg-adventure/tools/publish-standalone.sh (force to GitHub). Overwrite old prototype content is allowed/intended.
- Story & Morality First: Every feature/mechanic must tie to story bible (Rowan escape, playground ritual, villager "success" belief + escalation, companion arcs with bond/corruption, twists, 4 endings). Morality (-100 Innocent/Empath to +100 Ruthless/Vessel) affects appearance, companion states, dialogue, world reactivity, abilities, endings. Companions (Briar/Echo/Storm) are mechanical + emotional core — not optional.
- Scope Control: Vertical slice first. Cut anything not serving story/companions/horror/replay. No deep crafting, heavy inventory, many human NPCs, or voice in v1. Horror intensity slider (accessibility) reduces effects but keeps story/mechanical weight.
- Godot Conventions: Typed GDScript where possible. Signals for decoupling (expand GameEvents). State machines (player: EXPLORING/ATTACKING/HURT/CUTSCENE/DREAD_LOCK; companions: bond/corruption states). AnimationPlayer for age/morality visuals + cutscenes. 2D lights + CanvasModulate + custom shaders for dread/horror (vignette, grain, pulse, corruption). Resources for SpriteFrames/TileSets/abilities.
- Testing: F5 playable. Paste Godot errors/logs/output for debug. Self + playtester feedback (movement feel, choice impact, dread landing, companion emotional weight).
- AI Leverage: Reference full bible + this file + GROK.md in prompts. Grok (me) for vision/architecture/prompts/story consistency/high-level design. Cursor/Continue.dev/Ziva for multi-file edits, Godot terminal runs, log reading, iteration. Always @workspace or full project context.

**Vertical Slice Definition (Phase 0/1 exit criteria — build this first)**:
- Playable child Rowan (age visuals stub) + Briar (follow + one contextual assist: e.g. dig or bark).
- One small semi-open zone (playground at dusk → fringes; tilemap with collision, some decor from revised ritual).
- Real-time movement + basic attack (facing, anim lock).
- One simple environmental puzzle using companion (or morality choice).
- One Dialogue Manager scene (revised escape ritual context + first bond/morality choice with Briar; state read/written on PlayerData directly).
- Simple horror/dread moment (fog, wrong toy sounds, first "monster" glimpse or dread meter rise; companion fear behavior).
- Save stub, basic UI (interact prompt), touch parity.
- Ends with age-up teaser or first revelation hint. F5 in <10s on web export. Self-playtest: "Did the choice matter? Did dread land? Companion bond felt real?"

**Modular Architecture (reference in all code prompts)**:
```
test/
├── project.godot (name="Cycle of Innocence", autoloads as above, input for attack/interact/companion_call, layers for world/player/enemy)
├── scenes/
│   ├── player/player.tscn + AnimatedSprite2D + Collision + Camera
│   ├── companions/briar.tscn (etc.)
│   ├── zones/playground_fringes.tscn (or equivalent small zone)
│   └── ui/ (minimal HUD, transition_fader, dialogue balloon from Dialogue Manager)
├── scripts/
│   ├── autoload/ (GameEvents.gd with signals for age/morality/bond/revelation/dread/horror_stinger; PlayerData.gd; etc.)
│   ├── player/player_controller.gd (extend existing: age_stage enum, apply_age_visuals(), morality, real-time attack, companion calls, state machine)
│   ├── companions/ (base_companion.gd + briar.gd: follow AI, bond/corruption state, assist methods, visual updates)
│   ├── progression/ (age_morph.gd, morality_system.gd — branch abilities)
│   ├── horror/ (dread_manager.gd, atmosphere.gd — shaders/lights/audio)
│   ├── dialogue/ (.dialogue mutations call PlayerData directly: do PlayerData.change_morality(-5), do PlayerData.set_companion_bond("briar", 30.0))
│   └── utils/ (save_manager.gd, input_manager.gd)
├── resources/ (player_sprite_frames.tres per age/morality, companion frames, dialogue/*.dialogue)
├── assets/ (sprites/{player/age_*, companions/briar_* with growth/corruption}, shaders/horror_*.gdshader, audio/)
├── tools/ (sync-to-rpg-adventure.sh, publish-standalone.sh, import_imagine_assets.py extended for age/variants)
├── docs/ (local vault — always reference story/bible.md + this file + GROK.md)
└── AGENT_RULES.md + GROK.md (reference in every prompt)
```
- Reuse/adapt from siblings: player_controller.gd (8-dir, facing, anim lock, action_and_wait), autoloads (GameEvents/PlayerData), godot/ touch/resolution/pixel pipeline, rpg-adventure/ tools/Imagine workflow, room/zone manager patterns.
- No monolithic scripts. Clear signals. CompanionManager handles AI/assists/care.

**Prompt-Driven Iteration (how we work)**:
- You (user) or I (Grok) give specific task: "Implement age progression visuals for Rowan + Briar in playground zone per revised story bible (lottery, clowns/toys, no villager alarm yet)."
- I (or Cursor/Continue) output:
  - Complete GDScript (or .tscn structure).
  - Exact integration steps (e.g., "Add to PlayerData, connect signals in autoload, update sprite_frames in resources/, test in playground_fringes.tscn").
  - Test plan (F5, specific playthrough: "Child Rowan flees playground with Briar; first dread rise on toy sounds; bond choice over food; companion assist on simple dig puzzle").
- After test: Paste Godot output/errors/logs/screenshots (describe if needed). We debug/iterate.
- For assets: I output batches of Grok Imagine prompts (updated for story revs: playground ritual with clowns/stuffed toys, villager "success" belief). You generate → Aseprite (grid 32x32, palette ≤32 colors, clean) → Godot import (nearest).
- Always: Reference AGENT_RULES.md + story/bible.md + GROK.md + relevant mechanics/ (e.g. progression.md, companions.md, horror-and-dread.md) in prompts. "Use vertical slice first — keep to child Rowan + Briar in one zone."

**Asset Pipeline (Grok Imagine + Aseprite + Godot)**:
- Bibles first (character + companions with age/growth/corruption variants, palette swatches).
- Prompts: Locked style + story specifics (e.g. "playground ritual with creepy clowns/stuffed animals, villager unawareness, lottery context").
- Post-process: Aseprite (snap to 32x32 grid, reduce colors, animate walk/attack with age weight shift + companion personality/fear/corruption).
- Godot: SpriteFrames resources (logic selects by age_stage + morality + bond/corruption), modulate/shaders for final horror (dread pulse, corruption veins).
- Update docs/art/imagine-prompts.md + reference files in assets/reference/.

**Story & Systems Consistency**:
- Living docs: story/bible.md (acts, twists, Rowan background with revised ritual, companion arcs with bond/corruption), characters/companions.md, story/choice-matrix.md + endings.md, design/game-features.md, mechanics/*.md.
- Morality effects: Appearance (scars/glow/posture), companion states, dialogue (Dialogue Manager conditions on PlayerData), world (NPC fear/revere, areas accessible only with high bond), abilities (empath calming vs ruthless power), endings (4 paths with companion fates).
- Twists: Monsters = previous sacrifices; elders = prior "successes"; Rowan = perfect vessel from bloodline; animals carry echoes (can be vessels or keys to break/transform cycle).
- Always reference in prompts: "Per revised story bible (playground ritual, clowns/toys, villagers think successful, escalation creates more monsters) and companions.md (Briar as emotional heart)."

**Review & Fix Loops + Testing**:
- After any output: You test in Godot (F5). Paste errors, logs, screenshots (describe), playtest notes ("choice didn't feel impactful", "dread landed but companion fear was too frustrating").
- Iterate: "Fix X; keep vertical slice scope."
- Playtest rigor: Self-record clips; recruit 2-3 testers for vertical slice (movement feel, choice matter, dread, companion bond emotional weight). Metrics: 4+/5 fun, choice impact, non-frustrating touch/combat, <10s web load.
- Accessibility: Horror intensity slider (reduces effects, keeps story/mechanics); color-blind; subtitles; control remap.

**Tooling & AI Workflow (hybrid as you described)**:
- **Grok (me)**: High-level planning, architecture, story consistency, Grok Imagine prompt batches, GDScript skeletons + integration steps, review of agent output.
- **Cursor (Claude 4/Sonnet) or Continue.dev (free, model-flexible — Claude/Grok/Ollama)**: Primary implementation agent. Use @workspace or full project context. Highlight files or describe task → multi-file edits, Godot terminal runs (godot --headless for exports/tests), read logs, iterate. Excellent for .gd/.tscn.
- **Godot in-editor (Ziva or AI plugins)**: If available, for scene tree manipulation, in-editor code gen, quick tests.
- **Local/Privacy**: Ollama + Continue.dev for sensitive story/plot work.
- Daily: Start with me (Grok) for "Design X per bible + features doc". Hand off to Cursor/Continue for execution. Test in Godot (keep open alongside IDE). Paste back for fixes. For sprites: Ask me for prompts → generate → Aseprite → import.
- Pro tips: Commit frequently (agents can draft messages). Reference full bible in every agent prompt. Use Godot's built-in debugger + export HTML5 for quick web tests. For horror: Agents prototype shaders/lights/dread effects. Sync/publish after chunks.

**Scope & Risk Mitigation (from plan)**:
- Vertical slice gate after small playable core. If movement/dread/choice doesn't land, re-scope (e.g. 1 companion, simplify horror).
- No scope creep: Every addition must answer "Does this serve story (Rowan escape + twists), a companion arc, a horror beat, or replay (morality/choices/endings)?"
- Performance: Target 60 FPS desktop, 30+ Android, <15s web load. Use resolution/pixel pipeline early. Profile with Godot tools.
- Indie solo: Self-funded; itch.io first (name-your-price or low premium). No ads/F2P.

**Commands**:
```bash
# From test/ or game/ root
bash tools/sync-to-rpg-adventure.sh   # Overwrite rpg-adventure/ with current (docs/code/assets)
cd rpg-adventure && ./tools/publish-standalone.sh   # Force to GitHub
python3 ../scripts/obsidian/status.py   # Dashboard (triage REDs)
bash ~/.claude/hooks/update-memory-and-rpg-sync.sh   # Hook for reminders
# Godot: godot (editor), godot --headless for exports/tests
```

**Next Immediate Steps (this session, post-start)**:
1. Asset bibles: Generate more via prompts (update for full companions + adult variants + corruption; playground as recurring corrupted location).
2. Dialogue: First .dialogue titles for revised escape (playground ritual context, villager "success" belief, first bond/morality choice with Briar over food).
3. Prototype: Extend PlayerData (age/morality/companion states per features doc), basic real-time combat + 1 assist in small zone, simple dread rise.
4. Test + iterate with agents/me.
5. Sync/publish + journal update + status at end.

Reference this file + story/bible.md + GROK.md + mechanics/companion + progression + horror docs in ALL prompts. Let's build the vertical slice. What's the first specific task? (E.g. "Implement PlayerData age/morality/companion states" or "Generate 3 new image prompts for Echo/Storm + corrupted Briar".)

This setup + your hybrid agent approach is excellent for solo ambitious scope in 2026. Let's execute.