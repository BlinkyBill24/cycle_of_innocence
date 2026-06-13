#!/usr/bin/env python3
"""Generate inventory item ICONS via PixelLab /v2/map-objects basic mode (no
background -> real alpha). Icons are iconographic (side view), 48x48, limited
palette — they are UI sprites, not world props, so they are NOT palette-locked
to a zone backdrop (items read clearly in the satchel; cf. the toy_duck
saturation exemption). Output: assets/sprites/items/<id>.png."""
import base64, json, time, urllib.request
from pathlib import Path

KEY = (Path.home() / ".config/pixellab/api_key").read_text().strip()
BASE = "https://api.pixellab.ai"
OUT = Path("assets/sprites/items")

# id -> (view, description)  — short object descriptions; style comes from params
ICONS = {
    "dried_meat":    ("side", "a strip of dried cured jerky meat, frayed dark red-brown edges, single food item"),
    "forest_berries":("side", "a small cluster of dark wild forest berries on a short sprig with two leaves, deep purple-red"),
    "sturdy_stick":  ("side", "a stout broken tree branch used as a makeshift club, rough bark, one splintered end, brown"),
    "slingshot":     ("side", "a Y-shaped hand-whittled wooden slingshot with a stretched leather band, a child's makeshift weapon"),
    "sling_stones":  ("high top-down", "a small pile of three smooth rounded grey throwing pebbles"),
    "buried_bone":   ("side", "an old weathered dug-up animal bone caked with dark soil, gnawed, off-white"),
    "tin_locket":    ("side", "a small tarnished heart-shaped tin locket on a broken chain, caked with grave soil, a child's keepsake"),
}


def post(payload):
    req = urllib.request.Request(f"{BASE}/v2/map-objects",
        data=json.dumps(payload).encode(),
        headers={"Authorization": f"Bearer {KEY}", "Content-Type": "application/json"},
        method="POST")
    with urllib.request.urlopen(req, timeout=120) as r:
        return json.load(r)["object_id"]


def try_download(oid, dest):
    req = urllib.request.Request(f"{BASE}/mcp/map-objects/{oid}/download",
        headers={"Authorization": f"Bearer {KEY}"})
    try:
        with urllib.request.urlopen(req, timeout=60) as r:
            data = r.read()
        if data[:8] == b"\x89PNG\r\n\x1a\n":
            dest.write_bytes(data)
            return True
    except Exception:
        pass
    return False


OUT.mkdir(parents=True, exist_ok=True)
jobs = {}
for name, (view, desc) in ICONS.items():
    jobs[name] = post({
        "description": desc,
        "image_size": {"width": 48, "height": 48},
        "view": view,
        "outline": "single color outline",
        "shading": "basic shading",
        "detail": "medium detail",
    })
    print(f"submitted {name}: {jobs[name]}", flush=True)

pending = set(jobs)
for _ in range(40):
    time.sleep(8)
    for name in list(pending):
        if try_download(jobs[name], OUT / f"{name}_raw.png"):
            print(f"downloaded {name}", flush=True)
            pending.discard(name)
    if not pending:
        break
    print("waiting:", pending, flush=True)
print("remaining:", pending or "none")
