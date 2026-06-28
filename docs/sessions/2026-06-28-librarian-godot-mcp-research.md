---
name: 2026-06-28-librarian-godot-mcp-research
date: 2026-06-28
tags: [session, librarian, tooling, mcp]
---

# 2026-06-28 — Librarian pass: Godot MCP servers research

## What I did
Processed the research inbox file `Claude-Godot-MCP-Servers-Research-2026-06-28.md`
(single-pass claude.ai research on Godot MCP servers — workflow tooling, not a
game feature, so the four-pillar filter doesn't apply; filter was "does it reduce
wiring failures / blind guessing").

Three integrations applied (proposed first, then approved):

1. **`docs/design/ai-production-setup.md`** — corrected the "Code agents" stack row
   + the "Installed in this repo" note to reflect reality + add a `[FLAG 2026-06-28]`
   upgrade path. Key fact surfaced: the **installed** server is `Coding-Solo/godot-mcp`
   v0.1.1 (confirmed from `.mcp.json` → `/home/seitanist/godot-mcp` + its `package.json`
   homepage). It **runs the game + reads console errors but cannot see the live runtime
   tree or autoload state** (DreadManager/HollowingClock/VillageState etc.), and carries
   an unpatched command-injection advisory (issue #64 — localhost-only, low risk solo).
2. **`docs/ideas.md`** — new dated section "(Godot MCP tooling, 2026-06-28)" capturing
   the actionable next step: evaluate adding a runtime-visibility server. Preference:
   (1) `Erodenn/godot-mcp-runtime` (nothing ships in web/Android export → best fit for
   the hard Web constraint); (2) `PrajnaAvidya/Godot-Peek-MCP` (more debug power but
   ships an export-exclude addon, Linux x86_64-only — verify on Mint). Avoid
   `IvanMurzak/Godot-MCP` (C#/.NET → breaks Web export). Payoff: settles the *wiring*
   half of the Briar "yellow blob" + locked-door "no feedback" diagnoses.
3. **Inbox housekeeping** — set `status: integrated`, moved the file to
   `docs/research/done/` (plain `mv`; file was untracked, so `git mv` didn't apply).

## Not done (deliberate)
- No decision record written — nothing is decided yet; this is research feeding a
  future task, so it lives in the ideas inbox until greenlit.
- Did **not** install/swap any MCP server (real task with export implications).
- Did not reopen the locked Web-export / no-C# constraints (the report respects them).

## Notes
- Done on branch `art/briar-puppy-versions` (which carries unrelated in-progress art
  work). Docs-only changes; not committed (user didn't ask).
