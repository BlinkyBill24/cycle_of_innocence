# Grok Imagine prompts — Cycle of Innocence

> **M0 batch generated 2026-06-10** (grok-imagine-image-quality, 2k): all six reference images in `assets/reference/` — protagonist, Briar pup, Twisted Child, playground tileset, fringes tileset, HUD icons. Next pipeline step: human Aseprite cleanup/downscale, then animation sheets via image_edit on approved bibles. Note: the fringes tileset needed a softer rewording (twilight framing) — the original dark phrasing tripped output moderation twice; revised prompt below replaces the old one in practice. **Backgrounds: solid magenta #FF00FF (chroma-keyed by tools/pixelize.py) — never "transparent" (AI paints fake checkerboards, no real alpha; switched 2026-06-10 after keying artifacts).**

**Locked style**: retro pixel art, top-down, 32×32 per frame / reference grid, limited 24–32 color palette, SNES/Zelda + creeping horror atmosphere, transparent bg, crisp pixels, no anti-aliasing.

## Protagonist (Child — escaped sacrifice, ~8–10, revised ritual)
**Bible (updated for playground ritual with lottery/harmony score, creepy clowns/stuffed animals/toys, villagers believe "successful")**

```
retro pixel art top-down 32x32 character reference sheet, SNES Zelda style with horror atmosphere, small child ~8-10 selected via village lottery or Community Harmony Score (parents' contributions), escaped the ritual at the village playground (safe happy place with colorful but off decorations), wide innocent yet haunted eyes, simple rough tunic with ritual tear marks from creepy clown/stuffed toy "guardians", bare feet, 4–8 views (front back left right + 3/4 angles, one with toy in hand), A-pose + slight defensive posture after fleeing into fog, limited 24-color palette with desaturated rural tones + one wrong red accent for the "marked" feeling, palette swatches bottom row, solid magenta #FF00FF background (chroma-key), crisp pixels no anti-aliasing
```

Save as: `assets/reference/protagonist_child_bible.png` (revise for playground context)

## First Animal Companion (Dog / Hound pup — escaped with player, revised)
**Bible (updated for playground "lesser offering", villager unawareness of escape, escalation creating more monsters)**

```
retro pixel art top-down 32x32 animal companion reference sheet, SNES Zelda style horror-tinged, small terrified dog/wolf pup brought as lesser offering at village playground ritual (creepy clowns/stuffed toys), big fearful eyes, scruffy fur, one ear torn, ritual nick on flank from toy "guardians", loyal but scared posture next to escaped child, 2x2 or 4-view grid (front/side + action hints like digging), growth note space for adult version (brave protector or corrupted), limited 20-color palette (earthy browns + one warm bond glow), palette swatches, solid magenta #FF00FF background (chroma-key), crisp pixels no anti-aliasing
```

Save as: `assets/reference/companion_dog_pup_bible.png` (revise for playground context)

## Later variants (to generate after first slice)
- Protagonist teen + adult versions (same character bible evolution + taller silhouette + outfit reflecting morality choices: innocent bright vs pragmatic cloak vs ruthless scars/marks).
- Dog adult + corrupted versions (larger, more powerful stance; corrupted: glowing eyes, exposed "veins" or shadow tendrils, hunched aggressive).
- Bird companion bible (scout/raptor — smaller, flight poses in grid).
- Horse/foal bible (mount — larger silhouette, calm vs panicked).

Use `image_edit` on the bibles for variations (different morality tints, specific action frames) before full sheet generation.

## M0 batch additions (slice roadmap, 2026-06-10)

### A3a — Playground-at-dusk tileset
```
retro pixel art top-down 32x32 tileset reference sheet, SNES Zelda style with creeping horror, village playground at dusk after a ritual: swing set, slide, merry-go-round, sandbox, scattered oversized stitched stuffed animals and porcelain-faced toys posed slightly wrong, faded bunting and lottery posters, trampled grass paths, low fog patches, ground tiles + edge transitions + decor objects organized in grid, limited 28-color palette (warm dusk orange fading to sick green-grey, one wrong red accent), solid magenta #FF00FF background (chroma-key), crisp pixels no anti-aliasing
```
Save as: `assets/reference/tileset_playground_dusk.png`

### A3b — Fringes forest tileset
```
retro pixel art top-down 32x32 tileset reference sheet, SNES Zelda style horror-tinged, forest fringe at the edge of a village: twisted trees, root tangles, dirt paths, hiding hollows under roots, diggable soft-earth patches (marked subtly), fog banks, distant village fence pieces, ground + transition + decor tiles in grid, limited 24-color palette (cold greens/browns, moonlit highlights), solid magenta #FF00FF background (chroma-key), crisp pixels no anti-aliasing
```
Save as: `assets/reference/tileset_fringes_forest.png`

### A4 — "Twisted Child" monster (first former-sacrifice)
```
retro pixel art top-down 32x32 creature reference sheet, SNES Zelda style horror, small humanoid monster that was once a sacrificed child: hunched, wrong-jointed limbs, face hidden, still wearing a faded clown ruff and dragging one broken toy by a string, more sad than gory, subtle body horror (too-long fingers, faint glow under skin), 4 views + idle/stalk/lunge pose hints, growth note space for "Stilled" calm variant (head tilted, toy hugged), limited 20-color palette (greys, faded carnival colors, one wrong red), solid magenta #FF00FF background (chroma-key), crisp pixels no anti-aliasing
```
Save as: `assets/reference/monster_twisted_child_bible.png`

### A5 — Minimal HUD + touch icons
```
retro pixel art UI icon sheet, 16x16 and 24x24 elements, SNES-style with subtle horror edge: small heart containers (whole/half/empty, slightly hand-stitched look), interact prompt hand icon, hold-to-soothe musical note icon, dig paw icon, touch virtual stick base + nub, simple dialogue arrow, limited 16-color palette matching desaturated rural tones, solid magenta #FF00FF background (chroma-key), crisp pixels no anti-aliasing
```
Save as: `assets/reference/ui_hud_icons.png`

## Full animation sheets (after bible approval)
Use image_edit referencing the bible + exact grid layout (document in sheet_layout.txt).

Example for child protagonist 4-dir locomotion + attack/hurt:
```
retro pixel art top-down RPG sprite sheet, same escaped child from reference image, organized 8 column X row grid 32x32 per frame, row layouts for idle/walk/attack/hurt per direction, transparent background crisp pixels no anti-aliasing limited palette SNES game asset with subtle horror edge
```

Post-process in Aseprite (grid snap, palette reduce, anim timing for age weight shift and companion personality).


## PixelLab redesign pass (2026-06-11)

Character redesign via `create-character-pro` (`method=create_from_concept`):
- **concept_image**: keyed character crop from the Grok bible (full pages leak parchment/annotation blocks into the generation — probe #1 failed on this)
- **reference_image**: one clean 296px cell from the Grok pixel sheets, despilled, BOX-downscaled to native 32, NEAREST-upscaled to 128 (crisp style signal under the 168px API cap)
- `no_background: true` + style_description "single isolated character sprite, fully transparent background, no backdrop, no ground tile, no kennel, no box behind the dog" — the dog template repeatedly painted a backdrop box without the explicit negative
- 8 directions, 32px frames (stored on a 60px canvas for animation room), ~$0.095 per create
- Twisted has no clean Grok sheet — Rowan's style cell carries the rendering style; the bible + description carry the design

New animations this pass (beyond regenerating the old set): Briar `growl` (4-dir, quirk pings), `lie_down` (soothe calm-anchor), `head_bump` (softened stare / hideout play), `sit`; TwistedChild `hurt`, `crumble` (dominated death).

## Quirk-visual gap fill (2026-06-11, branch feature/anim-gap-fill)

Two Briar animations the quirk system expressed only via SFX/sit until now
(`animate-character`, `mode=v3`, frame_count 4, character 372cf8d9):
- `stare` (4-dir, loop 3fps) — long-stare corruption quirk, replaces the sit
  fallback during the beat-too-long stare: "standing rigidly still, frozen
  mid-step, head raised, unblinking fixed stare straight ahead"
- `dusk_press` (east, once 6fps) — bond quirk at dusk/night, falls back to
  head_bump if missing: "leaning its whole body sideways against a person's
  leg, pressing close for comfort, tail low"

## Village life batch (2026-06-11, branch feature/village-art-bibles)

Humans for village-life.md (grok-imagine-image-quality, 2k, magenta chroma-key).
Moderation notes: "horror undertone" + child in one prompt → rejected; child
sheet reworded fully wholesome (the horror is contextual, not in the sprite).
The mood scene tripped OUTPUT moderation twice even with benign wording —
third phrasing ("cozy... sunset... festival") passed.

### B1 — Farmer parent (base villager, palette-swap archetype)
```
retro pixel art top-down 32x32 character reference sheet, SNES Zelda style with creeping horror undertone, adult villager farmer parent in their 30s, plain rural work clothes with apron and rolled sleeves, tired kind face that never asks questions, posture of someone who chose not to see, 4-8 views (front back left right + 3/4 angles), A-pose + one carrying-basket pose + one hands-clasped celebration pose, limited 24-color palette desaturated rural earth tones with one cheerful festival ribbon accent that feels slightly wrong, palette swatches bottom row, note space for male and female variant heads, solid magenta #FF00FF background (chroma-key), crisp pixels no anti-aliasing
```
Save as: `assets/reference/villager_parent_bible.png`

### B2 — Warden (stage-2 patrol figure)
```
retro pixel art top-down 32x32 character reference sheet, SNES Zelda style horror-tinged, village Warden patrol figure, heavyset adult in long oilskin coat and wide-brim hat, carved wooden lantern pole with a small bell, stitched festival armband with cheerful colors gone grimy, face half-shadowed under the hat, silhouette must read instantly as someone to avoid, 4-8 views (front back left right + 3/4 angles), standing watch pose + walking patrol pose + raised-lantern searching pose, limited 24-color palette cold slate blues and oilskin browns with one sickly festival-yellow armband accent, palette swatches bottom row, solid magenta #FF00FF background (chroma-key), crisp pixels no anti-aliasing
```
Save as: `assets/reference/villager_warden_bible.png`

### B3 — Elder / Harmony-lottery priest
```
retro pixel art top-down 32x32 character reference sheet, SNES Zelda style with quiet horror, village Elder priest of the Harmony lottery, gentle grandfatherly figure in layered rural vestments with small stitched stuffed-animal charms hanging from the sash, kind open-armed posture that looks trustworthy but reads wrong in hindsight, ceremonial wooden clapper instead of a bell, 4-8 views (front back left right + 3/4 angles), blessing pose + leaning-on-staff pose, limited 24-color palette warm parchment and faded festival colors with one deep ritual red accent, palette swatches bottom row, solid magenta #FF00FF background (chroma-key), crisp pixels no anti-aliasing
```
Save as: `assets/reference/villager_elder_bible.png`

### B4 — Village child (still allowed to play)
```
retro pixel art top-down 32x32 character reference sheet, cozy SNES Zelda style, cheerful village child around 8 years old, patched bright rural clothes, small stuffed toy bunny held by one arm, carefree run pose + sitting-on-bench pose + waving pose, 4-6 views (front back left right), limited 20-color palette bright and warm, one festival ribbon in hair, palette swatches bottom row, solid magenta #FF00FF background (chroma-key), crisp pixels no anti-aliasing
```
Save as: `assets/reference/villager_child_bible.png`

### B5 — Village establishing mood (palette/architecture anchor for the zone)
```
retro pixel art game scene, top-down wide view of a cozy rural village green at sunset, SNES RPG style, half-timbered cottages with thatched roofs, a little chapel with bell tower, colorful festival bunting and glowing paper lanterns between the houses, village well and market stalls on the green, warm golden window lights, soft blue evening sky, a small playground with swings visible at the village edge, limited 32-color palette, crisp pixels no anti-aliasing
```
Save as: `assets/reference/village_dusk_mood.png` (16:9 — scene, no chroma-key)

## Village look reference (user-provided, 2026-06-11)

`assets/reference/village_tileset_ref_youmind.jpg` — cozy farming-village
asset sheet (warm saturated palette, soft outlines, front-facing cottages,
dirt paths — NO cobble). Drove two decisions:
- Village paths/yards are all packed DIRT (village_yard tileset); the
  cobble set is shelved for interiors/plazas (its transition rendered as a
  raised curb — create-tileset models transitions as elevation, see
  transition_size="height" in their docs).
- Future clutter pass (barrels, crates, cart, signpost, flowers, hay) can
  anchor on crops of this sheet via generate-with-style-v2 (style_images)
  or create-image-bitforge (style_image) — the tileset endpoint's reference
  params 500 server-side, but the image endpoints' style refs work.

## Prop authoring rules (2026-06-12 — full plan: [[art/prop-coherence]])

Every prop prompt from here on inherits these three rules:

1. **Flat neutral light, no cast shadows** — CanvasModulate + lights own
   time-of-day; baked light makes a prop wrong in every other scene.
2. **Palette hard-lock** — quantize the result to the target zone backdrop's
   48-color palette before import (never ship a prop on its own palette).
3. **Scale chart** — player = 32 px reference; door ≈ 1.3× player
   (research-pinned). Lamp ≈ 1.5×, fence ≈ 0.6×, well ≈ 1.2× player are
   PROVISIONAL — confirm against the editor placement pass, then pin. State
   the target size in the prompt AND verify against a backdrop crop before
   placement.

New props go through `create_map_object` with a zone-backdrop crop as
`background_image` (gated on smoke test) or the proven
`generate-with-style-v2` fallback — see [[art/prop-coherence]] workflow.

## Projection canon templates (2026-06-12 — rule 5 in [[art/prop-coherence]])

One camera everywhere: **low top-down (~20°), "Zelda perspective"** (tops AND
front faces visible, verticals vertical, no vanishing points). Defaults are
never trusted — `view` is always explicit.

**A. Grok ground repaint (production backdrops — the only standing Grok
pipeline):**
> top-down plan view of ground surface only; uniform texture scale across the
> whole image; no objects, no walls, no horizon, no shadows, no perspective;
> keep the layout exactly as given.

**B. Grok full scene (concept bibles / reference art ONLY — never production
backdrops):**
> angled top-down Zelda perspective (slightly elevated 3/4 view as in A Link
> to the Past / Terranigma), consistent foreshortening on every object, tops
> and front faces visible, verticals stay vertical, no linear perspective, no
> horizon, flat neutral light.

**C. `create_map_object` prop call (canonical):**
`view="low top-down"` (code-enforced canon) + `background_image=<zone
backdrop crop>` + description:
> <prop>, transparent background, same angled top-down view, foreshortening
> and proportions as the background reference; tops and front face visible;
> flat neutral light, no cast shadows, no baked time-of-day light; scale per
> the 32 px player chart.

Palette note: "inherit the palette" in a prompt is steering at best — the
palette GUARANTEE is the rule-1 quantize post-pass (`tools/palette_lock.py`),
never the prompt.

**Pinned canon references** (2026-06-12, for style/depth refs and the QA
eyeball gate):
- `assets/reference/canon_view_character.png` — approved Rowan south idle
  cell (48px, from the live sheet): the canon eye-height for characters.
- `assets/reference/canon_view_prop.png` — the canon well (low top-down,
  palette-locked): flat ~1:3 rim ellipse, front face visible, verticals
  vertical. Use as `background_image`/depth reference or comparison anchor.

Ratio-glance audit of legacy height-cue assets (2026-06-12): terrace/cliff
tileset PASS (straight-on fronts under plan tops), chapel roof PASS
(front-gable facade, no deep roof plane) — the pre-explicit-view tileset era
needs no depth-i2i rework.

## Playground props rework v2 (2026-06-13 — perspective/scale regen)

User feedback: playground props (minus trees) read with **off perspective +
wrong scale** — the legacy set was made via description-only pixflux where
`view` only weakly controls, so the slide came out isometric and the
roundabout ellipse too round. Regenerated all six at canon **low top-down**
via `create_map_object` + a placement-spot crop of `playground_ground_backdrop.png`
(world→backdrop px = `x+704, y+416`), oval inpainting, trim → `palette_lock.py`
→ gate. Staged in `assets/sprites/props/candidates/*_v2.png` for the editor
placement pass (sizes changed → colliders/offsets are an editor judgment).

- **swing_set** (crop 128×112, oval 0.8): "rusty playground swing set, metal
  A-frame legs, two hanging chain swings, one seat broken and dangling from a
  single chain, faded peeling red paint, low top-down ~20 degree angle, upright
  legs stay vertical, ground footprint slightly foreshortened, post-ritual horror edge"
- **slide** (crop 88×88, oval 0.78): "small old playground slide, faded blue
  metal, rusted ladder with vertical uprights, slide ramp descending, seen from
  a low top-down ~20 degree angle, slightly leaning, post-ritual horror edge"
- **roundabout** (re-roll, wide-short crop 96×52, oval 0.9 — iconic round
  prior): "rusted playground merry-go-round roundabout seen nearly edge-on from
  a low ~20 degree angle: the circular metal platform is a very shallow flat
  ellipse, its width roughly three times its visible front-to-back depth, a
  short central pole with bent handlebars, faded peeling paint, no tall ring"
  *(first roll at 104×80 came back ~0.74 ratio = too round; the wide-short
  crop + thrice-the-depth wording busted the prior to ~0.58)*
- **totem_bear** (re-roll, narrow crop 48×72, oval 0.88): "hand-stitched teddy
  bear lashed upright to a thin wooden stake driven into bare ground, crude
  thick stitches, mismatched button eyes, slightly leaning, no grass, low
  top-down ~20 degree view, stake stays vertical" *(first roll baked a grass
  base — rule-2 violation; "no grass" trimmed it to a small tuft)*
- **totem_rabbit** (crop 56×84, oval 0.85): "hand-stitched rabbit doll nailed
  to a wooden pole driven into the ground, long ears sagging, crude patchwork
  fabric, one button eye missing, low top-down ~20 degree view, pole stays vertical"
- **toy_duck** (basic mode, NO backdrop crop — **saturation exemption, rule 1**):
  "small abandoned wooden duck pull toy on a flat wheeled base with a frayed
  pull string, vivid saturated yellow paint with an orange beak, low top-down
  ~20 degree view, slight ground foreshortening" — NOT palette-locked; stays
  the lone saturated toy while the world drains.

## Inventory item icons (2026-06-13 — branch feature/inventory-item-art)

First inventory item ICONS. These are **UI sprites, not world props**, so they
break from the world-prop pipeline deliberately: generated via PixelLab
`create_map_object` **basic mode** (no background → real alpha, no magenta key),
48×48, mostly `view="side"` (iconographic — a clear profile reads better in a
satchel slot than a low-top-down floor view). **Not palette-locked** to a zone
backdrop — items should read clearly in the panel (same spirit as the toy_duck
saturation exemption). Params: `single color outline`, `basic shading`,
`medium detail`. Pipeline: generate → trim to bbox → import nearest-filter →
referenced as `ItemDef.icon` in `resources/items/<id>.tres`. Tool:
`tools/gen_item_icons.py` (⚠️ PixelLab 429s if all 7 fire back-to-back — space
submissions or batch ≤5). Saved to `assets/sprites/items/<id>.png`.

- **dried_meat** (side): "a strip of dried cured jerky meat, frayed dark red-brown edges, single food item"
- **forest_berries** (side): "a small cluster of dark wild forest berries on a short sprig with two leaves, deep purple-red"
- **sturdy_stick** (side): "a stout broken tree branch used as a makeshift club, rough bark, one splintered end, brown"
- **slingshot** (side): "a Y-shaped hand-whittled wooden slingshot with a stretched leather band, a child's makeshift weapon"
- **sling_stones** (high top-down): "a small pile of three smooth rounded grey throwing pebbles"
- **buried_bone** (side): "an old weathered dug-up animal bone caked with dark soil, gnawed, off-white"
- **tin_locket** (side): "a small tarnished heart-shaped tin locket on a broken chain, caked with grave soil, a child's keepsake"

## FX & prop sprites via PixelLab (2026-06-13, worktree pixellab-fx-props)

Replaced primitive Polygon2D placeholders (campfire flames, dig markers, fog
seams) with real sprites. **FX palette exemption** (prop-coherence rule 1):
the campfire (emissive fire) and fog (translucent overlay) are NOT
palette-locked — like `toy_duck`, their saturation/transparency IS the point.
The static dig sprite IS palette-locked to the playground backdrop.

- **dig_spot** (static, `create_map_object`, low top-down, ground crop, palette-locked):
  "small patch of freshly dug dark earth, a shallow disturbed hole with loose
  soil and a few clods, tiny mound at the rim". → `assets/sprites/props/dig_spot.png`,
  replaces the hexagon Polygon2D marker in `diggable_spot.tscn` (all 3 dig spots).
- **campfire** (animated, `create_1_direction_object` 96px top-down → `animate_object` v3, 9 frames):
  "small campfire: ring of grey stones around two charred crossed logs with
  orange and yellow flames"; anim "flames flickering and dancing, embers
  pulsing, logs stay still". User picked object `a8ee2399` over the auto-pick.
  → `campfire_sheet.png` + `assets/resources/fx/campfire_frames.tres` (AnimatedSprite2D,
  ~10fps loop), replaces the Stones/Flames/FlameCore polygons (FireLight kept).
- **fog** (animated, `create_1_direction_object` 128px top-down → `animate_object` v3, 9 frames):
  "soft wispy patch of pale grey-green fog, translucent drifting mist"; anim
  "drifting and billowing, edges swirling". → `fog_sheet.png` +
  `fog_frames.tres` (AnimatedSprite2D ~6fps), replaces FogSeamNorth/South
  polygons (names kept so `dread_beat` NodePaths + modulate-fade still work).
