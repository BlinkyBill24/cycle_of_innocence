---
name: Interface Horror (Dialogue Distortion + Control Degradation)
date: 2026-06-10
tags: [feature, mechanics, horror, dialogue, accessibility]
status: planned
related_decisions: [[decisions/2026-06-10-recent-games-research-greenlight]]
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

## Related
[[mechanics/horror-and-dread]] · [[mechanics/companion-quirks]] · [[design/customization]] (accessibility) · [[design/feature-candidates-2026-06]]
