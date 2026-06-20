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

**Direct shipped model** (secrets research 2026-06-13, [[design/secrets-and-discovery]]): **Void Stranger** (System Erasure, 2023) — new knowledge recontextualizes already-visited floors, with a second-run ARG layer that makes old rooms yield new interactions. The closest mechanical analogue to this spine. `[verified 2026-06-13]` **Scope caution for a solo dev**: a few *deep* flips beat many shallow toggles — Void Stranger / Outer Wilds / Animal Well all achieve recontext at scale via small, dense worlds, not many zones. Keep node count conservative.

**Stage-keyed variant** (✅ built 2026-06-13): `ZoneRecontext` now also toggles `recontext_stage_<n>` / `recontext_not_stage_<n>` groups by `HollowingClock.stage` (re-applied live on stage advance) — the same rail carries **doom presentation** (poster swaps, a fresh lottery notice appearing after the first bell) keyed to the net closing, per the [[mechanics/hollowing-clock]] doom-legibility roadmap. A `WhisperSpot` in such a group, with a `journal_text`, both speaks and records the sign as a Journal DOOM entry.

## Data model / tech
- Naming convention: nodes grouped `recontext_<revelation_id>`; a 20-line `ZoneRecontext` helper applies visibility on `zone_entered` + live on `GameEvents.revelation_unlocked`.
- NG+ interaction: revelations carried into NG+ mean zones start recontextualized — the run *feels* different from minute one (replay hook from [[mechanics/progression]] NG+ echoes, no extra work).

## Edge cases
- Never recontextualize a zone the player is standing in mid-change (apply on enter; live changes only via explicit scripted moments).
- Recontext access paths must not break sequence (gate checks remain on flags, not geometry alone).

## Future direction (inspiration, not yet decided)
*From [[research/done/2026-06-20-zelda-terranigma-mana-evermore-transferable-features]] (post-slice).* Zelda ALttP's Light/Dark world suggests giving a zone **2–3 authored states** ("normal → escalating dread → post-revelation") flipped by morality/bond/story flags — "the same place, but wrong now." Authored flips only (Web-safe, no parallel-dimension tech); pilot one zone. Tracked in [[ideas]].

## Related
[[mechanics/progression]] · [[mechanics/encounters-mercy]] · [[mechanics/vision-and-darkness]] · [[story/bible]] · [[design/feature-candidates-2026-06]]
