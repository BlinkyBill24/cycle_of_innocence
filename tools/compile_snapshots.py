#!/usr/bin/env python3
"""compile_snapshots.py — build the claude.ai bridge snapshots in docs/_compiled/.

The Obsidian vault (docs/) is the single source of truth. This script compiles
it into four replace-only snapshot files that get uploaded as project knowledge
to the claude.ai Project "Cycle of Innocence — Design & Research". The snapshots
are GENERATED; never hand-edit them and never edit them in claude.ai.

Run from anywhere: python3 tools/compile_snapshots.py
"""
from __future__ import annotations

import datetime
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent  # test/
DOCS = ROOT / "docs"
OUT = DOCS / "_compiled"

# Snapshot -> ordered list of source globs/paths (relative to test/).
SNAPSHOTS: dict[str, list[str]] = {
    "story-compendium.md": [
        "docs/story/bible.md",
        "docs/story/endings.md",
        "docs/story/choice-matrix.md",
        "docs/characters/companions.md",
    ],
    "mechanics-compendium.md": [
        "docs/mechanics/*.md",
        "docs/design/*.md",
    ],
    "decisions.md": [
        "docs/decisions/*.md",
    ],
    "state-and-roadmap.md": [
        "AGENTS.md",
        "docs/plan/*.md",
        "docs/ideas.md",
        "SESSIONS_LATEST",  # sentinel: newest two session journals
    ],
}

TITLES = {
    "story-compendium.md": "Story & Characters — bible, endings, choice matrix, companions",
    "mechanics-compendium.md": "Mechanics & Design — all mechanics specs and design docs (frontmatter `status:` = implementation state)",
    "decisions.md": "Decisions — architecture/process decision records, oldest first",
    "state-and-roadmap.md": "Project State & Roadmap — canonical brain (AGENTS.md), roadmap, ideas inbox, latest session journals",
}


def resolve(sources: list[str]) -> list[Path]:
    files: list[Path] = []
    for src in sources:
        if src == "SESSIONS_LATEST":
            sessions = sorted((DOCS / "sessions").glob("*.md"), reverse=True)[:2]
            files.extend(sessions)
        elif "*" in src:
            files.extend(sorted(ROOT.glob(src)))
        else:
            p = ROOT / src
            if not p.exists():
                print(f"WARN: missing source {src}", file=sys.stderr)
                continue
            files.append(p)
    return files


def compile_snapshot(name: str, sources: list[str], stamp: str) -> None:
    files = resolve(sources)
    parts = [
        f"# {TITLES[name]}\n",
        f"> GENERATED {stamp} by tools/compile_snapshots.py — do NOT edit "
        "(not here, not in claude.ai). Source of truth is the Obsidian vault "
        "in the game repo; this file is replaced wholesale at milestones.\n",
        "> Sources: " + ", ".join(str(f.relative_to(ROOT)) for f in files) + "\n",
    ]
    for f in files:
        rel = f.relative_to(ROOT)
        parts.append(f"\n\n{'=' * 70}\nSOURCE: {rel}\n{'=' * 70}\n\n")
        parts.append(f.read_text(encoding="utf-8").strip() + "\n")
    out = OUT / name
    out.write_text("".join(parts), encoding="utf-8")
    print(f"  {out.relative_to(ROOT)}  ({out.stat().st_size // 1024} KB, {len(files)} sources)")


def main() -> None:
    OUT.mkdir(exist_ok=True)
    stamp = datetime.date.today().isoformat()
    print("Compiling claude.ai snapshots:")
    for name, sources in SNAPSHOTS.items():
        compile_snapshot(name, sources, stamp)
    print("Done. Upload the changed files to the claude.ai Project knowledge "
          "(replacing all four never hurts).")


if __name__ == "__main__":
    main()
