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

## Bible concept-art batch 3 — protagonist stages, full companion sets, new monsters (2026-06-13, branch feature/bible-concept-art-batch3)

Grok Imagine (`grok-imagine-image-quality`, 2k, magenta `#FF00FF` chroma-key),
locked bible format (top-down reference sheet, multi-view, palette swatches,
limited palette, no AA). These are **concept bibles for human pixel-cleanup**,
not production sprites — next step is keyed crop → PixelLab `create_from_concept`
(see the 2026-06-11 PixelLab redesign note above) per character.

Moderation: all 15 passed first try. The two risky sheets (fetus-crawler,
ghost-girl) used the proven "more tragic/melancholy than gory" wording from the
twisted-child bible — the horror is in the *context*, not graphic content.
Transient note: the x.ai endpoint had a DNS blip on the first call (IPv6-only
resolution failed; IPv4 fine) — a plain retry fixed it.

Saved to `assets/reference/`. Briar **pup** already existed
(`companion_dog_pup_bible.png`) so only adult+corrupted were generated.

### Protagonist — late teen + adult (morality-neutral base; tint variants via image_edit later)
- `protagonist_teen_bible.png`: "...the same escaped protagonist now a lean teenager around 15-16, taller leggier silhouette, the same haunted watchful eyes grown harder and warier, weathered patched travel clothes layered over the remains of an old ritual-torn tunic, a makeshift wrap on one forearm, wrapped feet, hair longer and unkempt, 4-8 views..., A-pose plus a wary ready stance, limited 24-color palette desaturated rural tones with one wrong red accent..."
- `protagonist_adult_bible.png`: "...now a hardened adult in their early twenties, tall worn silhouette, gaunt resolute face carrying years of survival, layered scavenged traveler's cloak and gear over a scarred body, the old ritual scar still faintly visible, longer tied-back hair, ..., A-pose plus a grounded combat-ready stance, ... one wrong red accent..."

### Briar (hound) — adult + corrupted (pup already on disk)
- `companion_dog_adult_bible.png`: **Briar is a Belgian Malinois** (user spec 2026-06-13 — regenerated). "...the grown adult form of a loyal hound that is a Belgian Malinois, athletic lean muscled working dog, short fawn-tan coat with a distinct black mask and black-tipped sable overlay, dark erect pointed ears, the torn ear and old flank nick now healed scars, noble protective posture, 4-view grid (front/side plus a tracking sniff and a guard stance), limited 20-color palette fawn-tan and black with earthy browns and one warm bond glow..."
- `companion_dog_corrupted_bible.png`: "...the corrupted nightmare form of a once-loyal hound, matted patchy fur, glowing wrong-colored eyes, faint exposed 'veins' of dark Hunger-stuff glowing under the skin, hunched aggressive hackles-raised stance, more tragic than gory, ... one wrong red accent..."

### Echo (bird) — full set: egg → hatchling → adult → corrupted
- `companion_bird_egg_bible.png`: "...a single mysterious bird egg, pale speckled raptor egg with faint wrong markings, shown in a small nest of twigs with one scrap of faded ritual cloth, 3 views (whole egg, first hairline crack, egg in the nest), limited 16-color palette muted greys and bone-whites with one faint sickly accent..."
- `companion_bird_hatchling_bible.png`: "...a small ragged newly-hatched bird, scrawny raven or pale raptor chick, oversized eyes that look far too knowing, patchy down feathers, unsteady but sharp, 4-view grid (front/side plus hop and first-flutter), limited 18-color palette muted greys and charcoal with one pale highlight..."
- `companion_bird_adult_bible.png`: "...a sleek striking adult raven or pale raptor, glossy sharp feathers, an intelligent piercing eye, poised and a little cruel, flight poses, 4-view grid (perched front/side plus wings-spread glide and diving harass), limited 20-color palette deep blacks and charcoals with one cold bone-pale highlight..."
- `companion_bird_corrupted_bible.png`: "...feathers fallen out in mangy patches, too many or wrong-placed eyes, an unsettling extra detail, clutching a small grim trinket 'gift' in its claws, a ragged ominous flight pose, more wrong than gory, ... one wrong red accent..."

### Storm (mount) — full set: young/wary → adult/regal → corrupted pale-rider
- `companion_horse_young_bible.png`: "...a powerful but haunted horse, scarred and wary, old faded ritual 'ward' brands on its flank, ribs slightly showing, a flighty distrustful posture with ears pinned back, 4-view grid (front/side plus rearing-spook and balking), limited 22-color palette muted greys and duns with faint pale brand-scar marks..."
- `companion_horse_adult_bible.png`: "...now strong and almost regal after good care, glossy coat, calm steady powerful stance, small protective braids and hand-made tokens woven into mane and tail, healed brands, 4-view grid (front/side plus canter and steady-guard), limited 22-color palette warm duns and greys with one warm bond accent in the braids..."
- `companion_horse_corrupted_bible.png`: "...emaciated in places, milky or faintly burning eyes, ward brands spread like glowing infection across the hide, a ragged mane, a dreadful 'pale rider' presence, more haunting than gory, 4-view grid (front/side plus rear and charge), limited 22-color palette ashen pale greys and sick ember glow with one wrong red accent..."

### New monsters
- `monster_fetus_crawler_bible.png`: "...a small pitiable larval crawling creature born from a failed ritual, pale underdeveloped curled body, an oversized smooth head, thin too-long grasping limbs, a faint glow under translucent skin, blind groping movement, stylized and tragic rather than gory, 4 views plus idle-curl/crawl/reach, limited 18-color palette pale fleshy greys and sick translucent tones with one faint wrong red accent..." *(rendered as "LARVAL WRETCH — FAILED RITUAL")*
- `monster_grasping_roots_bible.png`: "...animated tangled tree roots that erupt from the ground to grab and ensnare, gnarled bark-skinned tendrils with grasping clawed tips, soil and ritual debris clinging, shown as a set of states (dormant cracked ground, bursting up, coiled grabbing, retreating), limited 20-color palette cold dark browns and root-greys with one sickly Hunger-glow accent in the cracks..." *(hazard/creature sheet — states, not directional views)*
- `monster_ghost_girl_bible.png`: "...the pale translucent ghost of a small girl from a previous offering, a faded simple ritual dress, hair drifting as if underwater, hollow sorrowful glowing eyes, a semi-transparent lower half trailing into mist, holding a faded ribbon or a small toy, more melancholy and eerie than gruesome, 4 views plus drift/reach/fade, limited 18-color palette ghostly washed blues and bone-whites with one faint wrong accent..."
- `monster_evil_warden_bible.png`: "...a malevolent village Warden enforcer who hunts escaped children, tall gaunt figure in a long grimy oilskin coat and wide-brim hat, face lost in shadow with a faint wrong glow where the eyes should be, carrying a hooked lantern pole and a stitched festival armband gone foul, a menacing implacable hunter silhouette, 4-8 views plus stalking-search and lantern-raise lunge, limited 22-color palette cold slate blues and oilskin browns with one sickly festival-yellow and one wrong red accent..." *(the monstrous/horror counterpart to the human `villager_warden_bible.png` patrol figure)*

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
