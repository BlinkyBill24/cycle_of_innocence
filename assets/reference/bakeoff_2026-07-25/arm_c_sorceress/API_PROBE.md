# Arm C — Sorceress Tool API probe (2026-07-25)

## Mission

Prove key-on-disk + headless client; attempt **one** Briar `cower` gen vs Arm A (test only).  
**Do not** auto-adopt Sorceress into the production art stack ([[decisions/2026-07-25-briar-pose-bakeoff]] still stands).

## Key storage (human)

```text
~/.config/sorceress/api_key   # chmod 600, NEVER in repo
# optional: SORCERESS_API_KEY env
```

Same pattern as PixelLab / ElevenLabs.

## Client

```bash
python3 tools/sorceress_api.py ping
python3 tools/sorceress_api.py tools
python3 tools/sorceress_api.py image "…" --model grok-imagine --aspect 1:1 --out path.png
```

**Live base:** `https://sorceress.games/api/v1`  
- `GET /tools` — catalog  
- `POST /tools/<id>` — invoke  
- `GET /jobs/<id>` — async poll  

## Results

| Check | Result |
|-------|--------|
| Key file present + mode 600 | OK |
| `ping` (auth) | **OK** |
| `tools` list | **OK** |
| First gen attempt | **402** balance 0 (before credits) |
| Second gen (credits topped) | **OK** job `e31c3d2c-…` **succeeded** |
| Output | `cower_raw.png` (960×960 JPEG-as-png, ~144 KB) + `cower_48.png` nearest shrink + `compare_cower_A_vs_C_x4.png` |
| Model used | `grok-imagine`, aspect `1:1` |

## Scorecard — one pose (`cower`) vs Arm A (0–5)

| Criterion | A Imagine (shipped interim) | C Sorceress API (this probe) |
|-----------|----------------------------|------------------------------|
| On-model to Briar V2 (Malinois pup, top-down) | **4** | **2** (cute side-view bulldog-ish; pink collar; not V2 sheet) |
| 32/48px clarity | **3** | **1** (high-res faux-pixel; nearest 48 mush) |
| Pose distinctness (scared cower) | **5** | **2** (reads as relaxed lie / cute rest more than fear) |
| 4-dir readiness | 2 | 1 |
| Palette / style vs V2 sheet | 3 | 2 |
| Time-to-import (API path) | 4 | **4** (after credits: ~20s job) |
| Commercial / pipeline clarity | 3 | 3 (Tool API works; AutoSprite not used) |
| Human edit burden | 3 | **4** (would need re-prompt + True Pixel + scale) |
| **Subtotal (same 8 axes)** | **27** | **19** |

**Agent recommendation:** Arm A still wins this job. **Do not adopt Sorceress as production stack** from this single call. API integration is proven; art quality for *this* prompt/model did not beat Imagine stand-ins.

**Human gate:** open the compare strip and `cower_raw` at game zoom — override scores if you disagree.

## Artifacts

```
cower_raw.png              # API download (large)
cower_raw_true.png         # RGBA re-save
cower_48.png               # naive 48×48 nearest (preview only)
cower_48_x4.png
compare_cower_A_vs_C_x4.png  # left A · right C
```

## Stack status

**Unchanged:** Sorceress is **not** production stack. Client remains optional probe tooling.  
Revisit only if a later run (ref images + True Pixel / AutoSprite + top-down lock) beats Arm A **and** Arm B style lock on the same anchors.
