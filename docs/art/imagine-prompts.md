# Grok Imagine prompts — Cycle of Innocence

**Locked style**: retro pixel art, top-down, 32×32 per frame / reference grid, limited 24–32 color palette, SNES/Zelda + creeping horror atmosphere, transparent bg, crisp pixels, no anti-aliasing.

## Protagonist (Child — escaped sacrifice, ~8–10, revised ritual)
**Bible (updated for playground ritual with lottery/harmony score, creepy clowns/stuffed animals/toys, villagers believe "successful")**

```
retro pixel art top-down 32x32 character reference sheet, SNES Zelda style with horror atmosphere, small child ~8-10 selected via village lottery or Community Harmony Score (parents' contributions), escaped the ritual at the village playground (safe happy place with colorful but off decorations), wide innocent yet haunted eyes, simple rough tunic with ritual tear marks from creepy clown/stuffed toy "guardians", bare feet, 4–8 views (front back left right + 3/4 angles, one with toy in hand), A-pose + slight defensive posture after fleeing into fog, limited 24-color palette with desaturated rural tones + one wrong red accent for the "marked" feeling, palette swatches bottom row, transparent background, crisp pixels no anti-aliasing
```

Save as: `assets/reference/protagonist_child_bible.png` (revise for playground context)

## First Animal Companion (Dog / Hound pup — escaped with player, revised)
**Bible (updated for playground "lesser offering", villager unawareness of escape, escalation creating more monsters)**

```
retro pixel art top-down 32x32 animal companion reference sheet, SNES Zelda style horror-tinged, small terrified dog/wolf pup brought as lesser offering at village playground ritual (creepy clowns/stuffed toys), big fearful eyes, scruffy fur, one ear torn, ritual nick on flank from toy "guardians", loyal but scared posture next to escaped child, 2x2 or 4-view grid (front/side + action hints like digging), growth note space for adult version (brave protector or corrupted), limited 20-color palette (earthy browns + one warm bond glow), palette swatches, transparent bg, crisp pixels no anti-aliasing
```

Save as: `assets/reference/companion_dog_pup_bible.png` (revise for playground context)

## Later variants (to generate after first slice)
- Protagonist teen + adult versions (same character bible evolution + taller silhouette + outfit reflecting morality choices: innocent bright vs pragmatic cloak vs ruthless scars/marks).
- Dog adult + corrupted versions (larger, more powerful stance; corrupted: glowing eyes, exposed "veins" or shadow tendrils, hunched aggressive).
- Bird companion bible (scout/raptor — smaller, flight poses in grid).
- Horse/foal bible (mount — larger silhouette, calm vs panicked).

Use `image_edit` on the bibles for variations (different morality tints, specific action frames) before full sheet generation.

## Full animation sheets (after bible approval)
Use image_edit referencing the bible + exact grid layout (document in sheet_layout.txt).

Example for child protagonist 4-dir locomotion + attack/hurt:
```
retro pixel art top-down RPG sprite sheet, same escaped child from reference image, organized 8 column X row grid 32x32 per frame, row layouts for idle/walk/attack/hurt per direction, transparent background crisp pixels no anti-aliasing limited palette SNES game asset with subtle horror edge
```

Post-process in Aseprite (grid snap, palette reduce, anim timing for age weight shift and companion personality).
