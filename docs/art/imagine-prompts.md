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
