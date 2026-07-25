# Sorceress AutoSprite trial vs PixelLab (2026-07-25)

**Goal:** Can AutoSprite V3 replace PixelLab for **multi-dir character grids**?  
One south walk probe only — not a full 4-dir sheet.

**Note:** Sorceress can route **Grok Imagine** for stills and **Imagine 1.5** for video (used here).

## Pipeline run (API)

1. `image_generate` model=`grok-imagine` — Briar-like pup on **green screen**  
   → `briar_green_char.png`
2. `autosprite_create_character`  
   → asset `c7af3fb4-4015-47a2-b5d8-ec6f3c182fde`
3. `autosprite_animate` model=`imagine-1.5`, 3 s walk_south, 720p  
   → 12 credits; `walk_south_greenscreen.mp4`
4. `autosprite_key` (Corridor Key), sampleEvery=8  
   → 4 credits; `walk_south_sheet.png`  
   Meta: **11 frames**, 8×2 grid, **frame 960×960**, fps ~3.75

Balance after run ≈ 954 (from API response).

## Artifacts

| File | Role |
|------|------|
| `briar_green_char.png` | Still input (green) |
| `walk_south_greenscreen.mp4` | Raw video |
| `walk_south_sheet.png` | HD RGBA sheet (~3.4 MB) |
| `walk_frame0.png` / `_48` / `_48_x4` | First frame + game-scale previews |
| `0x_*.log` | API logs |

## Agent scorecard vs PixelLab job (0–5)

| Criterion | PixelLab (current role) | AutoSprite this run |
|-----------|-------------------------|---------------------|
| On-model to Briar **V2 sheet** | **4** (when bitforge locks) | **2–3** (cute pup + collar/bell; front-view, not V2 top-down sheet mate) |
| True **32/48px** grid | **5** | **1** (960px frames; 48 nearest mush) |
| Multi-dir readiness | **5** (rotate/skeleton) | **2** (one video dir; more dirs = more $ and jobs) |
| Walk cycle / foot plant | **4** (skeleton timing) | **3** (video walk — need human F5 on mp4/sheet) |
| Style lock across variants | **4** | **2** (new still each time unless ref URLs) |
| Time / automation | 3 | **4** (full API path worked end-to-end) |
| Cost control | known free-tier pitfalls | 12+4 credits this clip; scales with seconds/frames |
| Godot import simplicity | high (cell sheets) | medium (huge HD sheet → downscale/regrid) |

**Agent recommendation:** **Keep PixelLab** for multi-dir locomotion grids.  
AutoSprite is a **real optional path** for cinematic / HD companion anims or prototypes, not a drop-in for 48px Briar loco.

## Human scores (2026-07-25)

| Call | Note |
|------|------|
| Walk animation | **Not bad for a first try** — motion path useful |
| Character look | **PixelLab dog still better** (identity/sheet fit) — assumed fixable with better still/refs later |
| Stack | **Keep PixelLab** for now; AutoSprite stays optional experiment |

## Stack status

PixelLab **not replaced**. Imagine stays for pose stand-ins. AutoSprite = optional path (motion OK; identity polish later).
