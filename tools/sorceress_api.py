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
    timeout: float = 120.0,
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
        err_body = e.read().decode()[:600]
        sys.exit(f"Sorceress API {e.code} on {path}: {err_body}")


def get(path: str) -> dict:
    return _request("GET", path)


def post(path: str, payload: dict | None = None) -> dict:
    return _request("POST", path, payload)


def wait_job(
    job_id: str,
    *,
    poll_s: float = 2.0,
    timeout_s: float = 300.0,
) -> dict:
    """Poll GET /jobs/:id until succeeded|failed or timeout."""
    deadline = time.time() + timeout_s
    last: dict = {}
    while time.time() < deadline:
        last = get(f"jobs/{job_id}")
        # Shapes seen/docs: {status}, {data:{status}}, {job:{status}}
        status = (
            last.get("status")
            or (last.get("data") or {}).get("status")
            or (last.get("job") or {}).get("status")
            or ""
        )
        status = str(status).lower()
        if status in ("succeeded", "success", "completed", "done", "failed", "error"):
            return last
        time.sleep(poll_s)
    sys.exit(f"job {job_id} still processing after {timeout_s}s: {json.dumps(last)[:400]}")


def _first_image_url(result: dict) -> str | None:
    """Best-effort extract of a downloadable image URL from invoke/job JSON."""
    if not isinstance(result, dict):
        return None
    for key in ("url", "imageUrl", "image_url", "resultUrl"):
        v = result.get(key)
        if isinstance(v, str) and v.startswith("http"):
            return v
    data = result.get("data") if isinstance(result.get("data"), dict) else {}
    for key in ("url", "imageUrl", "image_url", "resultUrl"):
        v = data.get(key)
        if isinstance(v, str) and v.startswith("http"):
            return v
    images = result.get("images") or data.get("images") or []
    if isinstance(images, list) and images:
        first = images[0]
        if isinstance(first, str) and first.startswith("http"):
            return first
        if isinstance(first, dict):
            for key in ("url", "imageUrl", "image_url"):
                v = first.get(key)
                if isinstance(v, str) and v.startswith("http"):
                    return v
    # nested result
    nested = data.get("result") if isinstance(data.get("result"), dict) else result.get("result")
    if isinstance(nested, dict):
        return _first_image_url(nested)
    return None


def download(url: str, out: Path) -> None:
    req = urllib.request.Request(url, headers={"Accept": "*/*"})
    with urllib.request.urlopen(req, timeout=120) as resp:
        out.write_bytes(resp.read())
    print(f"wrote {out} ({out.stat().st_size} bytes)")


def cmd_ping(_: argparse.Namespace) -> None:
    r = post("tools/ping", {"message": "cycle-of-innocence"})
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
    print(json.dumps(r, indent=2)[:4000])


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

    print(f"POST tools/image_generate model={args.model} …", flush=True)
    r = post("tools/image_generate", payload)
    print(json.dumps({k: r.get(k) for k in ("ok", "tool", "creditsCharged", "error", "message")}, indent=2))

    job_id = (
        r.get("jobId")
        or r.get("job_id")
        or (r.get("data") or {}).get("jobId")
        or (r.get("data") or {}).get("job_id")
        or (r.get("data") or {}).get("id")
    )
    final = r
    if job_id:
        print(f"polling job {job_id} …", flush=True)
        final = wait_job(str(job_id), poll_s=args.poll, timeout_s=args.timeout)
        status = (
            final.get("status")
            or (final.get("data") or {}).get("status")
            or ""
        )
        print(f"job status={status}", flush=True)

    url = _first_image_url(final) or _first_image_url(r)
    if not url:
        # dump for debugging (no secrets)
        dump = json.dumps(final, indent=2)
        print(dump[:3000])
        sys.exit("no image URL in response — inspect dump above")

    if args.out:
        out = Path(args.out)
        out.parent.mkdir(parents=True, exist_ok=True)
        download(url, out)
    else:
        print(url)


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__)
    sub = ap.add_subparsers(dest="cmd", required=True)

    sub.add_parser("ping", help="Auth + connectivity check").set_defaults(func=cmd_ping)
    sub.add_parser("tools", help="List tool catalog").set_defaults(func=cmd_tools)

    j = sub.add_parser("job", help="GET one job by id")
    j.add_argument("job_id")
    j.set_defaults(func=cmd_job)

    img = sub.add_parser("image", help="image_generate (async → download)")
    img.add_argument("prompt")
    img.add_argument(
        "--model",
        default="grok-imagine",
        help="Model id from discovery (default: grok-imagine)",
    )
    img.add_argument("--aspect", default="1:1")
    img.add_argument("--params-json", default="", help='e.g. \'{"quality":"low"}\'')
    img.add_argument("--ref", action="append", default=[], help="Reference image URL (repeatable)")
    img.add_argument("--out", default="", help="Write PNG path")
    img.add_argument("--poll", type=float, default=2.0)
    img.add_argument("--timeout", type=float, default=300.0)
    img.set_defaults(func=cmd_image)

    args = ap.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
