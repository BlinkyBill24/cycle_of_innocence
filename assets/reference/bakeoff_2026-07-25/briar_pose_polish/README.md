# Briar V2 pose polish (2026-07-25 Bite 5)

Gentle cleanup of Imagine stand-in poses so they read at **48px game scale**.

## What changed

| Step | Detail |
|------|--------|
| Source poses | Hard alpha + dark-fringe kill (`tools/polish_briar_v2_poses.py`) |
| Backup | `assets/companions/briar/puppy_v2/anim/_pre_polish_poses/` |
| Pack | `build_briar_v2_spriteframes.py` — feet-aligned, pose fit idle+2px, hard alpha on cells |
| Ship | `briar_v2_pup.png` + `briar_v2_frames.tres` rebuilt |
| Scene | Briar sprite `texture_filter = nearest` |

## Previews (×4 nearest)

- `compare_idle_and_poses_x4.png` — idle · cower · dusk_press · head_bump · lie_down  
- `*_48_x4.png` per pose  

## Still human / later

- Projection still side-on vs loco front/top-down (identity polish, not this pass)
- True multi-dir pose grids (PixelLab / AutoSprite) if needed
- Hand pixel touch in GIMP/Pixelorama if edges still soft at F5

## Rebuild

```bash
python3 tools/polish_briar_v2_poses.py   # optional re-run from backup
python3 tools/build_briar_v2_spriteframes.py
```
