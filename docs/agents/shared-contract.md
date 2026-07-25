---
name: Shared agent contract — Cycle of Innocence
tags: [agents, contract]
---

# Shared agent contract

**Every role skill must obey this.** Role skills add a job card; they never replace the brain.

## Single brain

1. **Canonical rules:** root `AGENTS.md` (R1–R7, stack, identity, patent posture).
2. **Story canon:** `docs/story/bible.md` + linked character/mechanics docs.
3. **Locked choices:** `docs/decisions/` — if a decision exists, follow it; to reverse it, write a new decision, do not silent-edit.
4. **Status map:** `STATE.md` (lean web snapshot) + `docs/handbook.md`.

Do **not** invent a second lore, stack, or companion cast.

## Always-on process

| Rule | Meaning |
|------|---------|
| **R1** | Branch before any change (`feature/…`, `fix/…`, `docs/…`, `chore/…`). Never commit to `main`. |
| **R2** | Read this contract + `AGENTS.md` + the role’s “Read first” list before editing. |
| **R3** | Deliver an F5-playable (or clearly doc-only) slice — not a 40-file system. |
| **R4** | Art is Imagine-first; log prompts in `docs/art/imagine-prompts.md`; nearest-filter import. |
| **R5** | Own session journal: `docs/sessions/YYYY-MM-DD-<slug>.md`. Stray ideas → `docs/ideas.md`. |
| **R6** | Commit + push on the feature branch when work is meaningful. Merge via Forgejo PR tools, not local main commits. |
| **R7** | Research lands in `docs/research/` first; librarian path before canon edits. |

## Hard bans (all roles)

- No reuse of the Mote / “Echoes of the Verdant Realm” cozy game (only low-level 2D patterns).
- No procedural NPC hierarchy / ranks / “nemesis system” framing (patent posture).
- No radial emotion dialogue wheel UI before the patent window ends — list balloons as built.
- No runtime LLM calls in the shipped game.
- No C# / .NET (Web export is a hard constraint). Godot **4.4.x** standard + typed GDScript.
- Storm (mount) is **cut** — traversal is level design, not a companion.
- Companions are **authored characters** (Briar + Echo by design), not generated parties.
- Do not put API keys in the repo (`~/.config/…` only).

## Proof over claims

- Code paths: `bash tools/run-tests.sh` (and `bash tools/playtest_smoke.sh` when critical path / zones change).
- Live wiring: Godot MCP runtime when available (`run_project` → `run_script` / screenshot) — do not run shell smoke concurrent with an active MCP `run_project`.
- Feel (dread, bond, difficulty, “does this read at game scale?”): **human F5** — agents mark it as a human gate, never fake it.

## Communication

Explain in **plain language** for a non-developer first (what changed, what it means, what to do next). Jargon only with a short definition. Deep detail optional at the end.

## Role card shape (every skill)

Each role skill is a job contract:

1. **Mission** — one deliverable sentence  
2. **Read first** — short path list  
3. **May edit** — allowed paths / asset types  
4. **Must not** — role-specific bans  
5. **Done when** — checks a human or script can verify  
6. **Output** — journal + branch-sized change  

When the user invokes a role, **stay in role** until they end the task or switch roles. Hand off cleanly: name the next role if the work leaves your lane.
