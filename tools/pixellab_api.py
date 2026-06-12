#!/usr/bin/env python3
"""Thin PixelLab API client (api.pixellab.ai/v1).

Auth: PIXELLAB_API_KEY env var, or ~/.config/pixellab/api_key (NEVER in repo).
Endpoints: generate-image-pixflux, generate-image-bitforge (reference-styled),
animate-with-skeleton, animate-with-text, rotate, inpaint, estimate-skeleton.

Usage examples:
  python3 tools/pixellab_api.py balance
  python3 tools/pixellab_api.py generate "small dog, side view" --size 32 --out dog.png
  python3 tools/pixellab_api.py rotate --image dog.png --out dog_dirs.png
"""
import argparse
import base64
import json
import os
import sys
import urllib.request
from pathlib import Path

BASE = "https://api.pixellab.ai/v1"

# Projection Canon (docs/art/prop-coherence.md rule 5): one camera for the
# whole game. EVERY generation call that takes a view passes this explicitly —
# PixelLab per-tool defaults differ (map tools: high top-down; character
# tools: low top-down). check-brain.sh lints tools/*.py for off-canon views;
# a deliberate exception needs a `# canon-override:` comment on the line.
CANON_VIEW = "low top-down"


def api_key() -> str:
    key = os.environ.get("PIXELLAB_API_KEY", "")
    if not key:
        path = Path.home() / ".config" / "pixellab" / "api_key"
        if path.exists():
            key = path.read_text().strip()
    if not key:
        sys.exit("no API key: set PIXELLAB_API_KEY or ~/.config/pixellab/api_key")
    return key


def call(endpoint: str, payload: dict | None = None, method: str = "POST") -> dict:
    req = urllib.request.Request(
        f"{BASE}/{endpoint.lstrip('/')}",
        data=json.dumps(payload).encode() if payload is not None else None,
        headers={
            "Authorization": f"Bearer {api_key()}",
            "Content-Type": "application/json",
        },
        method=method,
    )
    try:
        with urllib.request.urlopen(req, timeout=300) as resp:
            return json.load(resp)
    except urllib.error.HTTPError as e:
        sys.exit(f"PixelLab API {e.code} on {endpoint}: {e.read().decode()[:400]}")


def b64_image(path: str) -> dict:
    return {"type": "base64", "base64": base64.b64encode(Path(path).read_bytes()).decode()}


def save_images(result: dict, out: str) -> None:
    images = result.get("images") or ([result["image"]] if "image" in result else [])
    for i, img in enumerate(images):
        data = base64.b64decode(img["base64"] if isinstance(img, dict) else img)
        path = out if len(images) == 1 else out.replace(".png", f"_{i}.png")
        Path(path).write_bytes(data)
        print(f"wrote {path}")


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__)
    sub = ap.add_subparsers(dest="cmd", required=True)

    sub.add_parser("balance")

    gen = sub.add_parser("generate", help="generate-image-pixflux")
    gen.add_argument("description")
    gen.add_argument("--size", type=int, default=32)
    gen.add_argument("--out", default="pixellab_out.png")
    gen.add_argument("--no-bg", action="store_true", help="transparent background")

    rot = sub.add_parser("rotate", help="4/8-direction rotation from one sprite")
    rot.add_argument("--image", required=True)
    rot.add_argument("--size", type=int, default=32)
    rot.add_argument("--out", default="pixellab_rotated.png")

    args = ap.parse_args()
    if args.cmd == "balance":
        print(call("balance", method="GET"))
    elif args.cmd == "generate":
        result = call("generate-image-pixflux", {
            "description": args.description,
            "image_size": {"width": args.size, "height": args.size},
            "no_background": args.no_bg,
        })
        save_images(result, args.out)
    elif args.cmd == "rotate":
        result = call("rotate", {
            "image_size": {"width": args.size, "height": args.size},
            "from_image": b64_image(args.image),
        })
        save_images(result, args.out)


if __name__ == "__main__":
    main()
