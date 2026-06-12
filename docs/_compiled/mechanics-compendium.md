# Mechanics & Design — all mechanics specs and design docs (frontmatter `status:` = implementation state)
> GENERATED 2026-06-12 by tools/compile_snapshots.py — do NOT edit (not here, not in claude.ai). Source of truth is the Obsidian vault in the game repo; this file is replaced wholesale at milestones.
> Sources: docs/mechanics/adaptive-audio.md, docs/mechanics/combat.md, docs/mechanics/companion-quirks.md, docs/mechanics/day-night-hideout.md, docs/mechanics/encounters-mercy.md, docs/mechanics/hollowing-clock.md, docs/mechanics/horror-and-dread.md, docs/mechanics/interface-horror.md, docs/mechanics/inventory.md, docs/mechanics/progression.md, docs/mechanics/village-life.md, docs/mechanics/vision-and-darkness.md, docs/mechanics/zone-recontextualization.md, docs/design/ai-production-setup.md, docs/design/customization.md, docs/design/feature-candidates-2026-06.md, docs/design/game-features.md, docs/design/market-positioning.md, docs/art/prop-coherence.md


======================================================================
SOURCE: docs/mechanics/adaptive-audio.md
======================================================================

---
name: Adaptive Audio (Stem Layers)
date: 2026-06-10
tags: [feature, mechanics, audio, horror]
status: implemented (v2 crossfade 2026-06-10, AdaptiveAudio autoload)
related_decisions: "[[decisions/2026-06-10-recent-games-research-greenlight]]"
---

# Adaptive Audio — Three Stems and a Heartbeat

## What it does
Music and ambience are authored as **stacked stems** (ambient / tense / danger + a companion vocal layer) whose volumes crossfade continuously from game state — dread level, time of day, hollowing stage, companion fear. The score *is* the dread meter the player actually perceives.

## Why it fits (prior art check, R3b)
- [[design/game-features]] §12 already promises "adaptive layers… dynamic mixing based on dread" — this is the concrete design + implementation path.
- Slots into the FOSS pipeline: stems generated with ACE-Step ([[design/ai-production-setup]]), mixed in Audacity, played via Godot AudioBus.

## v2 implementation note (2026-06-10, slice-gate fix)
Layered playback clashed in the gate playtest — the ACE-Step tracks are independent compositions, not aligned stems. **v2 crossfades exclusively**: one intensity track audible at a time (ambient ↔ tense ↔ danger), equal-power 2.5s handovers, hysteresis + 4s dwell against threshold flapping, and ducking under stingers and the soothe lullaby. The layered ideal returns if/when true aligned stems are produced (one composition, stripped mixes).

## Stem stack (per zone theme)
| Stem | Driven by | Example |
|---|---|---|
| **Ambient** | always on; time-of-day variant ([[mechanics/day-night-hideout]]) | wind, distant village, music box far away |
| **Tense** | dread 30–70, monster proximity | low strings, wrong-pitched lullaby fragments |
| **Danger** | dread > 70, combat, hollowing stage ≥ 2 ([[mechanics/hollowing-clock]]) | percussion, the Hunger's sub-bass |
| **Companion vocal** | fear/corruption of nearby companions ([[mechanics/companion-quirks]]) | whimpers, wrong-sounding purrs/growls |

Rules: crossfade by lerp through intermediate states (no hard cuts — escalation must feel *earned*); hideout scenes duck everything but ambient + a warm campfire layer (the safety contrast that makes dread legible); stingers stay separate one-shots (existing `GameEvents.horror_stinger`).

## Implementation
- ~~**Option 1 (preferred)**: AdaptiSound addon~~ — **REJECTED 2026-06-12**: README states v1.0 has no web export support (breaks the hard Web constraint); addon targets Godot 4.3. [[decisions/2026-06-12-adaptisound-rejected]]
- **Option 2 (canonical, shipped)**: hand-rolled `AdaptiveAudio` autoload: one `AudioStreamPlayer` per stem on its own bus, `_process` lerps `volume_db` toward targets computed from `DreadManager` + `WorldState`.
- Stems must share BPM/key per zone theme; loop-cut in Audacity; OGG export.
- Mobile: 4 simultaneous OGG streams is cheap; keep stems mono except ambient.

## Accessibility
Horror-intensity slider scales tense/danger/vocal target volumes (never ambient — the world stays alive); "reduced dread" mode caps the danger stem.

## Asset plan (v1)
2 zone themes (playground/fringes, village edge) × 3 stems + 1 shared companion-vocal set + hideout warm layer = **8-10 short loops**. ACE-Step generation prompts go in [[art/imagine-prompts]]-style provenance notes (new `docs/art/audio-prompts.md` when work starts).

## Related
[[mechanics/horror-and-dread]] · [[mechanics/hollowing-clock]] · [[mechanics/day-night-hideout]] · [[design/ai-production-setup]] · [[design/feature-candidates-2026-06]]


======================================================================
SOURCE: docs/mechanics/combat.md
======================================================================

---
name: Combat System (Real-Time Action + Horror)
tags: [mechanics, combat, design]
status: draft
related:
  - "[[design/game-features]]"
  - "[[mechanics/progression]]"
  - "[[mechanics/horror-and-dread]]"
  - "[[story/bible]]"
---

# Combat System

## Core Philosophy
Real-time action combat (inspired by classic Zelda and Secret of Mana) with a heavy horror twist. Combat should feel fluid and empowering when you're doing well, but increasingly tense, frightening, and costly as dread rises or corruption spreads.

The goal is not "git gud" power fantasy — it's "this is what survival looks like when the world is trying to eat children."

**Locked Design** (from approved plan):
- Real-time (no pause-and-command menu combat like the old prototype).
- Player has direct control.
- Light companion assists (contextual or quick commands) rather than full party control.
- Horror elements (dread, body horror, psychological threats) are core to the combat feel.

## Basic Combat Loop

**Movement**: 8-direction CharacterBody2D (existing controller base). Snappy but with weight that changes slightly with age (child is lighter and more vulnerable; adult feels more grounded).

**Primary Attack**:
- Melee swipe or simple forward thrust (directional).
- Animation lock + recovery that feels fair but punishable.
- Can be chained into short combos as player gains age/experience.

**Dodge / Defense**:
- Roll or quick backstep with i-frames.
- Limited uses or stamina cost (or just strict timing) to keep tension high.
- Companions can sometimes "cover" you (Briar barks and draws aggro, etc.).

**Companion Assists**:
- Contextual: Stand near a dig spot with Briar → prompt to "Briar, dig!"
- Quick command: Dedicated button or radial for "Assist" that uses the currently bonded companion's signature move.
- Risk/reward: Using assists too aggressively can raise companion corruption or cause them to get hurt.

**Special / Ultimate Moves**:
- Gated behind age, morality branch, or high companion bond.
- Some are "corruption moves" — very strong but visibly damage the companion or Rowan.

## Enemy Design (Story-Tied)

1. **Corrupted Previous Offerings** (body horror core)
   - Shambling, tragic figures wearing scraps of white ritual clothes.
   - Patterns that feel wrong or familiar (a lunge that looks like a child's game).
   - Some can be calmed or "put to rest" with high empathy / specific revelations instead of killed.

2. **Village Wardens / Hunters**
   - Human, more tactical.
   - Can recognize Rowan by age/morality rumors.
   - Some have dialogue before or after fights ("You should have stayed dead, vessel.").

3. **Hunger Manifestations**
   - Abstract, nightmarish, change appearance based on current dread/corruption.
   - Less "fair" — they cheat, appear from walls, mess with controls or vision at high dread.

4. **Corrupted Companions** (worst case)
   - If you push a companion too far into corruption, they can become temporary or permanent enemies.
   - Fighting a twisted version of Briar should feel awful.

## Horror Integration in Combat

- **Dread Meter**: Rises during fights in certain areas or against certain enemies. High dread adds:
  - Screen distortion / vignette.
  - Slower recovery.
  - Companion fear behaviors (they hesitate or cower).
  - Occasional "false" enemy signals or audio hallucinations.
- **Body Horror Feedback**:
  - On high personal corruption: Your attacks may cause self-damage or have grotesque secondary effects.
  - On high companion corruption: Their assist moves become stronger but may hurt them or turn on you mid-animation.
- **Psychological Threats**: Some "enemies" are guilt or memory manifestations. They can't be damaged normally until you have the right revelation or emotional state.

## Death & Consequences

Not a hard fail state. Options:
- "You black out and wake at the edge of the woods" (with a companion if bond is high enough).
- A companion sacrifices themselves to save you (huge story moment).
- Time advances slightly (narrative consequence — the next ritual gets closer).

Death should always feel like a meaningful setback that reinforces the horror and the value of your bonds.

## Balance & Feel Goals

- Child sections: Combat should feel scary and desperate. You rely heavily on Briar and running/hiding.
- Adult sections: More powerful, but the stakes and horror are much higher (you have more to lose).
- Ruthless playthroughs: Combat is flashier and more brutal, but you risk losing the very things (companions) that make survival meaningful.
- Kind playthroughs: Combat is more about protection, timing, and using the environment + companions cleverly.

**No traditional difficulty settings** in v1 (except the horror intensity accessibility slider, which can also tone down some combat gore/psychological effects while keeping mechanical challenge).

## Technical Notes (Godot)

- Extend the existing player_controller.gd state machine (EXPLORING, ATTACKING, HURT, etc.).
- Use Area2D for hitboxes, with layers for player/enemy/interactable.
- Companion assists as separate nodes that can be "called" and have their own cooldowns/states.
- Global DreadManager singleton that multiple systems subscribe to.
- Juice: screenshake, hitstop, impact particles, sound design (flesh vs metal vs "wrong" sounds).
- Enemy AI: simple state machines (patrol, chase, attack, horror phase). Use NavigationAgent2D for basic pathing in larger zones.

## Scope for v1

- 5-7 enemy types max, heavily iterated.
- 2-3 companion assist moves per companion (unlocked over time).
- Focus on 2-3 distinct combat "feels" (child desperate, teen growing, adult powerful-but-damned).
- Polish the horror feedback (dread effects, corruption visuals) over adding dozens of moves.

See [[design/game-features]] for the high-level vision and [[mechanics/horror-and-dread]] for how dread specifically interacts with combat. This system must feel personal — every fight should remind the player why they're fighting and what they stand to lose.


======================================================================
SOURCE: docs/mechanics/companion-quirks.md
======================================================================

---
name: Companion Quirks (Diagnosable Behaviors)
date: 2026-06-10
tags: [feature, mechanics, companions, horror]
status: implemented
related_decisions: "[[decisions/2026-06-10-recent-games-research-greenlight]]"
---

# Companion Quirks — Corruption You Can Diagnose

## What it does
Bond and corruption stop being invisible numbers: they manifest as **specific, persistent, diagnosable behaviors** (Pacific Drive's quirk system, applied to living family). The player learns to *read* their companions — and high corruption makes that reading unreliable, which is the horror.

## Why it fits (prior art check, R3b)
- [[characters/companions]] already specifies "visual & behavioral feedback" and refusal risk; quirks give that a concrete data model and gameplay loop instead of ambient flavor.
- ideas.md inbox had "companion refusal extension" (The Last Guardian) — quirks absorb and supersede it.
- Builds directly on `PlayerData.companions` (bond/corruption per id) and existing `bond_changed`/`corruption_changed` signals; LimboAI behavior trees consume quirk state as blackboard variables.

## Quirk model
Each quirk: `{id, companion, trigger, behavior, tell, truth_chance}` — acquired at bond/corruption thresholds, persisted per save.

Examples (v1 pool: ~4 per companion):
- **Briar / bond ≥ 60**: growls at "empty" corners that hide buried things — a TRUE ping ([[mechanics/vision-and-darkness]] scent system) the player must learn to trust.
- **Briar / corruption ≥ 40**: stares at Rowan a beat too long when given orders; at ≥ 70, occasionally "guards" things that aren't there.
- **Echo / corruption ≥ 50**: scout reports gain `truth_chance < 1.0` — occasional FALSE pings (an ambush that isn't there… or is the real one the lie?).
- **Echo / bond ≥ 70**: lands on Rowan's shoulder before dread spikes — early-warning tell.
- **Storm / bond < 30**: refuses narrow-path route types entirely (forces detours); whinnies at specific villagers (suspicion hint, feeds [[mechanics/village-life]]).

## Diagnosis & care loop
- Quirks are *not* announced. The player notices patterns; the journal lets them pin observed behaviors per companion (lightweight: 1 line per discovered quirk).
- Hideout care ([[mechanics/day-night-hideout]]) can soften corruption quirks (lower trigger frequency) but never silently removes them — earned trust changes behavior visibly, e.g. the too-long stare becomes a head-bump.
- Empath-path insight: high-bond + Innocent tier shows a subtle tell animation distinguishing true pings from corrupted ones; Vessel tier sees nothing wrong at all (the Hunger hides its work).

## Data model / tech
- `companions[id].quirks: Array[StringName]` + quirk resource defs (trigger conditions, behavior anim, truth_chance).
- LimboAI: quirk flags on the blackboard; behavior-tree branches per quirk (low effort — conditions on existing follow/assist trees).
- GameEvents: `quirk_acquired(companion_id, quirk_id)`, `quirk_expressed(companion_id, quirk_id)`.

## Edge cases
- Never let a false ping cause unavoidable death — false information costs resources/dread, not runs.
- Horror-intensity slider: quirk *behaviors* always play (mechanical), but the most disturbing expressions (corrupted staring, wrong-jointed movement) soften visually.
- Quirks freeze during cutscenes/dialogue.

## Design-language note (patent posture)
Quirks are **authored, designer-scripted progressions** on three fixed characters — acquisition thresholds and behaviors are hand-defined data, never procedurally generated NPC evolution, hierarchies, or ranks. Keep that framing in code, docs, and marketing. See [[decisions/2026-06-10-patent-risk-review]].

## Implementation notes (2026-06-11, branch feature/companion-quirks)
- `CompanionQuirkDefs` (authored catalogue, patent-posture comment inline) + acquisition in `PlayerData.set_companion_bond/corruption` — earned at thresholds, persisted in the companion dict, never removed.
- Briar v1 pool live: **scent growl** (bond ≥ 60, TRUE ping at unrevealed diggables ≤ 90px), **long stare** (corr ≥ 40, 0.9s delay before obeying dig — softens to a head-bump at bond ≥ 60), **phantom guard** (corr ≥ 70, the same growl at nothing every 15–30s), **dusk press** (bond ≥ 75, −5 dread as dusk/night falls).
- Empath insight rule (`CompanionBase.insight_tell_visible`, pure/unit-tested): "!" tell only on TRUE pings, only for Innocent tier with bond ≥ 60; Vessel sees nothing wrong.
- Quirks freeze during dialogue (`exploration_paused`). New `growl` SFX. GameEvents: `quirk_acquired` / `quirk_expressed`. Journal-pinning UI deferred to interface-horror/UI pass (ideas inbox).

## Related
[[characters/companions]] · [[mechanics/vision-and-darkness]] · [[mechanics/day-night-hideout]] · [[mechanics/interface-horror]] · [[design/feature-candidates-2026-06]]


======================================================================
SOURCE: docs/mechanics/day-night-hideout.md
======================================================================

---
name: Day-Night Loop & Hideout
date: 2026-06-10
tags: [feature, mechanics, companions, horror, save-system]
status: planned
related_decisions: "[[decisions/2026-06-10-new-features-and-ai-setup]]"
---

# Day-Night Loop & Hideout (Safe-Camp)

## What it does
Splits play into a two-mode rhythm (Darkwood/Moonlighter): **day** = exploration, puzzles, scavenging, village reconnaissance in relative safety; **night** = dread spikes, corruption manifests visibly, certain monsters and ritual activity only at night. Between them sits the **hideout** — a safe-camp where Rowan tends companions, saves, and breathes. The hideout is also the game's emotional anchor: the found-family scenes happen at the campfire.

## Why it fits (prior art check, R3b)
- [[mechanics/horror-and-dread]] needs contrast to work — dread without safety flattens into noise. Mad Father/Ib safe-room contrast applied.
- [[characters/companions]] care actions (feed, soothe, play) currently have no *place*; the hideout gives them a diegetic home and a natural UI-free interaction space.
- ideas.md already captured "care mechanics with visible loyalty shifts" — this hosts them.
- Mobile-first: night→hideout→save is a natural session boundary ([[design/game-features]] §10 saves on "major story beats" — hideout rest becomes the canonical manual save).

## Flow
1. Time advances by **player action**, not real-time: each zone transition / major action ticks the day forward (dawn → day → dusk → night). A subtle palette shift (CanvasModulate) telegraphs it; no clock UI.
2. **Day**: standard exploration. Villagers/Wardens visible and avoidable. Most puzzles solvable.
3. **Dusk**: companions get restless (Briar whines toward camp — the game's "go home" cue, delivered by family instead of UI).
4. **Night**: dread floor rises (+20 baseline), vision radius shrinks ([[mechanics/vision-and-darkness]]), night-only monsters and ritual processions spawn (scaled by [[mechanics/hollowing-clock]] stage). High-corruption companions act *wrong* at night — the first place corruption shows.
5. **Hideout**: campfire scene. Available actions: feed/soothe/play (bond +, corruption −), inspect companions (their sprite state is the health UI), journal/memory review, **save**, sleep to dawn.
6. Choosing to push through the night instead of resting is always allowed — risk/reward, and some content is night-only (overhearing rituals, certain Stilled monsters wandering).

## Hideout progression
- Starts as a cold hollow under roots; small upgrades found (not crafted): a blanket, a firepit stone, Echo's perch, Storm's lean-to. Each upgrade is a story beat and slightly improves rest effects.
- Hideout can be **discovered** at Hollowing stage 3+ (Frenzy): forced relocation scene — even safety is provisional. One relocation max in v1.

## Data model
- `WorldState.time_of_day: enum {DAWN, DAY, DUSK, NIGHT}`, signal `time_advanced`.
- Hideout scene with care-interaction nodes driving existing `PlayerData.set_companion_bond/corruption`.
- Save anchored to hideout rest (plus existing auto-save on transitions).

## Edge cases
- Story sequences can pin time (no advancing mid-quest-chain).
- If all companions are dead/corrupted, the hideout scenes change to silence — the mechanic itself mourns ([[story/endings]] Failure path foreshadowing).
- Accessibility: "longer days" option for players who find night pressure stressful; horror-intensity slider dampens night audio/visuals, never the spawn rules.

## Mobile note
Palette-shift day cycle is shader-cheap; no real-time clock means no battery drain or interrupted-session unfairness.

## Related
- [[mechanics/horror-and-dread]] · [[mechanics/vision-and-darkness]] · [[mechanics/hollowing-clock]] · [[characters/companions]] · [[mechanics/inventory]]


======================================================================
SOURCE: docs/mechanics/encounters-mercy.md
======================================================================

---
name: Mercy & Calm Encounter Resolution
date: 2026-06-10
tags: [feature, mechanics, combat, morality, horror]
status: implemented
related_decisions: "[[decisions/2026-06-10-new-features-and-ai-setup]]"
---

# Mercy & Calm Encounter Resolution

## What it does
Most monsters are former sacrificed children ([[story/bible]] twist #1). Encounters can therefore be resolved three ways: **fight**, **flee/avoid**, or **soothe/spare**. Soothing is the Empath-path counterpart to combat — Rowan (and companions) calm a monster enough that it stops attacking, with lasting consequences in the choice matrix and endings. Inspired by Undertale's spare system, reframed through the game's own lore: you are not negotiating with a stranger, you are recognizing a child the village fed to the Hunger.

## Why it fits (prior art check, R3b)
- [[mechanics/combat]] already lists "calmed threats" as an experience source and the Empath ability branch in [[mechanics/progression]] includes "calming abilities, non-lethal options" — this doc mechanizes those stubs.
- [[story/endings]]: The Transformation ending requires understanding that monsters/animals are marked children — sparing is the gameplay verb that *teaches* this.
- New compared to existing docs: a concrete per-encounter resolution loop, spare-state persistence, and corruption cost for killing spareable monsters.

## Flow
1. Spareable monsters carry a hidden **Recognition** state (0–100). Most combat-capable monsters are spareable; Hunger manifestations and Wardens are not.
2. Player actions raise Recognition in real time (no menu pause — keeps Zelda/Mana feel):
   - **Hold-to-soothe**: stand ground, hold the soothe button (child Rowan hums the ritual lullaby — body horror inversion: the song that killed them is the only language they remember). Leaves Rowan defenseless (i-frames off, dread rising).
   - **Companion assist**: Briar at high bond lies down non-threateningly (+Recognition aura); Echo mirrors the monster's old name-call; Storm's calm presence slows monster aggression.
   - **Tokens**: offering a Memory/Lore item tied to that monster's past (links [[mechanics/inventory]] Memory items to gameplay) gives a large boost.
3. At Recognition ≥ threshold the monster becomes **Stilled**: stops attacking, follows light, may lead Rowan to a secret (its old home, a buried toy → lore fragment).
4. Stilled monsters persist per save. They re-aggro only if attacked or if the [[mechanics/hollowing-clock]] advances a stage (the Hunger reasserts its grip — escalation undoes mercy, which is the horror).

## Morality & corruption hooks
- Sparing: morality toward Innocent/Empath, small dread reduction, sets `spared_<id>` flags consumed by [[story/choice-matrix]].
- Killing a monster *after* it was Stilled: heavy morality push toward Vessel, +companion corruption if they witnessed it (Briar learns from you — Black & White-style behavioral mirroring), unique horrified companion reactions.
- Ruthless path inversion: a Vessel-tier Rowan can **Dominate** instead of soothe — same mechanic, opposite flavor: the monster obeys out of fear, fights for you once, then dies. Power now, ending flags later.

## Data model
- `Monster.recognition: float`, `Monster.spareable: bool`, `Monster.stilled: bool` (persisted).
- PlayerData: `spared_count`, `dominated_count`, per-monster flags into the existing revelation/choice flag system.
- GameEvents: `monster_stilled(id)`, `stilled_monster_killed(id)` signals.

## Edge cases
- Soothing in a group fight: only one target gains Recognition at a time; others keep attacking (risk/reward).
- High dread distorts the soothe: at dread > 80 the lullaby audio warps and Recognition gains halve — mercy is hardest when you're terrified, which is the point.
- Accessibility: horror-intensity slider does not change Recognition mechanics, only presentation.

## Mobile note
Hold-to-soothe maps cleanly to a touch hold; no extra buttons beyond existing interact.

## Research notes (2026-06, round 2)
- **Unique soothe per monster** (Undertale Yellow): each spareable monster has one *specific* interaction that moves Recognition fastest (show the buried toy, hum THEIR verse, let Briar approach first); repeating the generic soothe plateaus. Discovering the specific one = environmental storytelling payoff. See [[design/feature-candidates-2026-06]].

## Implementation notes (2026-06-10, branch feature/full-mercy)
- Generic soothe plateaus at Recognition 60; each monster exports `soothe_key_flag` — for the TwistedChild it is `dug_playground_buried_toy` (Briar digging up the toy IS the discovery payoff). With the key: rate ×1.6 and the plateau lifts.
- Briar calm aura: bond ≥ 25, not afraid, within 90px of the target → rate ×1.5 (stacks with the key). Dread > 80 halves everything. Pure rule: `PlayerController.soothe_rate()`.
- Stilled children lead: stay within 90px and the child walks to its `secret_spot_path` (keepsake diggable east of the swings) — once, flagged `led_<id>`. It stops *beside* the spot and waits; the reveal stays Briar's dig (assist + bond reward), never the monster's (playtest fix 2026-06-11).
- Domination: at Vessel tier the same hold becomes `add_domination` — ×1.4 rate, ignores dread and needs no key (fear is the easy road). The thrall heels, fights other monsters once, then crumbles; `dominated_<id>` keeps it dead forever. Morality +8, Briar corruption +5.
- Bookkeeping: `PlayerData.spared_count` / `dominated_count` + permanent `spared_`/`dominated_` flags (betrayal clears `stilled_`, never the history). All persisted.

## Related
- [[mechanics/combat]] · [[mechanics/horror-and-dread]] · [[mechanics/hollowing-clock]] · [[story/choice-matrix]] · [[characters/companions]]


======================================================================
SOURCE: docs/mechanics/hollowing-clock.md
======================================================================

---
name: The Hollowing Clock (Doom Escalation)
date: 2026-06-10
tags: [feature, mechanics, narrative, horror, world-state]
status: implemented
related_decisions: "[[decisions/2026-06-10-new-features-and-ai-setup]]"
---

# The Hollowing Clock — Doom Escalation System

## What it does
Mechanizes the story bible's "delayed alarm" beat: the village does not yet know the ritual failed. A hidden **Hollowing meter** advances in discrete stages as the Hunger and then the village realize the offering escaped. Each stage permanently worsens the world: emergency rituals, more monsters, corrupted zones, changed NPC behavior. Inspired by World of Horror's doom clock, but **event-driven, not real-time** — stages advance on story beats and player actions, never on a wall-clock timer (mobile-friendly, no anxiety treadmill).

## Why it fits (prior art check, R3b)
- [[story/bible]] explicitly describes the escalation ("villagers grow panicked and begin sacrificing more children in additional emergency rituals") but no doc mechanized it.
- [[design/game-features]] §7 says "time pressure is narrative (the next Hollowing approaches) rather than strict timer" — this doc is that system, made concrete.
- Interacts with [[mechanics/encounters-mercy]] (escalation can undo Stilled states) and [[mechanics/day-night-hideout]] (night danger scales with stage).

## Stages (v1: five)
| Stage | Name | World state |
|---|---|---|
| 0 | The Quiet | Post-escape. Village believes ritual succeeded. Safest the game will ever be. |
| 1 | The Doubt | Hunger stirs; crops twist wrong. Searchers on roads at night. First whispers. |
| 2 | The Alarm | Village knows. Wardens hunt Rowan. First emergency ritual → a new monster appears *that the player could not save*. |
| 3 | The Frenzy | Multiple emergency rituals. New corrupted zones; some NPCs vanish (their children taken). Stilled monsters can re-aggro. |
| 4 | The Hollowing | Endgame state. The next great ritual is imminent; ending branches lock in. |

## Advancement rules
- Primary: **story milestones** (revelations, zone firsts, age-ups).
- Secondary: **player noise** — being seen by villagers/Wardens, loud kills near the village, using high-corruption powers add hidden Alarm points; enough points pulls the next stage early.
- Mercy/stealth playstyles delay stages; ruthless/loud playstyles accelerate them. The clock is the world's response to *who Rowan is becoming*.
- Never advances while idle or during care/hideout scenes. No timer UI — the player reads the world (posters, patrols, church bells, NPC dialogue), with companion behavior as the early-warning system (Echo refuses to fly toward the village a stage before the player learns why).

## Consequences per stage
- Spawn tables and patrol routes per zone keyed to stage.
- Dialogue: `hollowing_stage` variable gates dialogue everywhere.
- Each stage adds one **irreversible loss** (an NPC, a safe path, a child) — the cost of delay is shown, not told.
- Endings read peak-stage and stage-at-finale flags ([[story/endings]]: Frenzy reached + low bonds feeds The Failure).

## Data model
- `HollowingClock` autoload (or merged into a WorldState autoload): `stage: int`, `alarm_points: int`, signals `stage_advanced(stage)`.
- GameEvents already has `horror_stinger` / zone signals to react to.
- Save: stage + points + per-stage loss flags.

## Edge cases
- NG+ starts at stage 0 but with `$knew_it_was_coming` echoes (NPCs uneasy around Rowan).
- Stage must never advance mid-dialogue or mid-hideout; queue and fire on zone transition.
- Anti-frustration: stage 2+ always leaves at least one safe route to the current objective.

## Implementation notes (2026-06-11, branch feature/hollowing-clock)
- `HollowingClock` autoload: `stage` (QUIET→HOLLOWING), milestones (revelations, age-ups — once per id) + Alarm points (kill +25, betrayal +40, domination +35, stilling **−20**; 100 = one stage early, overflow carries).
- Queue rule enforced: never advances mid-dialogue (`exploration_paused`) or inside the hideout (`hideout_entered/exited` on GameEvents); fires on resume.
- Stage feedback: distant bell toll (`hollowing_bell.wav`), Briar whimper (early warning), +12 dread, `horror_stinger`. No UI — debug label shows stage during dev (key H = +1 stage).
- Consequences live now: **Frenzy (3) un-stills every Stilled monster** (no betrayal cost — the Hunger's doing; `spared_` history kept); **Alarm (2) spawns the emergency-ritual child** in the deep fringes (`spareable=false` — the player could not save it); night dread floor 20 + 5×stage; enemy detection radius ×(1 + 0.1×stage).
- Persisted in saves (stage, points, pending, consumed milestones). Dialogue can gate on `HollowingClock.stage` directly.

## Doom legibility roadmap (research 2026-06-12, within the no-timer-UI rule)
- **Bell pattern language**: the chapel bell rings a different pattern per stage — attentive players can literally count the doom. Layers with (doesn't duplicate) the existing advance toll; cheap (SFX variants + stage switch).
- **Stage-keyed poster swaps**: village notice-boards/posters swap content by stage, reusing the recontext-group pattern keyed to `HollowingClock.stage` instead of a revelation ([[mechanics/zone-recontextualization]]).
- **Journal of observed signs**: consultable entries in the Growth/Memory screen, gated on the player *witnessing* the world change ("Mrs. Alden's bench was empty today.") — diegetic, hidden-state-safe, doubles as memorial; NG+ pre-seeds dread-tinged lines via `$knew_it_was_coming` ([[mechanics/progression]]).
- **Anti-pattern (flagged)**: any always-on-screen indicator, however diegetic-skinned (e.g. a corner candle burning down) — still a meter, still implies continuous time, still competes with the companions' early-warning job. Fails the filter.
- Corruption-spread-across-zone-maps (parked 2026-06-10 idea) stays parked until playtests say the world reads too slowly — art-cost item; bells/posters/journal buy legibility first.

*Source: [[research/done/2026-06-12-test-answer]]* `[training knowledge — design reasoning grounded in vault snapshots, no external claims]`

## Related
- [[story/bible]] · [[story/endings]] · [[mechanics/encounters-mercy]] · [[mechanics/day-night-hideout]] · [[mechanics/horror-and-dread]]


======================================================================
SOURCE: docs/mechanics/horror-and-dread.md
======================================================================

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

## How Horror Serves the Story

Every horror element should ultimately point back to the central conspiracy:
- The cycle creates the monsters.
- The "protectors" are complicit.
- Your bonds are the only thing keeping you human — and the cycle wants to take them too.

See [[mechanics/combat]] for how dread and corruption specifically affect fighting, and [[design/game-features]] for the broader vision. Horror here is a feature of the world and the player's soul, not just set dressing.


======================================================================
SOURCE: docs/mechanics/interface-horror.md
======================================================================

---
name: Interface Horror (Dialogue Distortion + Control Degradation)
date: 2026-06-10
tags: [feature, mechanics, horror, dialogue, accessibility]
status: implemented (v1 2026-06-11, branch feature/interface-horror)
related_decisions: "[[decisions/2026-06-10-recent-games-research-greenlight]]"
---

# Interface Horror — The Game Stops Obeying You

## What it does
Corruption and dread reach through the fourth wall via the two channels the player trusts most: their words and their hands. Maximum horror per line of code (Mouthwashing's unreliable dialogue + Heartworm's possession-degraded controls).

## Why it fits (prior art check, R3b)
- The Vessel arc ([[story/bible]]: Rowan as "perfect vessel") needs a *playable* expression of being spoken through — visuals alone ([[../assets/shaders/marked_corruption.gdshader]]) show it; this makes the player feel it.
- [[mechanics/horror-and-dread]] already owns the dread→gameplay channel (stamina, companion fear); this extends it to input/dialogue with the same accessibility contract.

## A. Dialogue distortion (Vessel speaks through Rowan)
- At morality tier VESSEL (and rare scripted Hardened moments): the option the player selects renders/says something *adjacent but wrong* — colder, or with a word Rowan wouldn't use. NPCs and companions react to what was *said*, not what was chosen.
- Implementation: Dialogue Manager conditional response text on `PlayerData.get_morality_tier()` — a distorted variant line per flagged choice. Authoring cost only; near-zero code.
- Rules: never on choices that set major flags (player agency over outcomes stays intact — distortion changes *texture and reactions*, not endings); companions' horrified reactions to distorted lines are the feedback loop ("Briar's ears flatten. That wasn't your voice.").

## B. Control degradation (the body resists)
- Triggers: dread ≥ 85, or personal corruption ≥ 70 in marked zones.
- Effects (subtle, brief): 1-3 frame input latency pulses, a dropped dodge once per spike, walk animation hitching (the `age_morph.gd` animation-speed hook already exists). NEVER full inversion, never longer than ~2s per spike.
- Implementation: small input-buffer layer in `scripts/player/player_controller.gd` reading dread/corruption; effect strength = `f(dread, corruption) * horror_intensity`.

## Accessibility contract (hard rules)
- Horror-intensity slider below 40%: control degradation fully OFF; dialogue distortion marked with a visual cue (distorted text styling) so the player always knows it happened.
- Never during precision puzzles, never in menus, never stacked with touch-input latency on mobile (auto-disabled if frame time is already poor).
- Both effects are presentation + texture; all mechanical consequences (morality, flags, endings) derive from the player's actual choices.

## Data model / tech
- `DreadManager` (planned autoload) exposes `interface_pressure: float`; player controller + dialogue balloon read it.
- Dialogue: `[if PlayerData.get_morality_tier() == PlayerData.MoralityTier.VESSEL]` response variants.

## Implementation notes (2026-06-11, v1)
- `DreadManager.interface_pressure()` — pure rule `interface_pressure_rule(dread, morality, intensity)`: dread ramps over [85,100], morality (Rowan's own corruption proxy) over [70,100], max of both × intensity; hard 0 below intensity 0.4. "Marked zones" deferred until zones carry a marked flag.
- Spikes (`player_controller.gd`): scheduler rolls `pressure * delta * 0.6` per frame with a 9s cooldown; spike = 0.8–2.0s of 1–3 frame input lag (FIFO buffer), ONE eaten attack press, walk `speed_scale` ×0.8. Skipped when FPS < 45 (mobile contract). Frozen during CUTSCENE (menus/dialogue never degrade).
- Dialogue distortion: `escape_food.dialogue` Vessel variants per choice — mutations stay outside the conditional (identical flags/morality/bond), distorted lines styled `[color=#b39ddb][shake]` (the always-on cue), Briar reacts to what was *said* (whimper + reaction beat).
- Tests: `tests/test_interface_horror.gd` (pressure rule, spike behaviors, both dialogue paths).

## Related
[[mechanics/horror-and-dread]] · [[mechanics/companion-quirks]] · [[design/customization]] (accessibility) · [[design/feature-candidates-2026-06]]


======================================================================
SOURCE: docs/mechanics/inventory.md
======================================================================

---
name: Inventory & Items
tags: [mechanics, inventory, design]
status: draft
related:
  - "[[design/game-features]]"
  - "[[mechanics/progression]]"
  - "[[story/bible]]"
---

# Inventory & Items

## Design Goals
- **Light and purposeful**, in the spirit of classic Zelda and Mana games.
- Items should feel meaningful and tied to story, companions, or exploration — not busywork.
- Support the themes: care for companions, uncovering the conspiracy, surviving with limited resources.
- Keep art and UI scope manageable (small pixel icons, limited slots).

**No** heavy RPG inventory, crafting systems, or economy in v1.

## Inventory Structure

**Slot Limit**: 8–12 slots (small grid or list). Forces prioritization.

**Categories**:

1. **Key Items**
   - Story-critical objects (ritual fragments, old journals, keys to hidden areas).
   - Often unique and cannot be discarded.
   - Many trigger revelations or new dialogue when examined or shown to the right person/companion.

2. **Companion Care Items**
   - Food (foraged berries, dried meat, special treats).
   - Soothing items (herbs, tokens, a brush).
   - These are the most common "consumables" and directly feed the bond/corruption systems.
   - Some are companion-specific (a high-pitched whistle only Echo responds to well).

3. **Combat / Utility Consumables**
   - Simple healing (bandages, poultices).
   - Temporary dread reducers (a charm, a lantern oil that burns "clean").
   - Throwable distractions or weak bombs (very limited).

4. **Memory / Lore Items**
   - Collectible fragments (child drawings, broken ritual tools, letters).
   - These don't take normal inventory space — they go into the Journal.
   - Collecting them feeds the revelation system and can unlock new dialogue branches or companion conversations.

## Interaction with Other Systems

- **Companions**: Many items exist primarily to care for them. Using the right item at the right time (after a bad scare, when corruption is rising) can have big bond payoffs.
- **Morality**: Some items have different descriptions or secondary effects based on current morality tier (a "kind" herb soothes; the same plant prepared ruthlessly can be used as a toxin or power enhancer).
- **Puzzles & Exploration**: Key items and companion-specific tools gate or solve environmental challenges.
- **Narrative**: Showing certain items to NPCs or companions can dramatically change conversations (proof of the cycle, evidence of what happened to a previous offering).

## UI

- Simple, clean retro-modern grid or list.
- Icons are small pixel art.
- Hover/inspect shows name + short description (flavored by current morality and known revelations when relevant).
- Companion care items can be used directly from the inventory or via contextual prompts when near a companion.

**Journal** (separate from main inventory):
- Acts as both quest log and conspiracy bible.
- Organized by revelations, companion notes, and "things Rowan has seen."
- This is where most lore items live.

## Acquisition & Economy

- **Foraging / Exploration**: Primary source of food and simple materials. Encourages careful exploration of zones.
- **Story / Character Moments**: Many important items are given, found in specific story locations, or received as thanks from rare kind NPCs.
- **No shops** in early game. Later, very limited and morally charged (buying from someone who may be complicit in the cycle).
- No selling or complex crafting. If an item is no longer needed, it can usually be discarded or is automatically cleaned up after its story use.

## Scope & Future

**v1**:
- Small, curated list of items.
- Focus on companion care and story keys.
- UI that feels good on keyboard, gamepad, and touch.

**Potential Expansions** (post-v1 or DLC):
- Slightly deeper care system for companions (different foods have different effects).
- A few more utility items for advanced puzzles.
- Optional "memory" collectibles that are purely for completionists and deeper lore.

**Hard Cuts for v1**:
- Any form of heavy crafting or resource management.
- Weapon or armor upgrades (progression comes from age, morality, and companions instead).
- Large inventories or "bag of holding" solutions.

## Technical Notes

- Simple array or dictionary in PlayerData (or a dedicated Inventory resource).
- Items are data-driven (small resources or a JSON/table) so they can carry effects, descriptions, and dialogue mutations.
- Use signals when items are gained/used/lost so the journal, companions, and dialogue systems can react.
- Icon loading via the existing pixel art pipeline.

See [[design/game-features]] for how inventory fits into the larger feature set and [[characters/companions]] for specific care item ideas tied to each animal. The inventory should never feel like the point of the game — it should feel like a quiet tool that helps you protect the only family you have left.


======================================================================
SOURCE: docs/mechanics/progression.md
======================================================================

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

**Menu**: "Growth" or "Memory" screen showing current age, morality, companion status, and unlocked abilities. Simple and thematic. **Journal of observed signs** (research 2026-06-12): entries appear only when the player witnessed the corresponding world change — Rowan's inference, not game state ([[mechanics/hollowing-clock]] doom legibility); NG+ pre-seeds via `$knew_it_was_coming`.

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


======================================================================
SOURCE: docs/mechanics/village-life.md
======================================================================

---
name: Village Life (Schedules + Overheard Gossip)
date: 2026-06-10
tags: [feature, mechanics, npc, narrative, post-slice]
status: implemented (v1 core 2026-06-11)
related_decisions: "[[decisions/2026-06-10-recent-games-research-greenlight]]"
---

# Village Life — Routines You Watch, Lies You Overhear

> **Post-slice.** Designed now, built after the vertical slice ships.

## What it does
The village runs on **daily NPC routines** (Shadows of Doubt, scaled way down) and leaks its conspiracy through **proximity-overheard gossip** (Sorry We're Closed). Rowan — a child the village believes is dead — watches normal life continue from hiding. That's the cruelest beat in the bible, made playable.

## Why it fits (prior art check, R3b)
- [[story/bible]]: "villagers believe the ritual succeeded… the world moved on without you" and ideas.md already captured "Rowan overhears parents celebrating" — this systematizes it.
- Rides on systems already greenlit: time-of-day clock ([[mechanics/day-night-hideout]]), hollowing stages ([[mechanics/hollowing-clock]]), vision/stealth ([[mechanics/vision-and-darkness]]).

## A. Routines (≈10–15 named villagers)
- Each villager: 4 schedule slots (morning work / midday / evening social / night) → location + activity per slot. Plain data (`{npc_id: [{slot, zone, marker, activity}]}`), positions updated on time-advance — no pathfinding simulation while off-screen.
- Schedules shift by hollowing stage: stage 0 = idyllic routine; stage 2 = patrols, locked doors, parents walking children in groups; stage 3 = some schedules simply *stop* (their child was taken — an empty bench at the usual hour says it).
- Gameplay use: predict when a house is empty (exploration windows), when the chapel is full (safe passage elsewhere), which routes Wardens walk.

## B. Overheard gossip
- Eavesdrop zones (Area2D) near gathering spots; entering unseen plays ambient dialogue balloons (Dialogue Manager, no portrait/no choices).
- Content keyed to `hollowing_stage` + revelation flags: stage 0 relief ("thank the Lottery it wasn't ours"), stage 1 unease, stage 2 fear and blame, stage 3 horror. Some lines carry real intel (a name, a route, a ritual date) — gossip is a *systemic lore channel*, not flavor-only.
- Being SEEN while eavesdropping: villager reaction + suspicion (below).

## C. Suspicion (per-NPC, feeds the clock)
- `suspicion: float` per villager; raised by sightings, lowered by time. Crossing a threshold converts to hollowing **alarm points** ([[mechanics/hollowing-clock]] "player noise" rule) — the clock advances because *specific people* started talking.
- High-suspicion NPCs change their own gossip ("I saw something small moving by the fences…") — the player hears the net closing.

## Data model / tech
- `VillageState` (or part of WorldState autoload): schedules, suspicion dict, gossip pools per stage.
- NPC scene: idle/walk-to-marker only (NavigationAgent2D); LimboAI tree with 3 states (routine / notice / report).
- Save: suspicion + stopped-schedule flags.

## Scope guardrails
≤ 15 NPCs, one village zone, no economy/trading, no procedural names — every villager is authored (we need their children to have names).

## Implementation notes (2026-06-11, v1)
- `VillageState` autoload: SCHEDULES (5 authored villagers x 4 TimeOfDay slots, markers resolved per-zone via `marker_<name>` groups), STAGE2_OVERRIDES (children indoors), STAGE3_STOPPED (the empty bench), STAGE2_STARTED (Warden Oslo's playground search detail only exists once the village fears). Suspicion -> one alarm report per villager (25 pts); decays x0.7 per phase. Stage-keyed gossip pools with intel lines; caught eavesdropping multiplies notice rate x2.5 (`player_eavesdropping`).
- `Villager` NPC: walk/idle to slot markers, LOS notice + exclaim, absent when its marker isn't in the zone. Frames as @export on the instance ROOT (child overrides die in web export).
- `EavesdropZone`: floating ambient lines, no input lock. Village green zone: `scenes/zones/village_green.tscn` with real ZoneManager transitions.
- Tests: tests/test_village_state.gd + test_village_zone.gd.

## Related
[[mechanics/hollowing-clock]] · [[mechanics/day-night-hideout]] · [[mechanics/vision-and-darkness]] · [[story/bible]] · [[design/feature-candidates-2026-06]]


======================================================================
SOURCE: docs/mechanics/vision-and-darkness.md
======================================================================

---
name: Vision Cone & Darkness (Line-of-Sight Fog)
date: 2026-06-10
tags: [feature, mechanics, horror, rendering, companions]
status: planned
related_decisions: "[[decisions/2026-06-10-new-features-and-ai-setup]]"
---

# Vision Cone & Darkness — Line-of-Sight Fog

## What it does
Darkwood-style perception: the player only clearly sees what Rowan faces; everything behind walls, foliage, or outside the facing cone is darkened or hidden. Horror lives in the unseen 240°. Companions extend perception in their own modalities — the family literally helps you see.

## Why it fits (prior art check, R3b)
- [[mechanics/horror-and-dread]] plans "2D lights + CanvasModulate for pools of safety vs dread" — this upgrades that from ambiance to a *system*.
- [[design/game-features]] §13 lists 2D lights/occluders as a Godot strength to leverage.
- Companion senses give Briar/Echo mechanical identity beyond combat assists ([[characters/companions]] abilities: tracking, scouting) — same abilities, now expressed through the fog system.

## Flow / rules
1. **Facing cone** (~120°) from Rowan, implemented as a `PointLight2D` with cone texture + `LightOccluder2D` on walls/trees (TileMap occlusion layer). Outside the cone: heavily darkened, entities invisible (not rendered on the "revealed" canvas layer).
2. **Ambient radius**: small 360° glow so movement isn't blind. Shrinks with dread and at night ([[mechanics/day-night-hideout]]); grows near campfires/safe lights.
3. **Sound hints**: unseen entities emit positional audio + subtle one-frame silhouette flickers at high dread (hallucination system overlap — sometimes the flicker is *nothing*).
4. **Companion senses**:
   - **Briar — scent**: pings through walls as drifting scent-wisps toward items/buried things/monsters (bond-gated range; corrupted Briar pings *wrong* things).
   - **Echo — overwatch**: scouting briefly reveals an aerial circle on the map; refuses zones it fears (its refusal is information — ideas.md's "bird refusing to land" idea, systematized).
   - **Storm — steadiness**: mounted, the ambient radius is larger and dread-shrink is dampened ("reduces dread when near" from [[characters/companions]], expressed in light).
5. **Monsters and the cone**: most monsters move differently when unobserved (slow stalking outside the cone, freeze or feint inside it). Turning around *is* the jump scare; no canned jump scares needed.

## Morality / story hooks
- Vessel-tier Rowan sees corruption traces glow in the dark (the Hunger shares its sight) — power that makes the dark friendlier, which should disturb the player.
- Some revelations permanently change what the cone reveals (after learning monsters are children, their silhouettes render with faint child-outlines inside the cone).

## Data model / tech
- Godot 4.4: `PointLight2D` (cone + ambient), `LightOccluder2D` via TileMap occlusion, `CanvasModulate` per zone, visibility check (`Area2D` + raycast) to toggle entity visibility — no custom engine work.
- `PerceptionManager` (or part of player scene): cone angle/range params driven by dread, time-of-day, mount state.
- Performance: 2-3 lights + occluders is cheap on mobile; avoid per-frame raycasts for every entity (stagger checks).

## Edge cases
- Cutscenes/dialogue lift the fog locally (no fighting the camera during story).
- Accessibility: "expanded vision" toggle (wider cone + brighter ambient) under the horror-intensity umbrella; puzzle-critical objects must never be findable *only* by pixel-hunting the dark.
- Top-down twin-stick aiming on touch: facing follows movement by default; optional touch-and-hold to look without walking.

## Research notes (2026-06, round 2)
- **Counterfeit pings** (Dredge sanity spiral): at dread > 80, hallucinations can mimic *companion senses* — a scent-wisp or aerial reveal that no companion produced. The family's voice can be forged; cross-checking with the actual companion's position/behavior is the counterplay. Interacts with [[mechanics/companion-quirks]] (corrupted Echo's false pings vs dread's fake pings — two distinct lies).

## Related
- [[mechanics/horror-and-dread]] · [[mechanics/day-night-hideout]] · [[mechanics/encounters-mercy]] · [[characters/companions]] · [[mechanics/companion-quirks]]


======================================================================
SOURCE: docs/mechanics/zone-recontextualization.md
======================================================================

---
name: Zone Recontextualization (Knowledge-Gated World)
date: 2026-06-10
tags: [feature, mechanics, narrative, exploration, post-slice]
status: mechanism implemented (2026-06-11); authored moments ongoing
related_decisions: "[[decisions/2026-06-10-recent-games-research-greenlight]]"
---

# Zone Recontextualization — The World Changes When You Know

> **Post-slice.** Designed now, built after the vertical slice ships.

## What it does
Revelations don't just unlock dialogue — they change how **existing zones function** on revisit (Void Stranger's knowledge gates). The playground you escaped is a different place once you know what the toys are. Same scene, new truth.

## Why it fits (prior art check, R3b)
- [[mechanics/progression]] already lists "Revelation abilities" and [[design/game-features]] §7 says "some puzzles change or become solvable only after revelations" — this gives those lines a concrete mechanism and content plan.
- Round-1 note in [[mechanics/vision-and-darkness]] (child-outline silhouettes after the monsters-are-children revelation) is one instance of this system.

## Mechanism
- Zones contain **recontext nodes**: children of a `RecontextGroup` toggled by `PlayerData.is_revelation_known(id)` (visibility + collision + interactivity), checked on zone enter. One scene per zone — variants are node groups, never duplicate scenes.
- Classes of change:
  1. **Perception**: decor reveals truth (scratches spell names; the merry-go-round's "rust" pattern is a seal diagram).
  2. **Interaction**: objects gain verbs (the toy chest can be *listened to*; a grave can be apologized at — morality beat).
  3. **Access**: a door/path that "was always there" becomes usable (knowledge IS the key — no fetch-item).
  4. **Inhabitants**: spawn-table swaps (a Stilled monster waits where its house stood, see [[mechanics/encounters-mercy]]).
- Companions react on first recontextualized visit (Briar whines at the spot he was rescued — bond moment for free).
- **Stage-keyed variant** (research 2026-06-12): the same group mechanism can key on `HollowingClock.stage` instead of a revelation (e.g. `recontext_stage_2` poster swaps) — doom presentation reuses this rail; see [[mechanics/hollowing-clock]].

## Content plan (v1)
3 zones × 2-3 revelations each ≈ **8-10 authored recontext moments**, anchored on the big bible twists (monsters-are-children, elders-are-survivors, Rowan-is-the-vessel). The playground gets the full treatment (it's the thesis statement: safety → horror → grief).

## Data model / tech
- Naming convention: nodes grouped `recontext_<revelation_id>`; a 20-line `ZoneRecontext` helper applies visibility on `zone_entered` + live on `GameEvents.revelation_unlocked`.
- NG+ interaction: revelations carried into NG+ mean zones start recontextualized — the run *feels* different from minute one (replay hook from [[mechanics/progression]] NG+ echoes, no extra work).

## Edge cases
- Never recontextualize a zone the player is standing in mid-change (apply on enter; live changes only via explicit scripted moments).
- Recontext access paths must not break sequence (gate checks remain on flags, not geometry alone).

## Related
[[mechanics/progression]] · [[mechanics/encounters-mercy]] · [[mechanics/vision-and-darkness]] · [[story/bible]] · [[design/feature-candidates-2026-06]]


======================================================================
SOURCE: docs/design/ai-production-setup.md
======================================================================

---
name: AI Production Setup (FOSS-first)
date: 2026-06-10
tags: [design, pipeline, ai-tools, licensing]
status: active
related_decisions: "[[decisions/2026-06-10-new-features-and-ai-setup]]"
---

# AI Production Setup — FOSS-first, upgrade later if needed

The complete per-area AI/tooling stack to take *Cycle of Innocence* from current state to shipped (Linux/Android/Web). Chosen stance (2026-06-10): **start free/FOSS everywhere; upgrade selectively to paid tools only when a concrete quality or volume wall is hit.**

## Stack by production area

| Area | Now (free/FOSS) | Upgrade trigger → paid option |
|---|---|---|
| Pixel art (concepts/bibles) | **Grok Imagine** → pixel cleanup (scripted or GIMP/Pixelorama — no Aseprite installed) + `tools/pixelize.py` (magenta chroma-key), nearest-neighbor import | — |
| Pixel art (character animation & variants) | Grok placeholders for the slice (functional but clunky) | **TRIGGER FIRED 2026-06-10** (Grok can't grid-align animation sheets) → **PixelLab** ~$12-30/mo pause-able, when variant work starts — skeleton rigs keep pose timing identical across outfit/age variants (see [[decisions/2026-06-10-sprite-tool-pixellab]]) |
| Pixel art (static tiles/icons) | Grok Imagine | Retro Diffusion ($20 one-time Aseprite Lite) if tileset quality wall fires |
| Music | **ACE-Step** (Apache 2.0, free web/self-host) for instrumental loops → **Audacity** loop/crossfade, export OGG | Need vocals or signature tracks → Suno Pro $10/mo (commercial license; never use Suno free tier commercially) |
| SFX | **ChipTone** + **sfxr** (free) for UI/hits/pickups; layer in Godot audio buses | Complex organic horror SFX ("wet stone crumble") → ElevenLabs SFX $5/mo Pro |
| Voice | **None — deliberate.** Text-only horror (Undertale/Inscryption precedent); text + ambience scarier than mediocre TTS | Trailer narration only, if ever |
| Dialogue | **Dialogue Manager** (MIT, pure GDScript — replaced Yarn Spinner: C#-only addon breaks Web export in 4.4) + LLM-drafted dialogue using [[story/bible]] as context, human-reviewed, **pre-baked only** (no runtime LLM text) | — |
| Code agents | **Claude Code + Cursor** (existing) + **godot-mcp** (FOSS MCP server: scene-tree reads, run-game, error capture) | — |
| In-game AI | **LimboAI** behavior trees + `NavigationAgent2D` pathfinding. **No runtime LLM calls** — offline mobile requirement, 300–1000ms latency, per-player API cost | — |
| Testing | **GUT** unit tests + `godot --headless` (CI-able via GitHub Actions) | — |

## Installed in this repo (2026-06-10)
- `addons/` — Dialogue Manager v3.10.4, LimboAI v1.6.0 (Godot 4.4 GDExtension build), GUT v9.6.0
- `tests/` — smoke tests; run via `tools/run-tests.sh`
- godot-mcp registered in Claude Code MCP config (scene-tree access for agents)
- PixelLab API client `tools/pixellab_api.py` (user subscribed 2026-06-10, free tier; key at `~/.config/pixellab/api_key`, never committed; generation needs credit top-up)

## Workflow rules
1. **Art**: Imagine prompt batches from [[art/imagine-prompts]] → generate at 2–4× target size → downscale scripted or in GIMP/Pixelorama (interpolation: none; no Aseprite installed) → palette discipline pass → import with nearest filter. Always add human pixel-edit work on top of AI output (strengthens legal authorship position — no AI tool indemnifies).
2. **Audio**: generate 3–5 ACE-Step candidates per mood, pick, loop in Audacity. Compose as **stems** (ambient/tense/danger sharing BPM/key per zone theme) for the adaptive system ([[../mechanics/adaptive-audio]]). Keep generation prompts/files as provenance receipts.
3. **Dialogue**: LLM drafts against the story bible; human pass for voice consistency; Dialogue Manager's in-editor test scene to validate branches; nothing generated at runtime.
4. **Code**: Grok = vision/architecture/prompts; Claude Code/Cursor = implementation via godot-mcp; runtime errors pasted back in text (agents are runtime-blind — test with F5/headless, report, iterate). Agents scaffold; humans balance (damage values, AI difficulty, dread tuning are playtest work).
5. **Enemy/companion AI**: design archetypes as LimboAI behavior trees (patrol/alert/chase/attack; companion follow/assist/fear states keyed to bond & corruption); tune via blackboard variables; watch live with LimboAI's visual debugger.

## Store compliance (disclosure)
- **Steam**: Tier 1 pre-generated AI content form — disclose AI-assisted sprites/music/SFX categories. Dev tools (Claude Code, Cursor, Copilot) are **exempt**, as are rule-based AI (LimboAI) and procedural generation. No live-generated content shipped.
- **Google Play**: similar disclosure in listing; EU listings should label AI-generated content explicitly. Offline-playable is also a Play policy expectation — another reason for no runtime LLM.
- **itch.io**: no formal requirement; add a transparency note on the page (audience values it).
- Never claim "100% handmade"; "designed and directed by the developer using AI-assisted tools" is accurate.
- **Licensing red lines**: no commercial use of free tiers that forbid it (ElevenLabs free, Suno free); no voice-cloning real people; keep prompt/project receipts for all generated assets.

## Cost posture
Current monthly cost: **$0** beyond existing subscriptions (Grok, Claude/Cursor). Full selective-paid stack if all upgrade triggers fire: ~$25/mo (Retro Diffusion + Suno + ElevenLabs). Decision per tool, recorded in [[decisions/_index]] when taken.

## Related
- [[decisions/2026-06-10-new-features-and-ai-setup]] · [[art/imagine-prompts]] · ../AGENT_RULES.md (R4 asset pipeline) · ../GROK.md


======================================================================
SOURCE: docs/design/customization.md
======================================================================

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


======================================================================
SOURCE: docs/design/feature-candidates-2026-06.md
======================================================================

---
name: Feature Candidates — Recent Games Research (Round 2)
date: 2026-06-10
tags: [design, research, features]
status: active
related_decisions: "[[decisions/2026-06-10-recent-games-research-greenlight]]"
---

# Feature Candidates from Recent Games (2022–2026) — Research Round 2

Round 1 ([[decisions/2026-06-10-new-features-and-ai-setup]]) covered genre classics. This round mines **recent releases** for unique mechanics, filtered against existing design and the locked stack (Godot 4.4 GDScript, Dialogue Manager, LimboAI, 32×32, solo dev, Linux/Android/Web).

## Per-game findings (condensed — unique mechanics only)

| Game (year) | Unique mechanic(s) | Fit |
|---|---|---|
| **Look Outside** (2025) | Transformation-as-gameplay: observing the phenomenon mutates the body; mutations spread by proximity; enemy phases evolve mid-fight | Tonally aligned; transformation tracking = state machine + sprite tiers (our corruption already does this) |
| **Pacific Drive** (2024) | **Quirk system**: companion (car) develops persistent, diagnosable behavioral quirks; trust erosion → refusal | ★ Greenlit → [[mechanics/companion-quirks]] |
| **Dredge** (2023) | Sanity spiral: hallucinations become unreliable *guides*, not just scares; risk-asymmetric day/night | Day/night already greenlit; false-guide hallucinations → refinement in [[mechanics/vision-and-darkness]] |
| **Mouthwashing** (2024) | Unreliable narrator dialogue (what you pick ≠ what is said); world spatially shrinks over time | ★ Greenlit (dialogue) → [[mechanics/interface-horror]]; map-shrink already in [[mechanics/hollowing-clock]] |
| **Heartworm** (2024) | Control degradation as possession horror (input stutter/delay/inversion) | ★ Greenlit → [[mechanics/interface-horror]] |
| **Sorry We're Closed** (2024) | Ambient/overheard narrative — conspiracy leaks via background dialogue and mundane wrongness | ★ Greenlit → [[mechanics/village-life]] |
| **Shadows of Doubt** (2023) | NPC daily routines (work/lunch/sleep schedules) you observe and exploit | ★ Greenlit (scaled to ~12 NPCs) → [[mechanics/village-life]] |
| **Void Stranger** (2023) | Knowledge-gated recontextualization: old rooms function differently once you know things | ★ Greenlit → [[mechanics/zone-recontextualization]] |
| **Animal Well** (2024) | Tool layering: every item has 3-5 cross-context uses; secrets in plain sight | Design rule adopted (ideas inbox): every companion ability needs 2-3 uses before it ships |
| **Undertale Yellow** (2023) | Per-enemy unique mercy interactions; repeating generic actions wastes turns | Refinement → [[mechanics/encounters-mercy]] |
| **In Stars and Time** (2023) | Loop-aware NPC memory: fractional remembered details across loops | Refinement → NG+ echoes in [[mechanics/progression]] |
| **Cult of the Lamb** (2022+) | Sacrifice with mechanical teeth (power vs loyalty); dual action/management loop | Sacrifice tension already core story; management loop rejected (scope) |
| **Crow Country** (2024) | Fully beatable with zero combat; multi-solution puzzles | Stretch accessibility goal (ideas inbox); mercy path partially covers |
| **Slay the Princess** (2023) | Choices vs the game's memory of what "really" happened | Flavor for NG+; no new system |
| **The Coffin of Andy and Leyley** (2023) | Small dialogue choices cascade into long-term relational decay | Validates our existing dialogue→bond/corruption mapping; no new system |
| **Hades II** (2024-25) | Familiar recruitment/upgrade via tokens | Rejected — conflicts with 3 fixed story companions |
| **Dave the Diver** (2023) | Tiered staff recruitment economy | Rejected — recruitment economy off-theme |
| **Lorelei and the Laser Eyes** (2024) | Real-world-knowledge puzzle language; learn the game's symbols | Partial: ritual-symbol literacy as puzzle flavor (ideas inbox) |
| **Leap Year** (2024) | Progression = knowledge only, zero new abilities | Philosophy already ours (no XP); affirmation |
| **Roadwarden** (2022) | Time+reputation economy; appearance affects prices | Per-NPC suspicion absorbed into [[mechanics/village-life]] + hollowing alarm points |
| **Moonring** (2023) | Free-form dread systems in top-down retro RPG; regenerating dungeons | Procedural dungeons rejected (handcrafted zones locked) |
| **Stifled / Phasmophobia** | Microphone-as-input horror | Rejected — Web/Android API pitfalls, accessibility |
| Godot practice (2024+) | 3-stem adaptive audio (ambient/tense/danger) via AdaptiSound (FOSS) | ★ Greenlit → [[mechanics/adaptive-audio]] |

## Tiers

- **Tier A — greenlit, slice-adjacent (cheap, high horror-per-line-of-code)**: [[mechanics/companion-quirks]] · [[mechanics/interface-horror]] · [[mechanics/adaptive-audio]] · gossip half of [[mechanics/village-life]]
- **Tier B — greenlit, post-slice (systemic)**: NPC schedules ([[mechanics/village-life]]) · [[mechanics/zone-recontextualization]] · ability-layering design rule
- **Tier C — refinements appended to round-1 docs**: unique soothe interactions (mercy) · hallucinated false pings (vision) · loop-memory dialogue (progression/NG+)
- **Rejected**: microphone input, procedural dungeons, settlement/follower management, recruitment/economy tiers, card mechanics

## Build-order note
Nothing here preempts the vertical slice. Slice ships first (child Rowan + Briar + one zone); Tier A features are designed to bolt onto systems the slice already exercises (companions dict, dialogue, dread, audio buses).

## Related
[[design/game-features]] · [[decisions/2026-06-10-recent-games-research-greenlight]] · [[ideas]]


======================================================================
SOURCE: docs/design/game-features.md
======================================================================

---
name: Game Features & Systems Overview
tags: [design, features, mechanics, scope]
status: draft
related:
  - "[[story/bible]]"
  - "[[characters/companions]]"
  - "[[mechanics/progression]]"
  - "[[mechanics/combat]]"
  - "[[design/customization]]"
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
- Vertical slice first: one zone as child Rowan + Briar, basic real-time combat, one companion-assisted puzzle, one meaningful dialogue choice, light horror beat.
- Prioritize emotional impact and replay over breadth.
- Cut anything that doesn't serve story, companions, or horror.
- Pixel art 32x32 limits (age/morality variants via sprite swaps + shaders, not hundreds of outfits).
- Leverage Godot strengths: AnimationPlayer, 2D lights/shaders for dread, Dialogue Manager for branching, signals for systems.

**Key Pillars**:
1. **Age & Life Progression** (Fable-inspired): Child → Teen → Adult. Visuals, reach, dialogue options, and world perception change.
2. **Morality / Alignment**: Numeric or tiered (Innocent / Wounded / Hardened / Vessel). Affects appearance (scars, glow, posture), companion bonds/corruption, NPC reactions, available abilities, and endings.
3. **Animal Companions as Core "Party"**: Rescue, name, raise, bond, use in exploration/combat/puzzles. Corruption is a major horror vector.
4. **Real-time Action + Horror Tension**: Fluid movement/combat that gets scarier as dread rises or corruption spreads.
5. **Branching Truths**: Dialogue Manager-driven dialogue where revelations change everything. Choices have delayed, compounding consequences.
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
  - Affects immersion and some dialogue lines ("Briar" vs custom name).
  - Default names: Briar (hound), Echo (bird), Storm (mount).
- **Visuals**: Growth stages (puppy → adult) + corruption variants are the main "customization." Minor bond-based details (handmade collar color chosen by player? simple accessory).
- **Personality Flavor**: Fixed core personalities from story bible, but bond level changes behavior (fearful vs brave, loyal vs resentful).

**Technical**:
- SpriteFrames resources per age stage + morality tier (or base + shader params + overlay sprites for scars/glow).
- PlayerData stores custom name, gender flag, chosen accent color, companion custom names.
- dialogue variables: `$player_name`, `$player_gender`, `$companion_name_briar`, etc.

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

**Technical**: CompanionManager autoload. Each companion is a scene with its own state machine (bond, corruption, current abilities). Signals to PlayerData and dialogue. Dedicated companion visual nodes that swap sprites based on state.

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

**Technical**: Simple Inventory resource or array in PlayerData. UI that feels retro but readable. Items can trigger dialogue mutations or companion state changes.

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

## 9. Narrative & Dialogue (Dialogue Manager)

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
  - Dialogue Manager for all branching.
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

## 15. Greenlit Additions (2026-06-10 research round 2 — recent games)

From the recent-releases research pass ([[design/feature-candidates-2026-06]], decision: [[decisions/2026-06-10-recent-games-research-greenlight]]):

**Slice-adjacent (cheap, high horror-per-effort):**
1. **[[mechanics/companion-quirks]]** — bond/corruption manifests as diagnosable companion behaviors (false pings, true growls, refusals); the player learns to read the family. (Pacific Drive)
2. **[[mechanics/interface-horror]]** — Vessel-tier dialogue distortion + dread-driven control degradation, behind the horror-intensity slider. (Mouthwashing/Heartworm)
3. **[[mechanics/adaptive-audio]]** — ambient/tense/danger/companion stems crossfaded from dread, time, and hollowing stage. (FOSS AdaptiSound or ~100-line autoload)

**Post-slice (systemic):**
4. **[[mechanics/village-life]]** — ~12 villager daily routines + proximity-overheard gossip + per-NPC suspicion feeding the hollowing clock. (Shadows of Doubt / Sorry We're Closed)
5. **[[mechanics/zone-recontextualization]]** — revelations change how existing zones function on revisit; the playground is the thesis statement. (Void Stranger)

Plus refinement notes added to encounters-mercy (unique soothe per monster), vision-and-darkness (counterfeit pings at high dread), and progression NG+ (loop-memory dialogue).

---

## Next Steps for Features

1. Lock story bible (user review in progress).
2. Flesh out individual mechanics docs (see linked files in this vault).
3. Prototype in code: PlayerData + age/morality/companion state first, then real-time combat with one assist, then basic dialogue integration.
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


======================================================================
SOURCE: docs/design/market-positioning.md
======================================================================

---
name: Market Positioning & Platforms
date: 2026-06-12
tags: [design, marketing, platform]
status: draft
related_decisions: "[[decisions/2026-06-12-steam-timing]]"
---

# Market Positioning & Platforms

Source: research round 3
([[research/done/2026-06-12-research-round3-outside-view-and-market]]).
Reliability markers preserved; **re-verify all sales figures at the marketing
milestone** (alongside the patent re-review).

## The lane is commercially proven — and crowding

- Mouthwashing: **500k+ copies on Steam at $13, five-person team**,
  Overwhelmingly Positive; lifetime sales 10–15× first week, word-of-mouth /
  streamer-driven. `[verified 2026-06-12, gamedeveloper.com; gamesradar.com; GameDiscoverCo]`
- World of Horror, OMORI, Undertale, Fear & Hunger: lo-fi/pixel horror with
  strong identity sells hundreds of thousands to millions. `[training knowledge —
  re-verify exact figures at marketing milestone]`
- The crowding is specifically the **brutalist F&H-like corner** ("fhunger-likes";
  Look Outside rode that lane jam→Devolver in 5 months). `[verified 2026-06-12]`

## Positioning

**Counter-position against the Fear & Hunger wave, not inside it.** The
mercy-core is the differentiator no current comp combines: child→adult life arc
with morality-driven body/world change, mercy as the core combat verb, the
village-that-moved-on conspiracy, authored companion family.

One-liner that survives contact:

> **"Undertale's mercy in Silent Hill's village — and you grow up inside it."**

Keep it at the front of every pitch sentence; the monsters-are-children lullaby
verb is the hook, never "retro horror RPG."

## Capsule & trailer rules

- Sell **horror tone and premise**, never "retro RPG" aesthetics — Feb-2025
  Next Fest data: pixel art over-performed in systems-depth genres, top RPG
  demos were 3D, horror placed ×2 in the top tier. `[verified 2026-06-12, presskit.gg]`
- Theme handling: child-sacrifice horror is shippable (ample precedent), but
  store-page framing, content warnings, and capsule tone need deliberate care
  at the demo milestone. Production risk: none. Marketing risk: real, manageable.

## Demo design

The public demo is a **complete emotional arc**, ending exactly on the
HollowingClock **stage 0→1 transition** — first bell, Briar's whimper, the
world tilting. Streamable and self-contained (the Mouthwashing long-tail
lesson); the reveal beat makes viewers need the rest. Stands on: ZoneManager,
Dialogue Manager, HollowingClock, adaptive audio. Serves a horror beat + story
+ replay-curiosity.

## Platform split

| Channel | Role |
|---|---|
| **Web (itch + NAS)** | Shop window: demo, discovery, external playtest loop — never the product |
| **Android** | The real mobile product (native export; touch parity already a slice criterion) |
| **Steam** | The revenue platform — timing pending [[decisions/2026-06-12-steam-timing]] |

### Web export — verified facts (Godot, 2026-06-12)

- Godot 4.3+ restored **single-threaded web export**: no cross-origin
  isolation needed (itch-embed friendly), fixes Apple/iOS issues; audio via
  Web Audio API Sample mode, low latency. `[verified 2026-06-12, godotengine.org]`
- Web export is **Compatibility renderer only**; **C# cannot export to web**
  (independent confirmation the Dialogue Manager switch was forced and correct).
- Keep initial payload in the **tens of MB**, prefer single-threaded export for
  the itch demo, test **Firefox/Chromium first** (Safari WebGL2 quirks persist).
  `[verified 2026-06-12]`

## Related

[[decisions/2026-06-12-steam-timing]] · [[decisions/2026-06-10-patent-risk-review]] ·
[[design/game-features]] · [[research/done/2026-06-12-research-round3-outside-view-and-market]]


======================================================================
SOURCE: docs/art/prop-coherence.md
======================================================================

---
name: Prop Coherence — rules & fix plan
date: 2026-06-12
tags: [art, pipeline, rules]
status: active
related_decisions: "[[sessions/2026-06-11]] (backdrop art direction lock)"
---

# Prop Coherence — Rules & Fix Plan

Source: art-tooling research + cross-model (Grok) review
([[research/done/2026-06-12-research-art-tooling-prop-coherence]]), corrected
by local verification 2026-06-12.

**Verdict (convergent across two models + audit): the stack is right; the
screenshot failures are a compositing/workflow gap, not a tooling gap.**
PixelLab characters, Grok GROUND-ONLY backdrop repaints, and the hand-rolled
adaptive audio are all reaffirmed — keep the locked art lane.

**Mid-2026 reality check** `[verified 2026-06-12]`: AI map tooling is
asset/tileset-level everywhere (PixelLab map tools are guided inpainting;
Ludo.ai is tilesets; nothing layout-level exists). Nothing one-shots a village
that "makes sense." Layout stays design work here **by necessity** — it is
load-bearing: VillageState routine markers, eavesdrop zone placement, Warden
patrol readability, recontext groups. Zones must read as *lived-in conspiracy
spaces, not modular kitbash* — that is the replay-value stake.

## Rules (apply to every prop, every zone)

1. **Palette hard-lock**: extract each zone backdrop's 48-color palette;
   force-quantize every prop to it — shipped implementation:
   `tools/palette_lock.py` (nearest-RGB, alpha preserved, `--dry-run`).
   Upgrades the Terranigma-pass desaturation fix into a guarantee. Biggest
   visual win per minute.
2. **Flat-neutral-light authoring**: props carry NO baked time-of-day light
   and NO cast shadows — `CanvasModulate` + lights own time-of-day. (A prop
   repainted to match one scene's light is wrong in every other scene.)
3. **Scale chart** (pin in [[art/imagine-prompts]]): player = 32 px reference;
   door ≈ 1.3× player; lamp/fence/well heights pinned alongside.
4. **Shadow canon (restated — a cross-model review garbled it)**: procedural
   contact-shadow ellipses for small props; baked worn foundations for
   buildings; **no shadow ellipses on ≥96 px sprites** (they caused floating).
5. **Projection Canon ("Zelda perspective")** *(research 2026-06-12,
   [[research/done/2026-06-12-research-projection-canon-angle-consistency]])*:
   one camera for the whole game — **low top-down (~20°), cheated
   oblique/mixed projection** (floors in plan view, fronts in elevation; tops
   AND front faces visible, verticals stay vertical, no vanishing points, no
   horizon). Perfect geometry is not the goal; **consistent cheating** is.
   - Every PixelLab call passes `view="low top-down"` **explicitly — defaults
     are never trusted**: they differ per tool (`create_map_object` /
     `create_topdown_tileset` default *high top-down* ≈35°; character tools
     default *low top-down* ≈20°) `[verified 2026-06-12, MCP docs + local
     schema]`. `check-brain.sh` lints `tools/*.py` for off-canon views
     (`# canon-override:` comment to exempt deliberately).
   - **Canon provenance** (stronger than overlay measurement): every
     production script already pinned `low top-down` at its call site
     (pixellab_props/village_props/npcs/v2.py) — all approved assets ARE the
     canon. The only drift ever shipped was the 2026-06-12 candidates,
     generated at high top-down through the then-viewless item-6 recipe
     (regenerated same day).
   - Grok ground repaints stay **angle-neutral**: plan-view texture only,
     uniform texture density top-to-bottom, no objects, no foreshortening, no
     shadows (templates in [[art/imagine-prompts]]).
   - Baked foundation fronts in the geometry-guide step follow the canon
     ratios below.
   - **Canon ratio table** (eyeball QA gate; ≈ values):
     ground circle (well rim, barrel top) ellipse height ≈ **0.34× width**
     (~1:3; high top-down ≈ 0.57× — reject); box visible top depth : front
     height ≈ **1:3** (high ≈ 2:3); verticals never converge; buildings show
     a **thin roof strip, mostly facade** (deep roof plane = wrong camera).
   - **QA overlay import gate (instruments shipped 2026-06-12)**:
     `assets/reference/qa_overlay_128.png` — green canon ellipses **64×22**
     and **32×11** (= 0.34, ~20°), red reject ellipse **48×27** (= 0.57,
     ~35°), canon box **top 7 px / front 21 px** (1:3), double vertical ruler
     with 8 px ticks — plus `qa_overlay_legend.png` (how to read it) and
     `tools/gate_sheet.py` (editor-less: composites the overlay onto
     `candidates/*.png` at 4× NN into one contact sheet). Every new
     prop/building/repaint passes before import. Reject on fat ellipses,
     converging verticals, or ground texture that shrinks toward the top.
   - **Gate instrument note**: pitched roofs legitimately show large slope
     area at low angles (classic Zelda houses are mostly roof) — **roofs are
     NOT the pitch instrument; horizontal circles are** (mouths, rims,
     barrel tops). Don't false-flag the cottage or the stall awning.
   - **Iconic-prior props** (well, pond, cauldron, basin — anything defined
     by a round opening): the model's prior is the open mouth seen from
     above, and `view` alone won't override it ("weakly controls",
     empirically: param-only well measured 0.51 → FAIL). Carry the angle in
     the **description content** — side-visible wall, rim as a thin flat
     ellipse, interior not visible beyond a thin dark sliver — (validated:
     PASS on roll 1); escalate to image-to-image (depth) with a programmatic
     grey-box only after 2–3 failed rolls.
   - **"Edge canon" rule-6 candidate: CLOSED — not needed** (empirical edge
     check 2026-06-12: 0 semi-transparent pixels, no near-black outline
     ring on either fence; the pasted-on look was palette/shading/angle).
     No defringe step; the `outline` param stays as is.
   - **Legacy audit (2026-06-12, ratio glance)**: terrace/cliff tileset PASS,
     chapel roof PASS — the pre-explicit-view assets already sit on the
     canon; no depth-i2i rework needed. Pinned references:
     `assets/reference/canon_view_character.png` + `canon_view_prop.png`
     ([[art/imagine-prompts]]). Lint also covers the `tile_view` key
     spelling.

## Prop generation workflow

- **New props**: PixelLab `create_map_object` with `view="low top-down"`
  (rule 5 — ALWAYS explicit) + a crop of the actual zone backdrop as
  `background_image` (style/palette/light inherited; output stays a
  transparent sprite for y-sort/collision) `[verified 2026-06-12,
  pixellab.ai/mcp]` — the multi-lock: the view param is weak ("weakly
  controls", per PixelLab docs), the crop is contextual (and reference params
  have a known 500 failure mode), so view + crop together converge. Fallback
  is `generate-with-style-v2`/bitforge with the same crop (confirm its
  `view`/`oblique_projection` params against the OpenAPI spec before relying
  on it).
- **Variants** (recontext / VillageState states of an existing prop): always
  `create_object_state` on the canon object — inherits view, seed-stable —
  **never a fresh generation**. `[verified 2026-06-12, MCP docs]`
- **Geometry lock for resistant props/buildings**: PixelLab **image-to-image
  (depth)** with an approved canon asset (or 5-minute grey-box) as depth
  reference, high `depth_strength` — ControlNet-style angle lock inside the
  locked stack. Buildings first: largest area, strongest pitch signal.
  `[verified 2026-06-12, pixellab.ai/docs/tools/image-to-image-depth]`
- **PROPS-ONLY `edit_image` diagnostic**: one repaint pass on a real composited
  screenshot ("repaint the lantern/bench/well to match the ground lighting and
  palette") to set the visual bar before regenerating anything. **Benchmark
  only, never the standing pipeline** — re-cropping repainted props bakes
  scene light into the sprite (violates rule 2).

## Ordered fix plan (cheap → structural; verified state 2026-06-12)

1. ~~Remove courtyard decal instances~~ — **already clean in repo** (no
   decal/courtyard/set-piece nodes in any scene; the reviewed screenshots were
   stale vintages).
2. ~~Clamp Camera2D limits to backdrop rects~~ — **DONE 2026-06-12**
   (branch `fix/zone-coherence-camera-palette`): `ZoneRoot` clamps the player
   camera to the `GroundBackdrop` rect + 16px bleed on zone enter, and resets
   limits in zones without a backdrop so clamps never leak across transitions.
3. ~~Palette hard-lock pass over existing village props~~ — **DONE
   2026-06-12** (same branch): new `tools/palette_lock.py` (PIL,
   nearest-RGB remap, alpha preserved, `--dry-run`); all 10 village props
   were 100% off-palette and are now locked to the backdrop's 48 colors.
   Expected casualty: cool accents (chapel roof) went warm-olive — the
   palette has no cool colors by design; polish via item 5 regen if needed.
4. ~~Extend foundations + contact ellipses to the village zone~~ — **VERIFIED
   ALREADY COVERED 2026-06-12**: `PropShadows.apply($World)` runs in BOTH zone
   scripts (village_green.gd:50), village props follow the StaticBody2D+
   Sprite2D pattern it targets, and village buildings sit on baked worn
   foundations since the backdrop lock. The research screenshots predated
   this (stale vintages).
5. ~~Regenerate worst offenders~~ — **DONE 2026-06-12** in three rounds:
   staged at canon view → user placed well_v2 + fence_v2 in the editor
   (offsets + colliders) → gate caught well_v2 at 0.51 (iconic prior) →
   prior-busting regen PASS roll 1, replaced in place (44×51 vs 54×60 — well
   collider needs a nudge). Remaining props (bench, lantern_post,
   harmony_board, market_stall) batch-regenerated at their placement-spot
   crops, palette-locked, **all six gated PASS** — staged in `candidates/`
   awaiting placement.
   Buildings deliberately NOT regenerated: palette lock + baked foundations
   already ground them, and a regen would fight the foundations painted into
   the backdrop.
6. ~~`create_map_object` smoke test~~ — **PASSED 2026-06-12**: no server-side
   500 (unlike create-tileset's reference params); style/projection inherited
   from the backdrop crop; palette only partially inherited → run
   `tools/palette_lock.py` on every result. **Production recipe**: crop the
   zone backdrop where the prop will stand → background_image (the MCP path
   mode hands back a curl command — key comes from `~/.config/pixellab/api_key`,
   never inline) → **`view="low top-down"` explicit (rule 5)** → object size ≈
   crop size × oval fraction (64px crop + fraction 0.72 ≈ 45–60px prop; 128px
   crop ≈ 75px+ prop — pick crop size for target scale) → trim transparent
   border → palette-lock → ratio-table/QA-overlay check → stage in
   `assets/sprites/village/candidates/` for editor placement (placement/scale
   is the user's editor pass).
7. **Editor pass (user) — THE ONLY OPEN ITEM**: missing StaticBody2D on the
   painted stone wall; audit painted features vs collider coverage; check
   the midday player-glow toggle; nudge the well collider (item-5 in-place
   regen); place the four new gated candidates.

## Filter test

Serves **horror beats** directly (the warm/cold zone thesis is a palette
effect — it cannot land while props carry foreign palettes), **companion
arcs** (Briar's pings/digs read as grounded only in a believable village
edge), and **replay** (recontext moments need lived-in spaces to
recontextualize). No new mechanics — everything slots inside the
content-complete-per-zone rule.

## Related

[[art/imagine-prompts]] · [[plan/slice-implementation-roadmap]] ·
[[research/done/2026-06-12-research-art-tooling-prop-coherence]] ·
[[sessions/2026-06-11]]
