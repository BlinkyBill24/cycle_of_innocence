---
name: Companion Pointer (Briar-Seek — Commandable Guide)
date: 2026-06-13
tags: [feature, mechanics, companions, horror, exploration]
status: draft
related_decisions: "[[decisions/2026-06-13-next-phase-hollow-house-slice]]"
source: "[[research/done/2026-06-13-companion-pointer-investigation-design]] (R7 bridge)"
---

# Companion Pointer — Briar-Seek, a Commandable Guide

## What it does
A **commandable, diegetic leading behavior**: the player tells Briar to *seek*, and
she physically guides them to a target (a buried clue, a hidden book, a stuck
door) by orienting, trotting toward it, looking back if they don't follow, and
playing a terminal "tell" (dig/gaze/bark) at the spot. She is the project's
**"guiding wind"** (Ghost of Tsushima) — no minimap, no UI marker, no quest arrow.

> This is the **active** counterpart to the **passive** [[mechanics/companion-quirks]]
> *scent-growl* quirk (Briar growls at unrevealed diggables ≤ 90px) and the
> [[mechanics/vision-and-darkness]] scent-wisp perception. Those *ping* on their
> own; this one is *commanded and leads*. It builds on them — it does not
> replace them.

## Why it fits (prior art check, R3b)
- **Primary model — Blair Witch's Bullet** `[verified 2026-06-13]`: a dog the player
  commands to "seek" that leads, sniffs, growls toward unseen things, and
  retrieves story items; Bloober chose a dog over a second human precisely for
  the asymmetric skillset ("their senses are keener, but they can't solve the
  puzzles like you do"). Bullet is also **safe-by-default** — no death-by-player-
  error, no escort mission — which matches [[mechanics/encounters-mercy]]'s
  no-unavoidable-death rule.
- Serves three of the four pillars at once: **companion arc** (bond/corruption
  shape the behavior), **horror beat** (the same animal that finds clues fears
  rooms — [[mechanics/horror-and-dread]]), and **replay** (NG+ recontextualized
  targets, [[mechanics/zone-recontextualization]]).
- Builds on existing tech: the LimboAI follow tree, `PlayerData.companions`
  bond/corruption, and the GameEvents bus — no new systems.

## The behavior chain (readability-first)
The dominant readability failure in shipped games is the **one-shot, easy-to-miss
cue** (The Last of Us' "press L3" prompt) `[verified 2026-06-13]`. The whole chain
is designed against that:

1. **Command** — player issues *seek* (recall/whistle). Not automatic.
2. **Orient** — Briar faces the target with an **exclusive `seek` animation** +
   a **unique `briar_seek_bark` SFX used for nothing else** (kills the "is she
   just idling?" ambiguity).
3. **Lead** — she trots a few steps toward the target, **pauses, looks back** at
   the player; if they don't follow within N seconds she returns partway and
   repeats (Bullet's look-back loop). She never sprints ahead and abandons them.
4. **Tell** — at the spot she plays a terminal, **looping** dig/gaze tell until
   acknowledged. It **re-triggers on recall** — the player can always ask again
   (no missed-cue dead end).
5. **Escalate only on request** — re-hint when recalled, *never* auto-interrupt
   (avoids Okami/Issun's "breaks into a cutscene to point at the obvious"
   annoyance) `[verified 2026-06-13]`.

## The no-missable fallback (load-bearing)
**Every clue Briar can find is also findable without her** — Fable's model, where
a dead/absent dog falls back to a glowing trail you dig yourself `[training knowledge]`.
Briar makes discovery *faster and more characterful*; she never **gates** it. The
required target (e.g. a [[mechanics/inventory]] DiggableSpot / hidden book)
carries its own subtle affordance (shimmer / consistent 32×32 interactable glint
— see [[design/secrets-and-discovery]] pixel-hunt rule) so losing or corrupting
Briar can never hard-block content. Enforces [[design/secrets-and-discovery]]
binding rule #4 (*nothing story-critical permanently missable*).

## Bond / corruption modulation
- **High bond** → eager: faster trot, shorter look-back interval, confident tell.
- **High corruption** → hesitant or *wrong*: she lags, refuses some rooms
  ([[mechanics/companion-quirks]] phantom-guard / refusal), and at extreme
  corruption may seek a **false** spot occasionally (costs dread/resources, never
  a run — same rule as the false-ping quirk). Reading Briar correctly *is* the
  skill the horror corrupts.

## Data model / tech (no new systems)
- LimboAI behavior-tree branch `seek_target` (blackboard: `seek_target_pos`,
  `seek_active`), composed from the existing follow tree.
- Reads `PlayerData.companions[&"briar"]` bond/corruption for the modulation
  curves; no companion-internal coupling beyond the blackboard.
- GameEvents: `companion_seek_requested(target)`, `companion_seek_arrived(target)`,
  `companion_seek_tell(target)` — all on the bus, per AGENTS.md decoupling rule.
- Audio: one exclusive `briar_seek_bark` SFX + optional soft directional swell on
  the [[mechanics/adaptive-audio]] bed (no HUD).

## Edge cases
- **Briar absent/dead/refusing** → fallback affordance only; quest still
  completable.
- **Target already found** → seek no-ops with a contented tell, never re-leads to
  a consumed spot.
- **Multiple candidate targets** → seek the nearest *un-found* one; recall cycles.
- **During dialogue / cutscene** → seek freezes (mirrors quirk freeze on
  `exploration_paused`).
- **Accessibility** → the horror-intensity slider softens corrupted-seek visuals
  but never changes whether the target is findable.

## Design-language note (patent posture)
Briar-seek is an **authored, designer-scripted behavior** on one fixed character
— hand-defined trigger, animation, and bond/corruption curves, never procedurally
generated NPC evolution, hierarchy, or rank. Keep that framing in code, docs, and
marketing. See [[decisions/2026-06-10-patent-risk-review]].

## Status
**Built — pass 1** (2026-06-13, branch `feature/hollow-house`). `CompanionBase`
gained `command_seek(target)` + a `Seek` HSM state (lead → look-back loop →
exclusive tell + new `briar_seek` SFX), bond/corruption modulation, the pure
unit-tested `pick_seek_target`, and re-point on **recall (C)** via
`GameEvents.companion_recalled`. The no-missable fallback is live (`_try_companion_assist`
hand-dig when Briar's absent). First delivery: [[design/hollow-house-quest]].
Readability is the explicit playtest gate — *do players notice and follow the
cue, and find the clue without her?* (thresholds in
[[decisions/2026-06-13-next-phase-hollow-house-slice]]). Real `seek_tell`
animation + `briar_seek` bark are the asset pass (placeholders shipped).

## Related
[[mechanics/companion-quirks]] · [[mechanics/vision-and-darkness]] · [[mechanics/encounters-mercy]] · [[mechanics/horror-and-dread]] · [[design/secrets-and-discovery]] · [[design/hollow-house-quest]] · [[characters/companions]]
