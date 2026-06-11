#!/usr/bin/env python3
"""PixelLab v2 character pipeline (per https://api.pixellab.ai/v2/llms.txt).

Proper flow: create each character ONCE from bible reference crops
(directions param) -> animate the stored character via skeleton templates
(consistent identity + correct directions) -> export ZIP -> assemble sheets.

Usage:
  python3 tools/pixellab_v2.py refs        # crop bible references for approval
  python3 tools/pixellab_v2.py create      # create 3 characters (async jobs)
  python3 tools/pixellab_v2.py status      # poll job/character status
  python3 tools/pixellab_v2.py animate     # queue animations on characters
  python3 tools/pixellab_v2.py download    # export character ZIPs + unpack
  python3 tools/pixellab_v2.py balance
"""
import argparse
import base64
import importlib.util
import json
import sys
import time
import urllib.request
from pathlib import Path

from PIL import Image

sys.path.insert(0, str(Path(__file__).parent))
from pixellab_api import api_key  # noqa: E402

_spec = importlib.util.spec_from_file_location("pixelize", Path(__file__).parent / "pixelize.py")
pixelize = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(pixelize)

BASE = "https://api.pixellab.ai/v2"
OUT = Path("assets/reference/pixellab_v2")
STATE_PATH = OUT / "state.json"
CHAR_SIZE = 32  # native game resolution — no downscaling afterwards

# bible crops: (file, left, top, right, bottom in source px, facing)
REFS = {
    "rowan": ("assets/reference/protagonist_child_bible.png", 85, 119, 512, 785, "south", False),
    "briar": ("assets/reference/companion_dog_pup_bible.png", 256, 205, 785, 956, "south", True),
    "twisted": ("assets/reference/monster_twisted_child_bible.png", 102, 205, 512, 990, "west", True),
}

DESCRIPTIONS = {
    "rowan": "small 9 year old village child, messy dark purple-brown hair, pale skin, big sad eyes, grey rough-spun knee-length tunic with faded red hand print on chest, bare feet",
    "briar": "small Belgian Malinois puppy, short fawn tan coat, black mask on muzzle, large dark upright ears, torn left ear, small bell collar, lean young build",
    "twisted": "small hunched creature in tattered grey rags, faded carnival clown neck ruff, face hidden in shadow, overly long thin fingers, dragging a tiny wooden duck pull toy on a string",
}

TEMPLATE_IDS = {"rowan": "mannequin", "briar": "dog", "twisted": "mannequin"}

## Redesign pass (2026-06-11): create-character-pro with the Grok bible as
## concept_image and a crisp cell from the Grok pixel sheets as style
## reference_image. Twisted has no clean sheet — Rowan's cell carries the
## rendering style; the bible + description carry the design.
STYLE_CELLS = {
    "rowan": ("assets/reference/protagonist_child_sheet_clean.png", 0, 0),
    "briar": ("assets/reference/companion_briar_sheet_clean.png", 0, 0),
    "twisted": ("assets/reference/protagonist_child_sheet_clean.png", 0, 0),
}
STYLE_CELL_SIZE = 296  # 1776x2368 sheets are 6x8 grids


def call(endpoint: str, payload: dict | None = None, method: str = "POST") -> dict:
    req = urllib.request.Request(
        f"{BASE}/{endpoint.lstrip('/')}",
        data=json.dumps(payload).encode() if payload is not None else None,
        headers={"Authorization": f"Bearer {api_key()}", "Content-Type": "application/json"},
        method=method,
    )
    try:
        with urllib.request.urlopen(req, timeout=300) as resp:
            return json.load(resp)
    except urllib.error.HTTPError as e:
        raise RuntimeError(f"PixelLab v2 {e.code} on {endpoint}: {e.read().decode()[:500]}") from e


def get_bytes(endpoint: str) -> bytes:
    req = urllib.request.Request(
        f"{BASE}/{endpoint.lstrip('/')}",
        headers={"Authorization": f"Bearer {api_key()}"},
    )
    with urllib.request.urlopen(req, timeout=300) as resp:
        return resp.read()


def state() -> dict:
    return json.loads(STATE_PATH.read_text()) if STATE_PATH.exists() else {}


def save_state(data: dict) -> None:
    STATE_PATH.write_text(json.dumps(data, indent=1))


def b64(path: Path) -> dict:
    return {"type": "base64", "base64": base64.b64encode(path.read_bytes()).decode()}


def make_refs(only: str | None = None, seed: int = 0, force: bool = False) -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    for char, (src, l, t, r, b, facing, api_debg) in REFS.items():
        if only and char != only:
            continue
        if not force and (OUT / f"{char}_ref_{facing}.png").exists() and not only:
            print(f"skip {char} ref (exists)")
            continue
        crop = Image.open(src).crop((l, t, r, b))
        if api_debg:
            # PixelLab's own background remover for non-checkerboard panel art
            tmp = OUT / f"_{char}_crop.png"
            crop.convert("RGB").resize((400, 400), Image.LANCZOS).save(tmp)
            result = call("remove-background", {
                "image": b64(tmp),
                "image_size": {"width": 400, "height": 400},
            })
            img = result.get("image") or (result.get("images") or [{}])[0]
            keyed = Image.open(__import__("io").BytesIO(base64.b64decode(
                img["base64"] if isinstance(img, dict) else img))).convert("RGBA")
        else:
            keyed = pixelize.key_background(crop)
        bbox = keyed.getchannel("A").getbbox()
        if bbox:
            keyed = keyed.crop(bbox)
        side = max(keyed.size)
        padded = Image.new("RGBA", (side, side), (0, 0, 0, 0))
        padded.paste(keyed, ((side - keyed.width) // 2, (side - keyed.height) // 2))
        hi = OUT / f"{char}_ref_{facing}_hi.png"
        padded.resize((256, 256), Image.LANCZOS).save(hi)
        # convert to native-size pixel art (direction refs must match image_size)
        payload = {
            "image": b64(hi),
            "image_size": {"width": 256, "height": 256},
            "output_size": {"width": CHAR_SIZE, "height": CHAR_SIZE},
        }
        if seed:
            payload["seed"] = seed
        result = call("image-to-pixelart", payload)
        img = result.get("image") or (result.get("images") or [{}])[0]
        import io
        px = Image.open(io.BytesIO(base64.b64decode(
            img["base64"] if isinstance(img, dict) else img))).convert("RGBA")
        px = _largest_blob(pixelize.key_background(px))
        out = OUT / f"{char}_ref_{facing}.png"
        px.save(out)
        print(f"ref: {out} (from {Path(src).name}, facing {facing}, {CHAR_SIZE}px)")


def _largest_blob(img: Image.Image) -> Image.Image:
    """Keep only the largest 4-connected opaque region (drops floating
    annotation marks that leaked from the bible sheets)."""
    import numpy as np
    arr = np.asarray(img).copy()
    alpha = arr[:, :, 3] > 0
    labels = np.zeros(alpha.shape, dtype=int)
    current = 0
    best_label, best_size = 0, 0
    for y in range(alpha.shape[0]):
        for x in range(alpha.shape[1]):
            if alpha[y, x] and labels[y, x] == 0:
                current += 1
                stack, size = [(y, x)], 0
                labels[y, x] = current
                while stack:
                    cy, cx = stack.pop()
                    size += 1
                    for ny, nx in ((cy-1,cx),(cy+1,cx),(cy,cx-1),(cy,cx+1)):
                        if 0 <= ny < alpha.shape[0] and 0 <= nx < alpha.shape[1] \
                                and alpha[ny, nx] and labels[ny, nx] == 0:
                            labels[ny, nx] = current
                            stack.append((ny, nx))
                if size > best_size:
                    best_size, best_label = size, current
    arr[(labels != best_label), 3] = 0
    return Image.fromarray(arr, "RGBA")


## briar: clean pixel direction ref. rowan/twisted: the bibles' red annotation
## marks poison pixelart conversion — use description + bible palette instead.
USE_DIRECTION_REF: set[str] = set()  # dog template demands south+east refs; palette path for all


def _despill_magenta(img: Image.Image) -> Image.Image:
    import numpy as np
    arr = np.asarray(img.convert("RGBA")).copy()
    r = arr[:, :, 0].astype(int)
    g = arr[:, :, 1].astype(int)
    b = arr[:, :, 2].astype(int)
    arr[(r > 170) & (b > 170) & (g < r - 60) & (g < b - 60), 3] = 0
    return Image.fromarray(arr, "RGBA")


def make_style_ref(char: str) -> Path:
    """One sheet cell -> clean native-32 pixel art -> 4x nearest (crisp 128px
    style reference, under the API's 168px cap)."""
    src, col, row = STYLE_CELLS[char]
    c = STYLE_CELL_SIZE
    cell = Image.open(src).crop((col * c, row * c, (col + 1) * c, (row + 1) * c))
    cell = _despill_magenta(cell)
    bbox = cell.getchannel("A").getbbox()
    if bbox:
        cell = cell.crop(bbox)
    side = max(cell.size)
    padded = Image.new("RGBA", (side, side), (0, 0, 0, 0))
    padded.paste(cell, ((side - cell.width) // 2, (side - cell.height) // 2))
    px = padded.resize((32, 32), Image.BOX)
    out = OUT / f"{char}_style_ref.png"
    px.resize((128, 128), Image.NEAREST).save(out)
    return out


def make_concept(char: str) -> Path:
    """Keyed character crop from the bible — the full page leaks parchment
    and annotation blocks into the generation (rowan probe #1)."""
    src, l, t, r, b, _facing, api_debg = REFS[char]
    crop = Image.open(src).crop((l, t, r, b))
    if api_debg:
        tmp = OUT / f"_{char}_concept_crop.png"
        crop.convert("RGB").resize((400, 400), Image.LANCZOS).save(tmp)
        result = call("remove-background", {
            "image": b64(tmp),
            "image_size": {"width": 400, "height": 400},
        })
        img = result.get("image") or (result.get("images") or [{}])[0]
        import io
        keyed = Image.open(io.BytesIO(base64.b64decode(
            img["base64"] if isinstance(img, dict) else img))).convert("RGBA")
    else:
        keyed = pixelize.key_background(crop)
    bbox = keyed.getchannel("A").getbbox()
    if bbox:
        keyed = keyed.crop(bbox)
    keyed = _largest_blob(keyed)
    side = max(keyed.size)
    padded = Image.new("RGBA", (side, side), (0, 0, 0, 0))
    padded.paste(keyed, ((side - keyed.width) // 2, (side - keyed.height) // 2))
    out = OUT / f"{char}_concept.png"
    padded.resize((512, 512), Image.LANCZOS).save(out)
    return out


def create_pro(only: str | None = None) -> None:
    st = state()
    for char in REFS:
        if only and char != only:
            continue
        key = f"{char}_pro"
        if st.get(key, {}).get("character_id") or st.get(key, {}).get("create_job"):
            print(f"skip {key} (already created/queued)")
            continue
        payload = {
            "description": DESCRIPTIONS[char],
            "image_size": {"width": 32, "height": 32},
            "method": "create_from_concept",
            "view": "low top-down",
            "template_id": TEMPLATE_IDS[char],
            "concept_image": b64(make_concept(char)),
            "reference_image": b64(make_style_ref(char)),
            "no_background": True,
        }
        if getattr(create_pro, "seed", 0):
            payload["seed"] = create_pro.seed
        result = call("create-character-pro", payload)
        st[key] = {
            "create_job": result.get("background_job_id"),
            "character_id": result.get("character_id"),
        }
        print(f"{key}: character {st[key]['character_id']} (job {st[key]['create_job']})")
        save_state(st)
    print("balance:", call("balance", method="GET"))


def preview(char_key: str) -> None:
    """Fetch a character's stored rotations and build an upscaled contact strip."""
    import io
    st = state()
    cid = st.get(char_key, {}).get("character_id")
    if not cid:
        print(f"{char_key}: no character")
        return
    info = call(f"characters/{cid}", method="GET")
    frames: list[Image.Image] = []
    rot_urls: dict = info.get("rotation_urls") or {}
    order = ["south", "south-east", "east", "north-east", "north", "north-west", "west", "south-west"]
    for direction in sorted(rot_urls, key=lambda d: order.index(d) if d in order else 99):
        url = rot_urls[direction]
        # storage URLs are public and reject the API bearer header
        with urllib.request.urlopen(url, timeout=120) as resp:
            frames.append(Image.open(io.BytesIO(resp.read())).convert("RGBA"))
    if not frames:
        print(f"{char_key}: no rotation images in response — keys: {list(info.keys())}")
        return
    w = max(f.width for f in frames)
    strip = Image.new("RGBA", (w * len(frames), w), (40, 40, 50, 255))
    for i, f in enumerate(frames):
        strip.paste(f, (i * w, 0), f)
    out = OUT / f"{char_key}_preview.png"
    strip.resize((strip.width * 4, strip.height * 4), Image.NEAREST).save(out)
    print(f"preview: {out} ({len(frames)} rotations, frame {w}px)")


def create() -> None:
    st = state()
    for char, (_src, _l, _t, _r, _b, facing, _debg) in REFS.items():
        if st.get(char, {}).get("character_id") or st.get(char, {}).get("create_job"):
            print(f"skip {char} (already created/queued)")
            continue
        payload = {
            "description": DESCRIPTIONS[char],
            "image_size": {"width": CHAR_SIZE, "height": CHAR_SIZE},
            "view": "low top-down",
            "template_id": TEMPLATE_IDS[char],
        }
        if char in USE_DIRECTION_REF:
            payload["directions"] = {facing: b64(OUT / f"{char}_ref_{facing}.png")}
        else:
            payload["color_image"] = b64(OUT / f"{char}_ref_{facing}_hi.png")
        result = call("create-character-with-4-directions", payload)
        st.setdefault(char, {})["create_job"] = result.get("background_job_id")
        st[char]["character_id"] = result.get("character_id")
        print(f"{char}: character {st[char]['character_id']} (job {st[char]['create_job']})")
        save_state(st)
    print("balance:", call("balance", method="GET"))


def status() -> None:
    st = state()
    for char, info in st.items():
        for key in ("create_job",) + tuple(k for k in info if k.startswith("anim_job_")):
            job_id = info.get(key)
            if not job_id:
                continue
            job = call(f"background-jobs/{job_id}", method="GET")
            print(f"{char}/{key}: {job.get('status')}")
            if job.get("status") == "completed" and key == "create_job":
                last = job.get("last_response") or {}
                cid = last.get("character_id") or last.get("id")
                if cid:
                    info["character_id"] = cid
                    print(f"  character_id: {cid}")
    save_state(st)


# sheet rows: (row_anim_name, zip_animation_match, direction, loop, fps)
SHEET_ROWS = {
    "rowan": {
        "out": "assets/sprites/player/child_sheet_32.png",
        "tres": "assets/resources/player/rowan_child_frames.tres",
        "rows": [
            ("walk_down", "walk", "south", "loop", 8),
            ("walk_up", "walk", "north", "loop", 8),
            ("walk_right", "walk", "east", "loop", 8),
            ("walk_left", "walk", "west", "loop", 8),
            ("idle_down", "idle", "south", "loop", 5),
            ("attack_down", "attack", "south", "once", 12),
            ("attack_up", "attack", "north", "once", 12),
            ("attack_right", "attack", "east", "once", 12),
            ("attack_left", "attack", "west", "once", 12),
            ("hurt", "hurt", "south", "once", 10),
            ("crouch", "crouch", "south", "once", 8),
        ],
        "aliases": {"idle_up": "walk_up", "idle_right": "walk_right", "idle_left": "walk_left"},
    },
    "briar": {
        "out": "assets/sprites/companions/briar_pup_32.png",
        "tres": "assets/resources/companions/briar_pup_frames.tres",
        "rows": [
            ("trot_down", "walk", "south", "loop", 8),
            ("trot_up", "walk", "north", "loop", 8),
            ("trot_right", "walk", "east", "loop", 8),
            ("trot_left", "walk", "west", "loop", 8),
            ("sit", "idle", "south", "loop", 4),
            ("bark", "bark", "east", "loop", 8),
            ("cower", "cower", "south", "loop", 6),
            ("dig", "dig", "east", "loop", 10),
        ],
        "aliases": {},
    },
    "twisted": {
        "out": "assets/sprites/enemies/twisted_child_32.png",
        "tres": "assets/resources/enemies/twisted_child_frames.tres",
        "rows": [
            ("walk_down", "walk", "south", "loop", 7),
            ("walk_up", "walk", "north", "loop", 7),
            ("walk_right", "walk", "east", "loop", 7),
            ("walk_left", "walk", "west", "loop", 7),
            ("idle", "idle", "south", "loop", 4),
            ("lunge", "lunge", "east", "once", 10),
            ("stilled", "stilled", "south", "loop", 3),
        ],
        "aliases": {},
    },
}


SYNONYMS = {
    "breathing-idle": "idle", "idle": "idle",
    "cross-punch": "attack", "taking-punch": "hurt", "crouching": "crouch",
    "crouched-walking": "walk", "walk-4-frames": "walk", "walk": "walk",
    "sneaking": "cower", "bark": "bark",
}


def _canonical(raw: str) -> str:
    raw = (raw or "").lower()
    if raw in SYNONYMS:
        return SYNONYMS[raw]
    for needle, name in [("lunge", "lunge"), ("hugging", "stilled"), ("sitting", "stilled"),
                          ("digging", "dig"), ("cowering", "cower"), ("flinch", "hurt"),
                          ("stumbl", "hurt"), ("crouch", "crouch"), ("walk", "walk")]:
        if needle in raw:
            return name
    return raw


def _collect_from_api(char: str) -> dict:
    """{(canonical_name, direction): [frame_url, ...]} — first complete group wins."""
    st = state()
    detail = call(f"characters/{st[char]['character_id']}", method="GET")
    frames: dict = {}
    for anim in detail.get("animations", []):
        name = _canonical(anim.get("display_name") or anim.get("animation_type") or "")
        for entry in anim.get("directions", []):
            key = (name, entry["direction"])
            urls = entry.get("frames", [])
            if key not in frames and urls:
                frames[key] = urls
    return frames


def _fetch_frame(url: str) -> Image.Image:
    import io
    with urllib.request.urlopen(url, timeout=120) as resp:
        return Image.open(io.BytesIO(resp.read())).convert("RGBA")


def _find_frames(char_dir: Path, match: str, direction: str) -> list[Path]:
    candidates = []
    for d in char_dir.rglob(direction):
        if d.is_dir() and "animations" in str(d):
            label = d.parent.name.lower()
            if match in label or match in str(d.parent.parent.name).lower():
                candidates.append(d)
    # match by template synonyms when display name differs
    synonyms = {"walk": ["walk", "crouched-walking", "walk-4-frames"],
                "idle": ["breathing-idle", "idle"],
                "attack": ["cross-punch"], "hurt": ["taking-punch"],
                "crouch": ["crouching"], "bark": ["bark"], "cower": ["sneaking"],
                "dig": ["dig"], "lunge": ["lunge"], "stilled": ["stilled", "sitting"]}
    if not candidates:
        for d in char_dir.rglob(direction):
            if d.is_dir() and "animations" in str(d):
                label = (d.parent.name + " " + d.parent.parent.name).lower()
                if any(s in label for s in synonyms.get(match, [match])):
                    candidates.append(d)
    if not candidates:
        return []
    frames = sorted(candidates[0].glob("*.png"), key=lambda p: int(p.stem))
    return frames


# zip animation-folder per (char, sheet_anim) — hand-resolved from metadata.json
# (template animations export under generic "animating-*" names; frame URLs in
# the API are access-restricted, so the local ZIP is the source)
ZIP_FOLDERS = {
    "rowan": {
        "walk_down": ("walking-3d7e3d8d", "south"), "walk_up": ("walking-3d7e3d8d", "north"),
        "walk_right": ("walking-3d7e3d8d", "east"), "walk_left": ("walking", "west"),
        "idle_down": ("animating", "south"),
        "attack_down": ("cross_punch_attack", "south"), "attack_up": ("cross_punch_attack", "north"),
        "attack_right": ("cross_punch_attack", "east"), "attack_left": ("cross_punch_attack", "west"),
        "hurt": ("taking_a_punch", "south"), "crouch": ("crouching", "south"),
    },
    "briar": {
        "trot_down": ("animating", "south"), "trot_up": ("animating", "north"),
        "trot_right": ("animating-b09da537", "east"), "trot_left": ("animating-b09da537", "west"),
        "sit": ("animating-806a9088", "south"),      # upright idle (visually verified)
        "bark": ("animating-a9daec65", "east"),
        "cower": ("animating-501bd44e", "south"),    # flattened sneak (visually verified)
        "dig": ("digging_energetically_in_the_dirt_with_front_paws", "east"),
    },
    "twisted": {
        "walk_down": ("walking_while_crouched-ef5fdfa6", "south"),
        "walk_up": ("walking_while_crouched-ef5fdfa6", "north"),
        "walk_right": ("walking_while_crouched", "east"),
        "walk_left": ("walking_while_crouched", "west"),
        "idle": ("animating", "south"),
        "lunge": ("sudden_forward_lunge_with_long_arms_outstretched", "east"),
        "stilled": ("sitting_down_calmly_hugging_a_small_wooden_duck_to", "south"),
    },
}


def sheets() -> None:
    for char, cfg in SHEET_ROWS.items():
        char_dir = OUT / "chars" / char
        anim_root = next(char_dir.glob("*/animations"))
        rows_frames: list[tuple[str, list[Image.Image]]] = []
        max_cols = 0
        for name, _match, _direction, _loop, _fps in cfg["rows"]:
            folder, direction = ZIP_FOLDERS[char][name]
            frame_dir = anim_root / folder / direction
            frame_paths = sorted(frame_dir.glob("frame_*.png"))
            if not frame_paths:
                print(f"MISSING {char}/{name} ({frame_dir})")
                return
            imgs = []
            for fp in frame_paths:
                img = Image.open(fp).convert("RGBA")
                # canvas is ~40% larger than character — center-crop to 32
                if img.width > CHAR_SIZE:
                    off_x = (img.width - CHAR_SIZE) // 2
                    off_y = (img.height - CHAR_SIZE) // 2
                    img = img.crop((off_x, off_y, off_x + CHAR_SIZE, off_y + CHAR_SIZE))
                imgs.append(img)
            max_cols = max(max_cols, len(imgs))
            rows_frames.append((name, imgs))
        sheet = Image.new("RGBA", (max_cols * CHAR_SIZE, len(rows_frames) * CHAR_SIZE), (0, 0, 0, 0))
        for r, (_name, imgs) in enumerate(rows_frames):
            for c, img in enumerate(imgs):
                sheet.paste(img, (c * CHAR_SIZE, r * CHAR_SIZE))
        Path(cfg["out"]).parent.mkdir(parents=True, exist_ok=True)
        sheet.save(cfg["out"])
        sheet.resize((sheet.width * 3, sheet.height * 3), Image.NEAREST).save(
            cfg["out"].replace(".png", "_preview.png"))
        _write_tres(char, cfg, rows_frames)
        print(f"sheet: {cfg['out']} ({len(rows_frames)} rows, {max_cols} cols)")


def _write_tres(char: str, cfg: dict, rows_frames: list) -> None:
    import random
    import string
    rng = random.Random(char)
    def uid(n=5):
        return "".join(rng.choices(string.ascii_lowercase + string.digits, k=n))
    res_path = "res://" + cfg["out"]
    atlases, anims = [], []
    def add_anim(name: str, row: int, count: int, loop: str, fps: float):
        refs = []
        for col in range(count):
            aid = f"AtlasTexture_{uid()}"
            atlases.append(
                f'[sub_resource type="AtlasTexture" id="{aid}"]\n'
                f'atlas = ExtResource("1_sheet")\n'
                f"region = Rect2({col * CHAR_SIZE}, {row * CHAR_SIZE}, {CHAR_SIZE}, {CHAR_SIZE})\n")
            refs.append('{\n"duration": 1.0,\n"texture": SubResource("%s")\n}' % aid)
        anims.append("{\n"
                     f'"frames": [{", ".join(refs)}],\n'
                     f'"loop": {"true" if loop == "loop" else "false"},\n'
                     f'"name": &"{name}",\n'
                     f'"speed": {float(fps)}\n' + "}")
    row_index = {}
    for i, (name, imgs) in enumerate(rows_frames):
        row_index[name] = (i, len(imgs))
    for (name, _m, _d, loop, fps), (row, count) in zip(cfg["rows"], row_index.values()):
        add_anim(name, row, count, loop, fps)
    for alias, source in cfg.get("aliases", {}).items():
        row, _count = row_index[source]
        add_anim(alias, row, 1, "loop", 4)
    out = (f'[gd_resource type="SpriteFrames" load_steps={len(atlases) + 2} format=3]\n\n'
           f'[ext_resource type="Texture2D" path="{res_path}" id="1_sheet"]\n\n'
           + "\n".join(atlases)
           + "\n[resource]\nanimations = [" + ", ".join(anims) + "]\n")
    Path(cfg["tres"]).write_text(out)
    print(f"tres: {cfg['tres']}")


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("cmd", choices=["refs", "create", "status", "animate", "download", "sheets", "balance", "create-pro", "preview"])
    ap.add_argument("--only")
    ap.add_argument("--seed", type=int, default=0)
    args = ap.parse_args()
    if args.cmd == "refs":
        make_refs(args.only, args.seed)
    elif args.cmd == "create":
        create()
    elif args.cmd == "status":
        status()
    elif args.cmd == "balance":
        print(call("balance", method="GET"))
    elif args.cmd == "download":
        download()
    elif args.cmd == "sheets":
        sheets()
    elif args.cmd == "animate":
        animate(args.only)
    elif args.cmd == "create-pro":
        create_pro(args.only)
    elif args.cmd == "preview":
        preview(args.only or "rowan_pro")


# (name, template_id or None, action_description or None, directions)
# template availability differs per skeleton (probed):
#   mannequin: walk, breathing-idle, cross-punch, taking-punch, crouching, crouched-walking, ...
#   dog: walk-4-frames, idle, bark, sneaking, fast-walk, running-*
ANIMATIONS = {
    "rowan_pro": [
        ("walk", "walk", None, ["south", "north", "east", "west"]),
        ("idle", "breathing-idle", None, ["south", "north", "east", "west"]),
        ("attack", "cross-punch", None, ["south", "north", "east", "west"]),
        ("hurt", "taking-punch", None, ["south"]),
        ("crouch", "crouching", None, ["south"]),
    ],
    "briar_pro": [
        ("walk", "walk-4-frames", None, ["south", "north", "east", "west"]),
        ("sit", None, "sitting down attentively, tail curled around paws", ["south"]),
        ("bark", "bark", None, ["east"]),
        ("cower", "sneaking", None, ["south"]),
        ("dig", None, "digging energetically in the dirt with front paws", ["east"]),
        ("growl", None, "growling with hackles raised, head low, body tense, fixed stare", ["south", "north", "east", "west"]),
        ("lie_down", None, "lying down calmly, head resting on front paws", ["south"]),
        ("head_bump", None, "quick affectionate forward head nudge against a friend", ["east"]),
    ],
    "twisted_pro": [
        ("walk", "crouched-walking", None, ["south", "north", "east", "west"]),
        ("idle", "breathing-idle", None, ["south"]),
        ("lunge", None, "sudden forward lunge with long arms outstretched", ["east"]),
        ("stilled", None, "sitting down calmly hugging a small wooden duck toy", ["south"]),
        ("hurt", "taking-punch", None, ["south"]),
        ("crumble", None, "slowly collapsing into a limp heap of rags and dust", ["south"]),
    ],
    "rowan": [
        ("walk", "walk", None, ["south", "north", "east", "west"]),
        ("idle", "breathing-idle", None, ["south"]),
        ("attack", "cross-punch", None, ["south", "north", "east", "west"]),
        ("hurt", "taking-punch", None, ["south"]),
        ("crouch", "crouching", None, ["south"]),
    ],
    "briar": [
        ("walk", "walk-4-frames", None, ["south", "north", "east", "west"]),
        ("idle", "idle", None, ["south"]),
        ("bark", "bark", None, ["east"]),
        ("cower", "sneaking", None, ["south"]),
        ("dig", None, "digging energetically in the dirt with front paws", ["east"]),
    ],
    "twisted": [
        ("walk", "crouched-walking", None, ["south", "north", "east", "west"]),
        ("idle", "breathing-idle", None, ["south"]),
        ("lunge", None, "sudden forward lunge with long arms outstretched", ["east"]),
        ("stilled", None, "sitting down calmly hugging a small wooden duck toy", ["south"]),
    ],
}


def animate(only: str | None) -> None:
    st = state()
    for char, anims in ANIMATIONS.items():
        if only and char != only:
            continue
        cid = st.get(char, {}).get("character_id")
        if not cid:
            print(f"{char}: no character yet")
            continue
        for name, template, action, directions in anims:
            # free accounts have 2 concurrent slots — chunk directions in pairs
            for chunk_start in range(0, len(directions), 2):
                chunk = directions[chunk_start:chunk_start + 2]
                key = f"anim_job_{name}_{'_'.join(chunk)}"
                if st[char].get(key):
                    print(f"skip {char}/{name} {chunk} (queued)")
                    continue
                payload: dict = {
                    "character_id": cid,
                    "animation_name": name,
                    "directions": chunk,
                }
                if template:
                    payload["mode"] = "template"
                    payload["template_animation_id"] = template
                else:
                    payload["mode"] = "v3"
                    payload["action_description"] = action
                    payload["frame_count"] = 4
                for attempt in range(40):
                    try:
                        call("animate-character", payload)
                        st[char][key] = "queued"
                        print(f"{char}/{name} {chunk}: queued")
                        save_state(st)
                        break
                    except RuntimeError as e:
                        if "429" in str(e):
                            time.sleep(75)
                            continue
                        raise
    print("balance:", call("balance", method="GET"))


def download() -> None:
    import io
    import zipfile
    st = state()
    for char, info in st.items():
        cid = info.get("character_id")
        if not cid:
            continue
        dest = OUT / "chars" / char
        dest.mkdir(parents=True, exist_ok=True)
        data = get_bytes(f"characters/{cid}/zip")
        with zipfile.ZipFile(io.BytesIO(data)) as zf:
            zf.extractall(dest)
        names = [n for n in sorted(Path(dest).rglob("*")) if n.is_file()]
        print(f"{char}: {len(names)} files")
        for n in names[:12]:
            print("  ", n.relative_to(dest))


if __name__ == "__main__":
    main()
