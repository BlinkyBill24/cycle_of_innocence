---
name: Librarian pass — solo-dev setup & Godot Web research
date: 2026-06-20
branch: docs/research-solo-dev-setup
tags: [session, research, librarian, process, web-export]
---

# 2026-06-20 — Librarian pass: solo-dev setup & Godot 4.4 Web

Processed `docs/research/2026-06-20-solo-dev-project-setup-godot-web.md`. The note is
overwhelmingly **process/setup that endorses existing rules** — no new mechanics, no
locked decision reopened. Applied 4 integrations (proposed first, user approved "apply all 4"):

1. **Stale Aseprite fix** — `docs/home.md` and the roadmap A1 row said "Aseprite";
   corrected to GIMP/Pixelorama + PixelLab ("no Aseprite installed"), matching the locked
   toolchain. (Two lines — same compliance fix; flagged.)
2. **Web-audio de-risk task** → `docs/ideas.md`: export to the Web target and confirm the
   adaptive stems start only after a click and crossfade acceptably (browsers block audio
   until first interaction; in-editor doesn't prove Web). Load-bearing for dread; distinct
   from the existing Sample-mode-safe note.
3. **Playtest `[FLAG]`** → `docs/plan/playtest-protocol-2026-06.md`: ~5 testers validates
   *usability*, not *tone/dread* — atmosphere needs more, varied testers over time.
4. **Process references** → roadmap: Derek Yu "Finishing a Game" + NN/g "5 users".

Endorsed-as-is (no change): folder structure, autoloads, LimboAI-on-Web (already proven),
`.gitignore` (`.godot/`/`exports/` already ignored), slice definition, content-complete rule.
Stardew/Undertale date nitpicks are about the source doc — no COI doc cites them, so no edit.

Provenance: set `status: integrated`, added an integration note resolving the verify-on-
integration checklist, moved the file to `docs/research/done/`.
