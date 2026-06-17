#!/usr/bin/env python3
"""status.py — repo + docs-vault health snapshot. Run at checkpoints / session close.
Exit 1 (RED) if on main/master; otherwise GREEN with notes. No deps beyond stdlib+git."""
from __future__ import annotations
import subprocess, datetime, sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DOCS = ROOT / "docs"
G, R, Y, O = "\033[32m", "\033[31m", "\033[33m", "\033[0m"

def git(*a: str) -> str:
    return subprocess.run(["git", "-C", str(ROOT), *a],
                          capture_output=True, text=True).stdout.strip()

def n(sub: str, pat: str = "*.md") -> int:
    d = DOCS / sub
    return len([p for p in d.glob(pat) if p.name.lower() != "readme.md"]) if d.is_dir() else 0

branch = git("rev-parse", "--abbrev-ref", "HEAD") or "?"
head = git("log", "-1", "--pretty=%h %s")
dirty = [l for l in git("status", "--porcelain").splitlines() if l.strip()]
today = datetime.date.today().isoformat()
today_journal = list((DOCS / "sessions").glob(f"{today}-*.md")) if (DOCS / "sessions").is_dir() else []
warn: list[str] = []

def row(label: str, val, ok: bool = True, note: str = "") -> None:
    col = G if ok else R
    print(f"  {label:<24}{col}{val}{O}{('  ' + Y + note + O) if note else ''}")

print("\nCycle of Innocence — status\n")
on_main = branch in ("main", "master")
row("branch", branch, not on_main, "← branch before committing (R1)" if on_main else "")
if on_main: warn.append("on main/master — create a feature branch (R1)")
row("HEAD", head or "(none)")
row("decisions", n("decisions"))
row("features", n("features"))
row("sessions", n("sessions"))
row("uncommitted files", len(dirty), len(dirty) == 0)
row("today's journal", "yes" if today_journal else "none yet",
    True, "" if today_journal else "← write at session end (R5)")
print()
if warn:
    print(f"{R}OVERALL  RED{O}")
    for w in warn:
        print(f"  - {w}")
    sys.exit(1)
print(f"{G}OVERALL  GREEN{O}\n")
