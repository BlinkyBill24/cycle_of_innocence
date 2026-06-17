#!/usr/bin/env python3
"""digest.py — regenerate docs/_digest/index.md: a compact, link-rich index of the
vault for quick orientation. Idempotent (full regen each run). Invoked by the
post-commit git hook and runnable by hand. Never writes outside docs/_digest/."""
from __future__ import annotations
import datetime
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DOCS = ROOT / "docs"

def title(p: Path) -> str:
    try:
        for line in p.read_text(errors="ignore").splitlines():
            if line.startswith("# "):
                return line[2:].strip()
    except OSError:
        pass
    return p.stem

def recent(sub: str, k: int = 8):
    d = DOCS / sub
    if not d.is_dir():
        return []
    files = sorted((p for p in d.glob("*.md") if p.name.lower() != "readme.md"),
                   key=lambda p: p.name, reverse=True)
    return files[:k]

out = ["---", "name: Digest (auto-generated — do not edit)", "tags: [digest, auto]", "---", "",
       "# Digest",
       f"_Regenerated {datetime.date.today().isoformat()} by `tools/digest.py`. Do not hand-edit._", ""]
for label, sub in [("Recent decisions", "decisions"), ("Features", "features"),
                   ("Recent sessions", "sessions")]:
    out.append(f"## {label}")
    items = recent(sub)
    out += [f"- [{title(f)}](../{sub}/{f.name})" for f in items] or ["- _(none yet)_"]
    out.append("")
ideas = DOCS / "ideas.md"
if ideas.is_file():
    cap = sum(1 for l in ideas.read_text(errors="ignore").splitlines() if l.strip().startswith("- "))
    out += [f"## Ideas inbox", f"- {cap} captured items in [ideas.md](../ideas.md)", ""]

(DOCS / "_digest").mkdir(parents=True, exist_ok=True)
(DOCS / "_digest" / "index.md").write_text("\n".join(out) + "\n")
print("regenerated docs/_digest/index.md")
