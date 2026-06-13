#!/usr/bin/env python3
"""session_digest.py — read all per-session journals for a day at once.

Per-session journals (R5) live as docs/sessions/YYYY-MM-DD-<slug>.md so parallel
sessions never collide on one file. This concatenates a day's files into one
read (the "what happened today" view), newest-modified first.

Usage:
  python3 tools/session_digest.py            # today
  python3 tools/session_digest.py 2026-06-13 # a specific day
"""
from __future__ import annotations

import datetime
import sys
from pathlib import Path

SESSIONS = Path(__file__).resolve().parent.parent / "docs" / "sessions"


def main() -> None:
    day = sys.argv[1] if len(sys.argv) > 1 else datetime.date.today().isoformat()
    # the per-session files for the day, plus a legacy bare YYYY-MM-DD.md
    files = sorted(
        SESSIONS.glob(f"{day}*.md"),
        key=lambda p: p.stat().st_mtime,
        reverse=True,
    )
    if not files:
        print(f"No session journals for {day} in {SESSIONS}/")
        return
    print(f"# Session digest — {day}  ({len(files)} session file(s))\n")
    for f in files:
        print(f"\n{'=' * 72}\n## {f.name}\n{'=' * 72}\n")
        print(f.read_text(encoding="utf-8").strip())


if __name__ == "__main__":
    main()
