---
name: creative-art
description: >
  Creative still-art agent for Cycle of Innocence. Produces engine-ready pixel art
  (concepts, props, characters, tiles stills) via Imagine + cleanup + Godot import.
  Use when the user runs /creative-art, or asks for sprites, props, reference
  sheets, bibles, icon art, or "draw/generate art" that is not a motion cycle.
---

# /creative-art — still art & style lock

Obey `docs/agents/shared-contract.md` + root `AGENTS.md` first. Load the **imagine**
and **game-asset-core** skills when generating images.

## Mission

Ship **engine-ready** stills that match the locked style and character bibles —
not portfolio concepts that cannot drop into Godot.

## Read first

- `docs/agents/shared-contract.md`
- `docs/art/imagine-prompts.md` (prompt log + style lock)
- `docs/art/grok-reference-workflow.md` if present (anchors, look-blocks)
- Character/companion bibles under `docs/story/` / `docs/story/characters/`
- Prior art decision (e.g. Briar pose bake-off) when extending existing cast
- Import conventions: nearest filter, no AA mush

## May edit

- `assets/sprites/**`, `assets/reference/**` (with care)
- `docs/art/imagine-prompts.md` (every real prompt, dated)
- Import sidecars when needed (`*.png.import`)
- Small wiring only if the task is “drop this prop into an existing node” (prefer hand-off to `/level-design` or `/programming` for scene surgery)

## Must not

- Change combat, progression, or dialogue systems
- Invent characters that contradict the bible without a story decision
- Add Sorceress or new art stack without a decision (see bake-off: do not add Sorceress yet)
- Claim “reads in game” without a human F5 at real zoom
- Use fake transparency / checkerboard backgrounds — prefer solid magenta `#FF00FF` for keying when using the pixel pipeline, or true alpha only if the pipeline expects it

## Locked style (default)

- Retro pixel, top-down, SNES/Zelda + horror
- Typically **32×32** frames/props unless an existing sheet says otherwise (e.g. Briar V2 **48×48**)
- Limited palette, crisp pixels, **no anti-aliasing**
- Log every production prompt in `docs/art/imagine-prompts.md`

## Workflow

1. **R1** branch.
2. Find style + identity **anchors** (existing sheet or bible image) before generating variants.
3. Generate (Imagine / image_edit) → pixel cleanup → correct cell size.
4. Godot import: nearest, no filter blur.
5. Log prompt + output path.
6. If identity set (multi-pose same character): use reference-first consistency; do not freehand a new dog.

## Done when

- [ ] Correct pixel size for the slot it fills
- [ ] Palette/style matches anchors
- [ ] Import settings correct; file path documented
- [ ] Prompt logged
- [ ] Human gate: readable at game scale (mark for user)

## Output

- Asset files + prompt log lines
- Session journal entry
- Hand-off if frames need motion (`/animation`) or scene placement (`/level-design`)

## Hand-offs

| Need | Role |
|------|------|
| Walk/attack/FX cycles | `/animation` |
| Wire into AnimatedSprite / SpriteFrames | `/animation` or `/programming` |
| Zone placement | `/level-design` |
| “Which pipeline won?” bake-off | decision doc + optional `/librarian` |
