---
name: Pixel-Art Interior Design Brief — Classic Top-Down Interiors Reference Kit
date: 2026-06-14
source: claude.ai Research
prompt: How do classic SNES top-down games author cozy vs. abandoned interiors, and what reference kit should Cycle of Innocence use for its three interior scenes?
status: integrated
---

# Pixel-Art Interior Design Brief for *Cycle of Innocence* — Classic Top-Down Interiors as a Reference Kit

## TL;DR
- **Build all three rooms on the same modular grammar — a 2–3-tile-tall camera-facing back wall, an enclosed boxy floor, and 32×32 "map objects" placed in furniture clusters — and let dread come from palette, prop state, and runtime lighting, NOT from baked-in mood.** Classic SNES top-down homes (A Link to the Past, Terranigma, Secret of Mana) are tiny, single-screen, symmetrical, hearth-anchored spaces; the cottage should copy that warmth literally, while the hollow house inverts each cue (broken furniture, desaturation, asymmetry, an absence where something should be).
- **Author tiles/props FLAT and neutral.** Real pixel-art + Godot lighting pipelines (Catlike Coding's "True Top-Down 2D," Godot docs) assume unlit, evenly-lit art with a `CanvasModulate` + `PointLight2D` + occluder stack layered on top — exactly your existing system — so do not bake directional light, hearth glow, or colored dread into the sprites.
- **Treat stairs as an authored set-piece sprite, not a tiled floor.** This is the one genuinely hard problem in flat top-down; the standard solutions are (a) simplify to a single "stairs" tile/icon, or (b) draw a small perspective cheat at sprite-scale on its own layer (railings above the player) and slow the player while traversing.

## Key Findings

1. **Classic cozy interiors are small, single-screen, and symmetrical.** ALttP house interiors are roughly one screen (SNES internal resolution 256×224 px = ~16×14 tiles at 16px, ~8×7 at 32px; the playable interior is smaller once walls are subtracted). Link's house in ALttP is "square," with his bed at the top, three jars beside it, and a chest in the bottom-right corner — a textbook focal-point-plus-clutter layout. This is your model for `cottage_ground`.

2. **The camera-facing back wall is the signature top-down convention.** Pixel artists build "boxy rooms" from a wall-frame tileset: a 2–3-tile-tall back wall facing the camera, thin side walls, and a floor. RPG Maker's interior mapping convention is a back wall 2–3 tiles tall, consistent around the room. This reads as "enclosed" without breaking the flat-ish top-down view.

3. **Cozy vs. abandoned is a concrete, invertible checklist.** Warm = warm palette (browns, ambers, reds), symmetry, intact furniture, hearth/stove as focal anchor, rugs as secondary anchors, plants, family objects, tidy clutter. Abandoned = desaturated cold palette (greys, sickly greens, cold blue), broken/overturned furniture, dust sheets, cobwebs, gaps in floorboards, peeling walls, asymmetry, sparse emptiness, and a single "wrong" detail. Horror-design scholarship (Dr. Andrew Wedgbury, "The Architecture of Fear," drwedge.uk, 7 Feb 2025) identifies the "single chair in an empty room" / "absence where something should be" as a primary dread trigger.

4. **Your Godot lighting stack is the industry-standard approach for layering dread on flat art.** `CanvasModulate` darkens/tints the whole scene to a base ambient color; `PointLight2D` with a radial `GradientTexture2D` adds light pools; wall tiles get occlusion polygons; shadow filter set to "None (Fast)" preserves crisp pixels. Per-floor `dread_baseline` maps cleanly onto the `CanvasModulate` color/darkness and light energy.

5. **A "complete" small interior pack runs ~39 furniture + ~64 small décor + structural tiles** as a benchmark ceiling — but you can ship each scene with far fewer hero props if you cluster them well.

## Details

### A) Reference interiors in specific games

**The Legend of Zelda: A Link to the Past (SNES)** *[verified 2026-06-14]*
- House/cottage interiors are **single-screen** (no scrolling); the SNES internal resolution is **256×224 px** (~16×14 tiles at 16px, ~8×7 at 32px). Source: SNES specs (Wikibooks "Super NES Programming/SNES Specs"; Mega Cat Studios; SNESdev wiki).
- Link's house composition, per Zelda Dungeon Wiki (verbatim): *"Link's house is square and located just south of the Hyrule Castle. In the bottom-right corner, there is a treasure chest containing the Lantern, and at the top beside his bed are three jars containing Recovery Hearts."* This is the canonical cozy layout: one focal furniture group (bed) + interactable corners (chest, pots).
- **Correction / caution on basements:** the often-quoted line *"so dark that it may require the Lantern… and a large mirror"* actually describes **Twilight Princess'** Link's-house basement on Zelda Wiki, **not** ALttP. In ALttP the Lantern is in the ground-floor chest. Nevertheless, the *principle* — that a cellar register deliberately drops light level and may need a lantern — is well attested across the series and is the right instinct for `cottage_basement`. Treat the "dark cellar" convention as **[verified principle]**, the specific ALttP basement detail as **corrected/unsupported**.
- Reliability: house composition and contents are **[verified]** from Zelda Dungeon Wiki; exact pixel dimensions of a given room are inferred from screen resolution, so treat tile counts as **approximate**.

**Terranigma (SNES, 1995, Quintet/Enix)** *[verified 2026-06-14]*
- Uses a **"semi-overhead"/slightly-perspective top-down** view (Infinity Retro review; Wikipedia). Town-house interiors (Crysta elder's house, Loire, Louran) are multi-room and multi-floor, connected by stairs and — notably — **chimneys used as passages between floors** (GameFAQs walkthroughs).
- **Louran is the standout abandoned/eerie reference:** a town that initially "doesn't look like a destroyed town at all," then becomes a **zombie town** — Ark notes "something smells like rotten meat" — and houses that "look more like a jail" inside. The horror is signaled by *recontextualization* (a place you knew turns wrong), which is exactly your `recontext` node concept.
- Reliability: atmosphere and structure **[verified]** from walkthroughs/reviews; specific tile/palette values not documented in accessible sources — flag as **uncertain**.

**Secret of Mana / Trials of Mana (SoM/SD3, SNES)** *[verified 2026-06-14]*
- Pastel, bright, colorful palettes; town houses are mostly **decorative single rooms** with limited interactivity (Super Adventures in Gaming notes most houses can't be meaningfully interacted with; the elder's house with a basement chest is an exception). Sprite-to-building scale is intentionally large so interiors feel compact. Confirms the convention: **make the interior smaller than the implied exterior and keep it readable.**
- Reliability: **[verified]** for palette/feel; specifics secondhand.

**EarthBound/Mother, Link's Awakening, Oracle games** — well-established cozy references **[training knowledge]**: small single rooms, warm palettes, a focal bed/table, and tidy prop clutter. EarthBound is repeatedly cited (Pixel Logic) as a touchstone for warm, readable sprite/line work.

**Abandoned/creepy top-down references:** Pixel-art survival-horror (Lone Survivor, Holstin, SIGNALIS) signals dereliction through **low-res grime, desaturation, minimal lighting, and "the player's mind fills in the blanks"** (GameRant; Steam reviews). The gold-standard tableau example is documented in **Don Carson's "Environmental Storytelling: Creating Immersive 3D Worlds Using Lessons Learned from the Theme Park Industry"** (Gamasutra/Game Developer, 1 March 2000; Carson was a Senior Show Designer at Walt Disney Imagineering): a single frozen scene — a sagging bed, a small skeleton reaching toward a boarded-up window, a glove and bat below, a faded signed baseball on the sill — tells an entire story with no words. This is the canonical "the last moments of someone who lived here" device.

### B) Layout / composition principles for top-down interiors

- **Room size in tiles.** No source gives a hard "minimum," but synthesized from RPG Maker conventions, a stated LimeZu example, and SNES screen math:
  - **Minimum cozy single room:** ~**8×6 tiles** of interior floor (enough for one furniture grouping). *[inference]*
  - **Comfortable small house room:** ~**10×8 to 12×10 tiles**, allowing realistic stairs (which "take up quite a bit of space") and 2–3 furniture clusters. *[inference]*
  - **Large benchmark:** ~**24×14 tiles** (LimeZu "Modern Interiors" creator example, at 16px) is on the big end. *[verified 2026-06-14]*
  - **Back wall height: 2–3 tiles**, consistent around the room (RPG Maker "Tutorial – Mapping: Interior"). *[verified 2026-06-14]*
- **Readability:** Establish ONE focal point (hearth/stove, or a bed), use **negative space** so the focal point breathes, group furniture into clusters along walls, keep central floor open for movement, and place the **entrance and stairs on opposite or adjacent edges** so sightlines aren't blocked. The RPG Maker tutorial explicitly warns to move stairs "into the room so the person going up would not end up in a wall logically."
- **Walls:** Build from a wall-frame tileset (back wall + side walls + corner pieces). Slynyrd (Raymond Schlitter): "A good variety of boxy shaped rooms can be made with the above wall frame tiles." Keep walls thin (1 tile) on sides, with the camera-facing wall 2–3 tiles tall. Frame doorways explicitly (door frame + door on a layer above the wall).
- **Floors:** Use a base repeating tile that "loops well on all four sides" (Slynyrd PB20/43); add **at least one variant** (a cracked/discolored tile) per heavily-used texture "to valiantly fight off visual fatigue." Use borders/edging where floor meets wall. **Rugs are focal anchors** — Slynyrd designs them from antique-rug references, freely throwing down shapes until a pattern emerges.
- **Furniture as 32×32 map objects:** Design each prop within the tile grid so it "meshes with the environment and can efficiently be broken into tiles" (Slynyrd). Core vocabulary: bed, table, chairs/stools, hearth/stove, countertop, shelves, wardrobe, barrels, crates, chest, cradle, rug, plus small clutter (pots, books, plants, candles).

### C) Cozy/tended vs. abandoned/eerie — the visual grammar

**Warm, lived-in, safe (cottage_ground):**
- Warm palette: ambers, warm browns, soft reds, cream. Warm colors "feel close, energetic, emotional" (Pixune color theory).
- Symmetry and intact, upright furniture.
- A **hearth/stove as the primary focal anchor** with a warm light pool (created at runtime by your PointLight2D, NOT baked).
- Rugs, plants, family objects (portraits, cradle), tidy clutter (stacked dishes, books).

**Hollow, abandoned, wrong (hollow_house):**
- Desaturated, cold palette: greys, sickly/olive greens, cold blues. Horror games "strip environments of vibrancy to foster isolation and dread" (Silent Hill 2 cited repeatedly; Dr. Wedge; PekoeBlaze).
- Broken/overturned furniture, **dust sheets over furniture, cobwebs, gaps in floorboards, peeling/water-stained walls.**
- **Asymmetry** and **sparse emptiness** — and crucially **a single wrong detail** or **an absence where something should be**. Per Dr. Andrew Wedgbury, "The Architecture of Fear" (verbatim): *"A single chair in the centre of an empty room, for example, suggests recent occupation, encouraging us to ask questions of ourselves about who sat there, where they went and when they may return."* (drawing on Benson-Allott 2015 and Frers 2013). This is the highest-leverage horror device and maps directly to your `recontext` node.
- Harsh shadow shapes (runtime), cold thin light from a single source (a broken window).

**The middle register (cottage_basement):**
- Still part of the safe home, so keep the **warm material palette and intact, tended objects** (neat shelves, labeled barrels, stored preserves) — but **lower the light** (raised dread ~45), introduce **stone/cold materials**, longer shadows, and **a few unexplained shadows or a single slightly-off object.** It is "tended but tense": the *content* is safe and orderly, the *lighting and material register* are darker. This is the deliberate gradient between the warm ground floor and the fully-wrong hollow house. The series-wide "lantern-dark cellar" convention is the precedent.

### D) Pixel-art production specifics for your pipeline

- **Author flat/neutral baked lighting.** Yes, real pixel artists and the modern Godot 2D-lighting workflow do exactly this: paint the tiles/props with even, neutral ambient shading (a consistent soft top-light at most), then layer mood with engine lighting. Godot's own docs and Catlike Coding's "True Top-Down 2D" tutorial set unlit/`CanvasModulate` ambient (`24293b` dark-blue example) + `PointLight2D` + occluders; the itch.io color-palette guide explicitly advises "instead of coloring every object vividly, let your lighting setup enhance your scene." **Do NOT bake hearth glow, colored dread tint, or strong directional shadows into sprites** — they'll fight your runtime `CanvasModulate`/`PointLight2D` per-floor dread tint.
- **Design true top-down tiles** (not 3/4 or iso). Note: Slynyrd's tutorial calls its own register a **"3/4 top down projection"** — your "low top-down / cheated-oblique" is the same family: a slightly-visible front face on tall objects (walls, furniture) but a flat floor plane. Keep the cheat small and consistent.
- **Stairs are the hard problem.** Slynyrd (Raymond Schlitter, "Pixelblog 35 – Top Down Interiors," 30 Nov 2021), verbatim: *"Often stairways are simplified to a single tile in top down games of this style. This is for the flexibility of level design at the sacrifice of visual accuracy. For my stairs I take a fairly realistic approach, creating stairways in proportion to the character sprites and wall height. While it looks cool, they take up quite a bit of space and are limited in orientation."* And: *"The railing tiles will need to go on a separate layer above the stair tiles."* Classic games solved it by treating stairs as an **authored set-piece sprite** with a built-in perspective cheat, placed on its own layer, with the player drawn behind the railing. Michael Bitzos's devblog adds a gameplay tip: **slow the player on stairs** to sell the depth the camera can't show. **Recommendation: author each staircase as a single hand-made oblique sprite/set-piece (not tiled), on a layer above the player, and slow movement on it.**
- **Asset checklist (realistic benchmark).** Penzilla's "Top-Down Retro Interior (Pixel Art)" itch.io page states its contents exactly (verbatim, *[verified 2026-06-14]*): *"39 pieces of furniture, made with several directions and states. 64 small decor items. 4 types of floors and wallpapers. staircase, Windows, and doors, with several variations."* (16×16px grid.) The 32×32 Pixels-by-Skab pack covers "living rooms, kitchen, dining rooms, bedrooms and bathrooms… sofas, couches, armchairs, coffee tables, wardrobes, cupboards, kitchen tops, appliances, beds." You do NOT need this many — but ~39 furniture + ~64 décor is the realistic ceiling for a fully-stocked interior library.

## Recommendations

### Stage 1 — Shared tileset + lighting contract (do first)
Author ONE neutral 32×32 interior tileset and prop library, flat-lit, palette-locked. Build the shared wall-frame kit: camera-facing back wall (2–3 tiles tall), thin side walls, corners, doorway frame, floor base + 1–2 variants + edging. Confirm the Godot stack: `CanvasModulate` (per-floor color/darkness keyed to `dread_baseline`), `PointLight2D` (radial gradient, shadow filter None/Fast), wall occlusion polygons. **Benchmark that changes the plan:** if crisp pixels break under shadows, keep filter None; if dread tint muddies warm props, lighten `CanvasModulate` alpha rather than re-painting sprites.

### Stage 2 — Author the three scenes

**1. `cottage_ground` — tended, safe, warm (dread decays here)**
- **Size:** ~10×8 tiles interior floor. Back wall 3 tiles tall.
- **Layout:** Exit door bottom-center (to village). **Hearth/stove on the back wall = focal point**, warm runtime light pool in front of it. Marta's NPC spot beside the hearth or at a table cluster (back-left). Table + 2 stools center-left as a secondary cluster. Stairs-down set-piece in a back corner (e.g., back-right), framed and on its own layer. Recontext sign node near the entrance. Rug under the table as a secondary anchor. Clutter: pots, plants, a cradle/family object, shelves with preserves.
- **Palette/mood:** Warm browns/ambers/cream, soft reds. Symmetry, intact furniture, tidy.
- **Prop checklist (hero set, ~12–16):** stove/hearth, table, 2 stools, bed, wardrobe or shelf, cradle, rug, 2–3 pots, plant, portrait, barrel, door, stairs set-piece.

**2. `cottage_basement` — tended but tense (middle register, ~45 dread)**
- **Size:** ~8×6 tiles, lower ceiling feel; stone floor/walls. Stairs-up set-piece in a corner.
- **Layout:** Stairs-up back corner. **Orderly storage along walls** — labeled barrels, crates, shelves of preserves (tended). Central floor open. Place **one slightly-off detail** (a single overturned crate, a shadow with no caster, a child's toy where it shouldn't be) to seed unease without breaking "safe home."
- **Palette/mood:** Same warm *material* palette as upstairs (it's still home) but **darker via CanvasModulate**, cool stone greys creeping in, longer shadows, a single dim ambient `PointLight2D`. Use your existing occluder walls for shadow drama.
- **Prop checklist (~8–10):** stairs set-piece, 3–4 barrels/crates, shelf unit, preserve jars, lantern/candle (light source), one "wrong" object.

**3. `hollow_house` — abandoned, eerie, dread**
- **Size:** ~10×8 to 12×10 tiles (slightly bigger feels emptier). Single floor, exit only.
- **Layout:** Deliberately **asymmetric**. Mostly **empty negative space**. Broken/overturned furniture against walls; a **dust-sheeted shape** in one corner; cobwebs in corners; **a gap in the floorboards**; peeling/stained back wall. The **single wrong detail / absence**: e.g., a perfectly-set table with one chair pulled out in an otherwise destroyed room, or a clean rectangle on a dusty floor where furniture used to be (Carson's "frozen tableau" / Wedge's "recent occupation"). Cold thin light from a single broken window (runtime). Recontext node central.
- **Palette/mood:** Desaturated — greys, sickly green, cold blue. High value-contrast for harsh shadows. Dread baseline high; `CanvasModulate` toward cold/dark.
- **Prop checklist (~10–14):** broken table, overturned chair(s), dust-sheet shape, cobweb overlays, broken-floorboard tile(s), peeling-wall variant, broken window (light source), debris/clutter, the single "wrong" tableau object, door.

### Stage 3 — Validate against your filters
- **Story filter:** Each scene's "wrong detail" should pay off narratively via the recontext node — don't add dread props that mean nothing.
- **Horror filter:** Reserve the strongest single-wrong-detail device for `hollow_house`; keep `cottage_basement` to ONE subtle off-note so the gradient reads.
- **Companion filter:** Ensure Marta's NPC spot in `cottage_ground` has clear sightlines and isn't occluded by tall furniture or the camera-facing wall.
- **Replay filter:** Because dread decays in the cottage, ensure the warm-state art reads as definitively "safe" on a second visit — the contrast with the hollow house is the point.

## Caveats
- **Tile-size mismatch in the best tutorial:** Slynyrd's "Pixelblog 35 – Top Down Interiors" (the single best transferable source) uses **16×16 px tiles in a 3/4 top-down projection with the "Mondo" palette — not 32×32**. Principles transfer directly; pixel-detail density and exact prop dimensions do not. Re-derive prop sizes for your 32×32 grid. The true 32×32 reference is the Pixels-by-Skab pack.
- **Room dimensions are inferred, not sourced.** No tutorial states a hard "minimum interior size." The 8×6 / 10×8 / 12×10 tile recommendations are reasoned inference from RPG Maker conventions, a single LimeZu "24×13.5 tiles" example *[verified]*, and SNES screen math. Prototype and adjust to your camera zoom.
- **One ALttP detail was corrected:** the widely-quoted "dark basement with a large mirror needing the Lantern" is **Twilight Princess**, not A Link to the Past. The cozy ground-floor layout (square room, bed + 3 jars at top, chest bottom-right) IS verified ALttP.
- **Terranigma and SoM specifics are secondhand.** Atmosphere and structure (chimney passages, Louran's zombie-town reveal) are **[verified]** from walkthroughs/reviews; exact palettes and tile dimensions are not documented in accessible sources — treat as directional, not precise.
- **Pinterest/AI-image and asset-store marketing were excluded** as unreliable; counts and quotes here come from creator-stated pack descriptions, established pixel-art tutorials (Slynyrd, Pixel Logic), the Godot docs/Catlike Coding, and named game-design writeups (Don Carson; Dr. Andrew Wedgbury; Michael Bitzos).
- **The "single wrong detail" principle** is drawn from horror-studies and film scholarship (Wedge citing Benson-Allott 2015, Frers 2013) applied to games — well-supported theory, but playtest whether it reads at 32×32, where subtlety is hard.