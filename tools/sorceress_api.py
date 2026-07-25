#!/usr/bin/env python3
"""Thin Sorceress Tool API client (https://sorceress.games/api/v1).

Auth: SORCERESS_API_KEY env var, or ~/.config/sorceress/api_key (NEVER in repo).
Pattern matches tools/pixellab_api.py.

Live base (verified 2026-07-25):
  GET  /api/v1/tools              — catalog
  POST /api/v1/tools/<tool_id>   — invoke (JSON body = tool params)
  GET  /api/v1/jobs/<job_id>     — poll async jobs

Examples:
  python3 tools/sorceress_api.py ping
  python3 tools/sorceress_api.py tools
  python3 tools/sorceress_api.py image "pixel dog" --model grok-imagine --out dog.png
  python3 tools/sorceress_api.py sfx "locked door rattle" --out door.mp3
  python3 tools/sorceress_api.py call autosprite_list
"""
from __future__ import annotations

import argparse
import json
import os
import sys
import time
import urllib.error
import urllib.request
from pathlib import Path
from typing import Any

BASE = "https://sorceress.games/api/v1"


def api_key() -> str:
    key = os.environ.get("SORCERESS_API_KEY", "")
    if not key:
        path = Path.home() / ".config" / "sorceress" / "api_key"
        if path.exists():
            key = path.read_text().strip()
    if not key:
        sys.exit(
            "no API key: set SORCERESS_API_KEY or ~/.config/sorceress/api_key"
        )
    return key


def _request(
    method: str,
    path: str,
    payload: dict | None = None,
    timeout: float = 180.0,
) -> dict:
    url = f"{BASE}/{path.lstrip('/')}"
    data = None if payload is None else json.dumps(payload).encode()
    req = urllib.request.Request(
        url,
        data=data,
        headers={
            "Authorization": f"Bearer {api_key()}",
            "Content-Type": "application/json",
            "Accept": "application/json",
        },
        method=method,
    )
    try:
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            body = resp.read().decode()
            return json.loads(body) if body else {}
    except urllib.error.HTTPError as e:
        err_body = e.read().decode()[:800]
        sys.exit(f"Sorceress API {e.code} on {path}: {err_body}")


def get(path: str) -> dict:
    return _request("GET", path)


def post(path: str, payload: dict | None = None) -> dict:
    return _request("POST", path, payload)


def invoke(tool_id: str, payload: dict | None = None) -> dict:
    return post(f"tools/{tool_id}", payload or {})


def _status(blob: dict) -> str:
    return str(
        blob.get("status")
        or (blob.get("data") or {}).get("status")
        or (blob.get("job") or {}).get("status")
        or ""
    ).lower()


def _job_id(blob: dict) -> str | None:
    data = blob.get("data") if isinstance(blob.get("data"), dict) else {}
    for candidate in (
        blob.get("jobId"),
        blob.get("job_id"),
        data.get("jobId"),
        data.get("job_id"),
        data.get("id"),
        blob.get("id"),
    ):
        if candidate:
            return str(candidate)
    # animate may return jobIds[]
    for key in ("jobIds", "jobs"):
        arr = data.get(key) or blob.get(key)
        if isinstance(arr, list) and arr:
            first = arr[0]
            if isinstance(first, str):
                return first
            if isinstance(first, dict):
                return str(first.get("jobId") or first.get("id") or "")
    return None


def wait_job(
    job_id: str,
    *,
    poll_s: float = 3.0,
    timeout_s: float = 600.0,
) -> dict:
    """Poll GET /jobs/:id until succeeded|failed or timeout."""
    deadline = time.time() + timeout_s
    last: dict = {}
    while time.time() < deadline:
        last = get(f"jobs/{job_id}")
        status = _status(last)
        if status in ("succeeded", "success", "completed", "done", "failed", "error"):
            return last
        # progress log (Corridor Key can take minutes)
        prog = (last.get("data") or {}).get("progress") or last.get("progress")
        if prog is not None:
            print(f"  job {job_id[:8]}… status={status or 'processing'} progress={prog}", flush=True)
        else:
            print(f"  job {job_id[:8]}… status={status or 'processing'}", flush=True)
        time.sleep(poll_s)
    sys.exit(f"job {job_id} still processing after {timeout_s}s: {json.dumps(last)[:400]}")


def _walk_urls(obj: Any, out: list[str]) -> None:
    if isinstance(obj, dict):
        for k, v in obj.items():
            if isinstance(v, str) and v.startswith("http") and any(
                x in k.lower()
                for x in (
                    "url",
                    "image",
                    "audio",
                    "media",
                    "sprite",
                    "sheet",
                    "track",
                    "mp3",
                    "mp4",
                    "png",
                )
            ):
                out.append(v)
            else:
                _walk_urls(v, out)
    elif isinstance(obj, list):
        for item in obj:
            _walk_urls(item, out)


def first_media_url(result: dict, prefer: tuple[str, ...] = ()) -> str | None:
    """Prefer keys matching prefer substrings, else first http media-ish URL."""
    # direct preferential keys
    prefer_keys = prefer or (
        "spriteSheetUrl",
        "spritesheeturl",
        "audioUrl",
        "audio_url",
        "imageUrl",
        "image_url",
        "mediaUrl",
        "url",
    )
    flat: list[tuple[str, str]] = []

    def collect(obj: Any, prefix: str = "") -> None:
        if isinstance(obj, dict):
            for k, v in obj.items():
                path = f"{prefix}.{k}" if prefix else k
                if isinstance(v, str) and v.startswith("http"):
                    flat.append((path.lower(), v))
                else:
                    collect(v, path)
        elif isinstance(obj, list):
            for i, item in enumerate(obj):
                collect(item, f"{prefix}[{i}]")

    collect(result)
    for want in prefer_keys:
        w = want.lower()
        for path, url in flat:
            if w in path:
                return url
    return flat[0][1] if flat else None


def download(url: str, out: Path) -> None:
    out.parent.mkdir(parents=True, exist_ok=True)
    req = urllib.request.Request(url, headers={"Accept": "*/*"})
    with urllib.request.urlopen(req, timeout=180) as resp:
        out.write_bytes(resp.read())
    print(f"wrote {out} ({out.stat().st_size} bytes)")


def invoke_and_wait(
    tool_id: str,
    payload: dict,
    *,
    poll_s: float = 3.0,
    timeout_s: float = 600.0,
) -> dict:
    print(f"POST tools/{tool_id} …", flush=True)
    r = invoke(tool_id, payload)
    print(
        json.dumps(
            {k: r.get(k) for k in ("ok", "tool", "creditsCharged", "error", "message")},
            indent=2,
        ),
        flush=True,
    )
    if r.get("ok") is False:
        sys.exit(json.dumps(r, indent=2)[:800])

    # Multi-job responses (e.g. animate batch)
    data = r.get("data") if isinstance(r.get("data"), dict) else {}
    job_ids: list[str] = []
    jid = _job_id(r)
    if jid:
        job_ids.append(jid)
    for key in ("jobIds", "jobs"):
        arr = data.get(key) or r.get(key)
        if isinstance(arr, list):
            for item in arr:
                if isinstance(item, str):
                    job_ids.append(item)
                elif isinstance(item, dict):
                    x = item.get("jobId") or item.get("id")
                    if x:
                        job_ids.append(str(x))

    # de-dupe
    seen: set[str] = set()
    uniq = []
    for j in job_ids:
        if j and j not in seen:
            seen.add(j)
            uniq.append(j)

    if not uniq:
        return r  # sync tool

    finals = []
    for j in uniq:
        print(f"polling job {j} …", flush=True)
        final = wait_job(j, poll_s=poll_s, timeout_s=timeout_s)
        st = _status(final)
        print(f"job {j} status={st}", flush=True)
        if st in ("failed", "error"):
            print(json.dumps(final, indent=2)[:1500])
            sys.exit(f"job failed: {j}")
        finals.append(final)
    if len(finals) == 1:
        return finals[0]
    return {"ok": True, "jobs": finals, "data": {"jobs": finals}}


def cmd_ping(_: argparse.Namespace) -> None:
    r = invoke("ping", {"message": "cycle-of-innocence"})
    print(json.dumps(r, indent=2))


def cmd_tools(_: argparse.Namespace) -> None:
    r = get("tools")
    tools = r.get("tools") or []
    for t in tools:
        print(
            f"{t.get('id'):28} status={t.get('status')} enabled={t.get('enabled')}  {t.get('label', '')}"
        )
    if not tools:
        print(json.dumps(r, indent=2)[:2000])


def cmd_job(args: argparse.Namespace) -> None:
    r = get(f"jobs/{args.job_id}")
    print(json.dumps(r, indent=2)[:6000])


def cmd_call(args: argparse.Namespace) -> None:
    payload = json.loads(args.json) if args.json else {}
    r = invoke_and_wait(
        args.tool_id,
        payload,
        poll_s=args.poll,
        timeout_s=args.timeout,
    )
    print(json.dumps(r, indent=2)[:8000])
    if args.out:
        url = first_media_url(r)
        if not url:
            sys.exit("no media URL to download")
        download(url, Path(args.out))


def cmd_image(args: argparse.Namespace) -> None:
    payload: dict = {
        "model": args.model,
        "prompt": args.prompt,
        "aspectRatio": args.aspect,
    }
    if args.params_json:
        payload["params"] = json.loads(args.params_json)
    if args.ref:
        payload["refImages"] = list(args.ref)

    final = invoke_and_wait(
        "image_generate",
        payload,
        poll_s=args.poll,
        timeout_s=args.timeout,
    )
    url = first_media_url(final, prefer=("imageUrl", "url", "images"))
    if not url:
        print(json.dumps(final, indent=2)[:3000])
        sys.exit("no image URL in response")
    if args.out:
        download(url, Path(args.out))
    else:
        print(url)
    # also print URL for chaining create_character
    print(f"IMAGE_URL={url}")


def cmd_sfx(args: argparse.Namespace) -> None:
    payload: dict = {"prompt": args.prompt}
    if args.duration is not None:
        payload["targetDuration"] = args.duration
    final = invoke_and_wait(
        "sfx_generate",
        payload,
        poll_s=args.poll,
        timeout_s=args.timeout,
    )
    url = first_media_url(final, prefer=("audioUrl", "audio", "url", "mp3"))
    if not url:
        print(json.dumps(final, indent=2)[:3000])
        sys.exit("no audio URL in response")
    if args.out:
        download(url, Path(args.out))
    else:
        print(url)


def cmd_as_create(args: argparse.Namespace) -> None:
    payload: dict = {"imageUrl": args.image_url, "name": args.name}
    if args.prompt:
        payload["prompt"] = args.prompt
    r = invoke("autosprite_create_character", payload)
    print(json.dumps(r, indent=2)[:4000])
    data = r.get("data") if isinstance(r.get("data"), dict) else {}
    asset = (
        data.get("assetId")
        or data.get("characterAssetId")
        or data.get("id")
        or r.get("assetId")
    )
    if asset:
        print(f"CHARACTER_ASSET_ID={asset}")


def cmd_as_animate(args: argparse.Namespace) -> None:
    anims = json.loads(args.animations_json)
    payload: dict = {
        "characterAssetId": args.character_asset_id,
        "animations": anims,
        "model": args.model,
        "resolution": args.resolution,
    }
    final = invoke_and_wait(
        "autosprite_animate",
        payload,
        poll_s=args.poll,
        timeout_s=args.timeout,
    )
    print(json.dumps(final, indent=2)[:5000])
    # try extract animation asset ids for keying
    urls: list[str] = []
    _walk_urls(final, urls)
    for u in urls[:8]:
        print(f"MEDIA={u}")


def cmd_as_key(args: argparse.Namespace) -> None:
    payload: dict = {}
    if args.asset_id:
        payload["assetId"] = args.asset_id
    if args.asset_ids:
        payload["assetIds"] = list(args.asset_ids)
    if args.sample_every:
        payload["sampleEvery"] = args.sample_every
    final = invoke_and_wait(
        "autosprite_key",
        payload,
        poll_s=args.poll,
        timeout_s=args.timeout,
    )
    print(json.dumps(final, indent=2)[:5000])
    url = first_media_url(final, prefer=("spriteSheetUrl", "spritesheet", "url"))
    if url and args.out:
        download(url, Path(args.out))
    elif url:
        print(f"SPRITESHEET_URL={url}")


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__)
    sub = ap.add_subparsers(dest="cmd", required=True)

    sub.add_parser("ping", help="Auth + connectivity check").set_defaults(func=cmd_ping)
    sub.add_parser("tools", help="List tool catalog").set_defaults(func=cmd_tools)

    j = sub.add_parser("job", help="GET one job by id")
    j.add_argument("job_id")
    j.set_defaults(func=cmd_job)

    c = sub.add_parser("call", help="Invoke any tool id with JSON body")
    c.add_argument("tool_id")
    c.add_argument("--json", default="{}", help="JSON object body")
    c.add_argument("--out", default="")
    c.add_argument("--poll", type=float, default=3.0)
    c.add_argument("--timeout", type=float, default=600.0)
    c.set_defaults(func=cmd_call)

    img = sub.add_parser("image", help="image_generate (async → download)")
    img.add_argument("prompt")
    img.add_argument("--model", default="grok-imagine", help="e.g. grok-imagine")
    img.add_argument("--aspect", default="1:1")
    img.add_argument("--params-json", default="")
    img.add_argument("--ref", action="append", default=[], help="Reference image URL")
    img.add_argument("--out", default="")
    img.add_argument("--poll", type=float, default=2.0)
    img.add_argument("--timeout", type=float, default=360.0)
    img.set_defaults(func=cmd_image)

    sfx = sub.add_parser("sfx", help="sfx_generate (async → download mp3)")
    sfx.add_argument("prompt")
    sfx.add_argument("--duration", type=float, default=3.0)
    sfx.add_argument("--out", default="")
    sfx.add_argument("--poll", type=float, default=2.0)
    sfx.add_argument("--timeout", type=float, default=300.0)
    sfx.set_defaults(func=cmd_sfx)

    asc = sub.add_parser("as-create", help="autosprite_create_character")
    asc.add_argument("image_url")
    asc.add_argument("--name", default="BriarV2Probe")
    asc.add_argument("--prompt", default="")
    asc.set_defaults(func=cmd_as_create)

    asa = sub.add_parser("as-animate", help="autosprite_animate")
    asa.add_argument("character_asset_id")
    asa.add_argument(
        "--animations-json",
        required=True,
        help='e.g. \'[{"label":"walk","prompt":"walk cycle loop","duration":4}]\'',
    )
    asa.add_argument("--model", default="imagine-1.5", help="imagine-1.5 or wan-2.7")
    asa.add_argument("--resolution", default="720p")
    asa.add_argument("--poll", type=float, default=4.0)
    asa.add_argument("--timeout", type=float, default=900.0)
    asa.set_defaults(func=cmd_as_animate)

    ask = sub.add_parser("as-key", help="autosprite_key (Corridor Key → sheet)")
    ask.add_argument("--asset-id", default="")
    ask.add_argument("--asset-ids", action="append", default=[])
    ask.add_argument("--sample-every", type=int, default=8)
    ask.add_argument("--out", default="")
    ask.add_argument("--poll", type=float, default=5.0)
    ask.add_argument("--timeout", type=float, default=1200.0)
    ask.set_defaults(func=cmd_as_key)

    args = ap.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
