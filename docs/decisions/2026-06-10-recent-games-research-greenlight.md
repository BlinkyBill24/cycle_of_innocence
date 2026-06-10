---
name: Recent-games research (round 2) — greenlight quirks, interface horror, adaptive audio, village life, recontextualization
date: 2026-06-10
tags: [decision, features, research]
status: active
related_features:
  - "[[mechanics/companion-quirks]]"
  - "[[mechanics/interface-horror]]"
  - "[[mechanics/adaptive-audio]]"
  - "[[mechanics/village-life]]"
  - "[[mechanics/zone-recontextualization]]"
related_bugs: []
supersedes: null
superseded_by: null
---

# Research Round 2 — Recent Games (2022–2026) Feature Greenlight

## Context
After round 1 (genre classics → mercy/clock/day-night/vision-cone), the user asked for analysis of recent releases with unique features and a feasibility-filtered suggestions list. ~22 games researched (Look Outside, Pacific Drive, Dredge, Mouthwashing, Heartworm, Sorry We're Closed, Shadows of Doubt, Void Stranger, Animal Well, Undertale Yellow, In Stars and Time, Cult of the Lamb, Crow Country, Hades II, Lorelei, Leap Year, Roadwarden, Moonring, etc.). Full findings: [[design/feature-candidates-2026-06]].

## Decision
User greenlit all four proposed groups:
1. **Slice-adjacent**: [[mechanics/companion-quirks]] (Pacific Drive), [[mechanics/interface-horror]] (Mouthwashing/Heartworm), [[mechanics/adaptive-audio]] (3-stem mixing, FOSS AdaptiSound or hand-rolled).
2. **Post-slice**: [[mechanics/village-life]] (schedules + gossip + suspicion; Shadows of Doubt/Sorry We're Closed), [[mechanics/zone-recontextualization]] (Void Stranger).
3. Refinement notes appended to round-1 docs: unique soothe per monster (mercy), counterfeit pings (vision), loop-memory dialogue (progression NG+).
4. Design rule to ideas inbox: ability layering (Animal Well) — every companion ability ships with 2-3 cross-context uses.

Build order unchanged: **vertical slice first**; Tier A bolts onto slice systems, Tier B comes after.

## Alternatives (rejected, with reasons)
- **Microphone-input horror** (Stifled/Phasmophobia): Web/Android API fragility, accessibility, privacy.
- **Procedural dungeons** (Moonring): handcrafted zones are locked design.
- **Settlement/follower management** (Cult of the Lamb/Bellwright): scope; companions are the management layer.
- **Companion recruitment tiers/tokens** (Hades II/Dave the Diver): conflicts with 3 fixed story companions.
- **Card/deck mechanics** (Inscryption): genre mismatch; its sacrifice-weight insight is already core story.
- **Crow Country full no-combat mode**: deferred to ideas inbox as accessibility stretch (mercy path partially covers).

## Consequences
- + Round-2 features are mostly *expression* layers over existing data (companions dict, dread, dialogue, audio buses) — high horror payoff, low architectural risk.
- + Village-life finally mechanizes the bible's cruelest beat (the village moves on without Rowan).
- − Design-debt grows: 9 greenlit-but-unbuilt systems now precede the slice. Mitigation: slice scope unchanged; greenlit docs are specs, not commitments to v1 if the slice gate fails.
- − Audio pipeline gains a constraint (stem-based composition, shared BPM/key).

## Implementation
- **Branch**: `docs/feature-research-round2`
- **Files**: `docs/design/feature-candidates-2026-06.md`, 5 new `docs/mechanics/*.md`, §15 in `docs/design/game-features.md`, refinement appendices in 3 round-1 docs, audio row in `docs/design/ai-production-setup.md`.
- **Verified**: check-brain.sh green; status.py no RED; pushed to origin.

## Lookback Questions
- After the slice: did quirks read as "family you can diagnose" in playtests, or as bugs?
- Did interface horror stay on the right side of frustrating (esp. on touch)?
- Was AdaptiSound 4.4-compatible, or did we hand-roll?

## Related
[[2026-06-10-new-features-and-ai-setup]] · [[design/feature-candidates-2026-06]] · [[design/game-features]]
