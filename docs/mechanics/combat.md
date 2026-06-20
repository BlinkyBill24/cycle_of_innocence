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
- **Read-only reference** *(from [[research/done/2026-06-20-michael-games-aarpg-harvest]])*: the MIT `github.com/michaelmalaska/aarpg-tutorial` (typed GDScript, Godot 4.x) is a clean, idiomatic **typed Area2D hit/hurtbox** implementation worth comparing against if we ever revisit combat plumbing. **Two hard exclusions — do NOT lift:** (1) it calls autoload singletons directly by name with no signal bus — our **GameEvents** bus is the better, more-decoupled pattern, keep it; (2) it uses a hand-rolled GDScript FSM — we are standardized on **LimboAI**, so it offers no transferable enemy-AI patterns. Read it for *typed combat shape only*, never for wiring/AI.

## Scope for v1

- 5-7 enemy types max, heavily iterated.
- 2-3 companion assist moves per companion (unlocked over time).
- Focus on 2-3 distinct combat "feels" (child desperate, teen growing, adult powerful-but-damned).
- Polish the horror feedback (dread effects, corruption visuals) over adding dozens of moves.

**Equipment (post-slice):** the planned gear system ([[mechanics/equipment]]) feeds small **medium-weight** modifiers into combat — and is deliberately weighted toward **soothe / defense / dread-resist**, not pure damage, so it reinforces mercy/soothe rather than a brute-force lane. No numeric HUD; strength is felt (sprite change, old enemies reading easier via recontext).

**Ability directions (post-slice, from [[research/done/2026-06-20-player-abilities]]):** make the attack read differently by **age & morality** (innocent = desperate/merciful; ruthless = harder hits that cost companions/corruption) — start with two "feels" + companion reactions. Add a **short, grounded dodge** (dodge → soothe) that can shave dread on success. A **separate punch button is redundant — fold it into the attack variants / close-range mercy option**, and keep any **jump** rare and story-gated only (a free jump pulls toward platformer and hurts dread pacing + 32×32 readability). Tracked in [[ideas]].

See [[design/game-features]] for the high-level vision and [[mechanics/horror-and-dread]] for how dread specifically interacts with combat. This system must feel personal — every fight should remind the player why they're fighting and what they stand to lose.