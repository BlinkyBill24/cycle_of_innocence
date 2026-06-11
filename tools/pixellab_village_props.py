#!/usr/bin/env python3
"""Village zone props via create-image-pixflux (sync — safe to run while
background jobs render). Palette-anchored to the approved mood shot
(village_dusk_mood.png) so buildings match the establishing art.

Usage: python3 tools/pixellab_village_props.py [--only NAME]
"""
import argparse
import base64
import io
import json
import sys
import urllib.request
from pathlib import Path

from PIL import Image

sys.path.insert(0, str(Path(__file__).parent))
from pixellab_v2 import call as _call, BASE  # noqa: E402
from pixellab_api import api_key  # noqa: E402


def call(endpoint: str, payload: dict | None = None, method: str = "POST") -> dict:
    """Like pixellab_v2.call but with a 15-min timeout — sync pixflux renders
    block behind the background-job queue (observed 2026-06-11)."""
    req = urllib.request.Request(
        f"{BASE}/{endpoint.lstrip('/')}",
        data=json.dumps(payload).encode() if payload is not None else None,
        headers={"Authorization": f"Bearer {api_key()}", "Content-Type": "application/json"},
        method=method,
    )
    with urllib.request.urlopen(req, timeout=900) as resp:
        return json.load(resp)

OUT = Path("assets/sprites/village")
MOOD = "assets/reference/village_dusk_mood.png"
STYLE = ("retro pixel art, SNES-style top-down RPG building, half-timbered "
         "thatched rural village, muted dusk palette, crisp pixels, "
         "no anti-aliasing, single object centered")

# name: (width, height, description)  — free-tier canvas area cap is 200x200
PROPS = {
    "cottage_a": (128, 112,
        "small half-timbered cottage with steep thatched roof, front facade "
        "with door and two warm lit windows, stone foundation"),
    "cottage_b": (128, 104,
        "half-timbered cottage with thatched roof and side chimney, front "
        "facade with door, one shuttered window and one lit window"),
    "cottage_dark": (128, 104,
        "half-timbered cottage with thatched roof, front facade with closed "
        "door, all windows dark and shuttered, slightly unkempt"),
    "chapel": (144, 160,
        "small village chapel with wooden bell tower, steep shingled roof, "
        "arched door, round window, weathered stone walls"),
    "well": (48, 48,
        "round stone village well with wooden roof post and bucket on a rope"),
    "market_stall": (96, 72,
        "wooden market stall with striped fabric awning, crates and baskets "
        "of vegetables on the counter"),
    "fence": (64, 24,
        "rustic wooden fence segment, two rails on three posts, slightly "
        "crooked"),
    "lantern_post": (24, 56,
        "wooden lantern post with a glowing round paper lantern hanging from "
        "a bracket"),
    "bench": (48, 24,
        "simple weathered wooden bench"),
    "harmony_board": (40, 56,
        "village notice board on two posts with pinned paper lists and a "
        "carved sun emblem on top, festive ribbon on one corner"),
}


def mood_palette_b64() -> dict:
    img = Image.open(MOOD).convert("RGB").resize((64, 64), Image.BOX)
    buf = io.BytesIO()
    img.save(buf, "PNG")
    return {"type": "base64", "base64": base64.b64encode(buf.getvalue()).decode()}


def generate(only: str | None = None) -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    palette = mood_palette_b64()
    for name, (w, h, desc) in PROPS.items():
        if only and name != only:
            continue
        path = OUT / f"{name}.png"
        if path.exists() and not only:
            print(f"skip {name} (exists)")
            continue
        result = call("create-image-pixflux", {
            "description": f"{desc}, {STYLE}",
            "image_size": {"width": w, "height": h},
            "no_background": True,
            "view": "low top-down",
            "color_image": palette,
        })
        path.write_bytes(base64.b64decode((result.get("image") or {})["base64"]))
        print(f"{name}: {path}", flush=True)
    _preview()
    print("balance:", call("balance", method="GET")["credits"]["usd"])


def _preview() -> None:
    imgs = [(n, Image.open(OUT / f"{n}.png").convert("RGBA"))
            for n in PROPS if (OUT / f"{n}.png").exists()]
    if not imgs:
        return
    gap = 10
    width = sum(i.width for _, i in imgs) + gap * (len(imgs) + 1)
    height = max(i.height for _, i in imgs) + gap * 2
    strip = Image.new("RGBA", (width, height), (45, 45, 55, 255))
    x = gap
    for _, img in imgs:
        strip.paste(img, (x, height - gap - img.height), img)
        x += img.width + gap
    strip.resize((int(strip.width * 1.5), int(strip.height * 1.5)), Image.NEAREST).save(
        OUT / "_village_props_preview.png")
    print(f"preview: {OUT / '_village_props_preview.png'}")


if __name__ == "__main__":
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--only")
    args = ap.parse_args()
    generate(args.only)
