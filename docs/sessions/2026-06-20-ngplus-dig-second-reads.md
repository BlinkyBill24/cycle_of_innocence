---
name: NG+ second-reads for the dig fragments
date: 2026-06-20
branch: feature/ngplus-dig-second-reads
tags: [session, ngplus, recontext, digs, content-complete, fringes]
---

# 2026-06-20 — NG+ second-reads for the dig fragments (content-complete, item 3)

## What I did
Wired `lore_text_recontext` + `recontext_revelation = monsters_are_children`
onto the two fringes dig fragments (no new mechanic — same `DiggableSpot.choose_lore`
NG+ gate the rabbit already uses):
- **DiggableSpotFringes** — the too-small child's shoe.
- **StilledChildKeepsake** — the wooden duck.

## ✅ Already done (flagged)
The third fragment — the **playground rabbit** (`DiggableSpotPlayground`, "Mara —
Harmony 71") — already carried its second-read from an earlier pass, so I left it
untouched. All three of the slice's dig fragments now NG+-recontextualize on the
same gate.

## ⚠ Placeholder strings (yours to write)
Both new second-reads are **`TODO(lore):`** placeholders; the carried-into-NG+
meaning is bible lore for you to supply. The plain first-reads are unchanged.

## Tests
`test_doom_signals.gd`: both fringes digs read plainly before the revelation and
second-read once `monsters_are_children` is known; and the gate **survives a save
round-trip** (`SaveManager.save_game`/`load_game`). Suite **300 green**; check-brain green.
