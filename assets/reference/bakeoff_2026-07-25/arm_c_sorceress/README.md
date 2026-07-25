# Arm C — Sorceress.games (human trial recipe + API probe)

**Bake-off day:** browser path not run.  
**API probe 2026-07-25:** key + `tools/sorceress_api.py` **auth OK**; image gen **blocked on 0 credits**.  
See [[API_PROBE]] for paths, commands, and re-run steps.

## Goal

Same four Briar V2 stand-in poses as Arms A/B:

| Pose | Readable read |
|---|---|
| `cower` | low, scared, tucked |
| `dusk_press` | affectionate side lean / press |
| `head_bump` | gentle forehead bump toward camera |
| `lie_down` | belly rest, calm |

## Inputs (copy from this bake-off folder)

- `../anchors/briar_v2_style_ref.png` — style lock  
- `../anchors/briar_v2_idle_south_f0.png` — pose start  
- `../anchors/briar_v2_concept.png` — optional concept  

## Suggested tool path on Sorceress

1. **AI Image Gen** or upload anchors (prefer reference upload).  
2. **AI Video Gen** (optional): short idle→pose motion if Auto-Sprite wants video.  
3. **Auto-Sprite v2** *or* **True Pixel** / **Pixel Snap**: force **true pixel grid**, palette limit ~24, transparent/magenta bg, south / low top-down.  
4. Export **PNG frames** (not only web preview).  
5. Drop exports here as:

```
cower_raw.png
dusk_press_raw.png
head_bump_raw.png
lie_down_raw.png
```

6. Optional: run the same 48px cell fit as Arms A/B (or ask an agent to pixelize).

## Score (API probe `cower` only — fill full set later)

| Criterion | Score (API cower) | Notes |
|---|---|---|
| On-model to Briar V2 | 2 | Side-view cute pup; not Malinois V2 top-down |
| 32/48px clarity | 1 | 960px faux-pixel; 48 nearest mush |
| Pose distinctness | 2 | More lie/rest than scared cower |
| 4-dir readiness | 1 | Single side-ish frame |
| Palette / style vs V2 | 2 | Magenta OK; collar/breed off |
| Time-to-import | 4 | API ~20s after credits |
| Commercial clarity | 3 | Tool API works |
| Human edit burden | 4 | Needs heavy rework for sheet |

Full write-up: [[API_PROBE]]. Compare to decision [[decisions/2026-07-25-briar-pose-bakeoff]].  
**Recommendation:** keep Arm A interim; **no stack adopt**.

## Hard rules for CoI

- Godot stays the engine — **do not** build the game in WizardGenie.  
- Keep exports as plain PNGs in-repo; no cloud runtime in the shipped game.  
- Log prompts/dates in `docs/art/imagine-prompts.md` (or a sorceress subsection).  
