---
name: Vision Cone & Darkness (Line-of-Sight Fog)
date: 2026-06-10
tags: [feature, mechanics, horror, rendering, companions]
status: planned
related_decisions: [[decisions/2026-06-10-new-features-and-ai-setup]]
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
