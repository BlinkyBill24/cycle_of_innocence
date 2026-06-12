# System Setup & Replication Guide — Cycle of Innocence Design System
**Obsidian vault · Claude Code CLI · claude.ai Project — Linux Mint / Synology**

> Lives at `docs/setup-guide.md` so it syncs and survives with the vault.
> **Status:** adapted 2026-06-12 from the space-game design-system guide to the
> Cycle of Innocence project. Where the two projects differ, THIS file is
> correct for this project.
>
> **Key difference from the space-game system:** this project is already in
> active development with a canonical brain (`AGENTS.md`) and git history, so
> the vault was NOT restructured into numbered folders and git is NOT parked.
> The system here adds two things around the existing vault: the **compiled
> snapshot bridge** to a claude.ai Project (research instrument) and the
> **research inbox** for the return path. Operational rules live in `AGENTS.md`
> (R1–R7); this guide covers bootstrap, reconnection, and replication only.

---

## A. The system at a glance

| Component | Role |
|---|---|
| **Obsidian vault** `~/game/test/docs` (in the git repo, Synology-synced via the repo checkout) | Single source of truth: story (`story/`, `characters/`), mechanics & design specs (`mechanics/`, `design/`), decisions (`decisions/`), research inbox (`research/`), roadmap (`plan/`), journal (`sessions/`), ideas inbox (`ideas.md`) |
| **`AGENTS.md`** (repo root `test/`) | Canonical brain for ALL AI tools — identity, locked stack, rules R1–R7, tool roles. Vault = knowledge, AGENTS.md = rules |
| **Claude Code CLI** (run in `test/`) | Hub + implementation + **librarian**: processes the research inbox, audits, runs `compile`, commits — governed by AGENTS.md (imported via CLAUDE.md) |
| **claude.ai Project** "Cycle of Innocence — Design & Research" | Research instrument & design thinking partner, grounded in the `docs/_compiled/` snapshots — the **shared brain's web-facing half** |
| **`docs/_compiled/` snapshots** (4 files) | The bridge: story-compendium · mechanics-compendium · decisions · state-and-roadmap — generated only (`python3 tools/compile_snapshots.py`), replace-only |

Git: **active** (unlike the space-game system) — R1 branch discipline, R6
commit-and-push; the user merges. `_compiled/` is committed so any machine (or
GitHub directly) can supply the upload files.

---

## B. One-time setup / reconnection

### B1. Claude account (claude.ai)
1. Plan: **Pro** (Research feature, Projects, top models, Claude Code).
2. Settings → Capabilities: enable web search, search & reference chats, memory, artifacts.
3. Settings → Profile → preferences — **universal content only** (project identity lives in project instructions):
   > I'm based in Austria and use Linux (Mint) across multiple machines synced via a Synology NAS. I'm comfortable in German and English — answer in whichever language I use. Be direct: give recommendations with reasoning, not just lists of options. Cite sources I can verify, and flag uncertain or possibly outdated information.

### B2. Vault on a machine
1. Clone/sync the repo (`github.com/tchintchie/game`); the vault is `test/docs/`. Let Synology/git sync settle before opening.
2. Install Obsidian → Open `test/docs` as vault.
3. Python 3 present (for `tools/compile_snapshots.py` and `../scripts/obsidian/status.py`).
4. Sync hygiene: don't keep the vault open in Obsidian on two machines simultaneously; exclude `.obsidian/workspace*` from sync if the client supports filters.

### B3. Claude Code CLI
1. Install Claude Code and log in with the same account.
2. Run `claude` **in `test/`** — `CLAUDE.md` imports `AGENTS.md` automatically; rules, tool roles, and hooks (branch guard) come from there. No standing prompt needed.
3. Smoke test: `bash tools/check-brain.sh` green + ask Claude Code to "compile the snapshots" → 4 files regenerate in `docs/_compiled/`.

### B4. claude.ai Project
1. Create Project **"Cycle of Innocence — Design & Research"**.
2. Project instructions — current canonical text:
   > I'm a solo indie game developer building **Cycle of Innocence**, a 2D top-down horror-conspiracy action RPG (Godot 4.4 typed GDScript, 32×32 pixel art, Dialogue Manager + LimboAI addons, targets Linux/Android/Web — Web is a hard constraint, so no C#). This project supports its design and research. The single source of truth is my local Obsidian vault in the game repo; the four files in project knowledge are compiled snapshots from it — never edit them here, they get replaced at milestones. Treat the locked tech stack and recorded decisions as locked unless I explicitly reopen one, and respect the guardrails: no procedural-NPC/nemesis-like systems (WB patent), no radial emotion-mapped dialogue wheels (BioWare patent), no reuse of my earlier cozy-game mechanics. When researching other games or design topics, map findings to transferable mechanics, note which existing systems each would stand on (GameEvents bus, PlayerData age/morality/companions, DreadManager, HollowingClock, VillageState suspicion/routines, ZoneManager + zone recontextualization, Dialogue Manager balloons, companion bond/corruption, mercy/soothe combat, SaveManager, adaptive audio stems), and end with a clear recommendation. Filter everything through: does it serve story, a companion arc, a horror beat, or replay value — flag anything that fails the filter instead of recommending it. When research results are meant for the vault, output them as an inbox file: provenance frontmatter (name, date, source, prompt, status: inbox) plus findings with [verified YYYY-MM-DD] / [training knowledge] reliability markers — never as Claude Code instructions; the vault's own conventions govern integration.
3. Project knowledge: upload the four files from `docs/_compiled/` — nothing else.
4. Verification test in a fresh project chat: *"Which mechanics stand on the HollowingClock, and what would a new player-visible doom presentation have to respect?"* — a grounded answer (stage-keyed villager routines/gossip, monster un-stilling on Frenzy, emergency-ritual child, night floor + detection scaling, diegetic-presentation rule: bells/posters not HUD) proves the bridge works.
5. Optionally move design conversations into the project (chat search is project-scoped).

---

## C. The workflow (the shared-brain loop)

1. **Research** in the claude.ai project (quick chats, or "+ → Research" for deep dossiers, ~1–2/week). Per project instructions, vault-bound results arrive as **inbox-formatted output** with reliability markers.
2. **Inbox:** save as `docs/research/YYYY-MM-DD-topic.md` (provenance header, body verbatim). Convention: `docs/research/README.md`.
3. **Librarian:** in Claude Code — *"Process the inbox: read docs/research/[file]. Propose integrations — new/updated mechanics or design docs, decision records, ideas-inbox entries, story flags. Show me the full proposal before applying anything."* Locked decisions get flags, not edits; markers preserved; rejected ideas land in `docs/ideas.md` with reasons. Integrated files move to `docs/research/done/`.
4. **Compile & sync** when a change set is milestone-worthy: `python3 tools/compile_snapshots.py` → replace the changed snapshots in project knowledge (replacing all four never hurts). Natural milestone = a merged PR that touched docs.
5. **Status changes** on mechanics docs (`planned → implemented` etc.) are deliberate acts via the librarian/implementation PRs; superseded docs are marked, never deleted.
6. **Audits**: `bash tools/check-brain.sh` (brain drift) + `python3 ../scripts/obsidian/status.py` (vault health) at session close — both already required by the completion checklist.

**Division of labour in the shared brain:** claude.ai = outward-looking
(market/genre research, design sparring, long-form dossiers — it sees snapshots,
never the repo). Claude Code = inward-looking (implementation, tests, vault
integration, snapshot generation — it sees everything). The vault is the brain;
the snapshots are its projection; the inbox is the only door back in.

---

## D. Replication & recovery scenarios

**New machine:** B2 + B3 (repo brings vault AND snapshots; Obsidian + Claude Code; same account). Nothing else — the vault and AGENTS.md self-describe.

**Disaster recovery:** the git repo is everything (GitHub + Synology + working copies). `docs/_compiled/` regenerates via the compile script; the claude.ai Project is recreated in 10 minutes from B4.

**Second project on this architecture:** copy the skeleton (AGENTS.md structure, `docs/_templates/`, `tools/compile_snapshots.py` with adjusted source lists, `docs/research/README.md`); write new project instructions per B4. The conventions transfer; the content doesn't.

**Account change / fresh Claude setup:** B1 + B3-login + B4 — vault untouched.

---

## E. Pointers (don't duplicate, read there)

- Rules & tool roles: `AGENTS.md` (repo root — the canonical brain)
- Research inbox convention & librarian prompt: `docs/research/README.md`
- Compile source lists: `tools/compile_snapshots.py` (top of file)
- Roadmap: `docs/plan/slice-implementation-roadmap.md` · Story: `docs/story/bible.md`
- Decision record for this system: `docs/decisions/2026-06-12-web-research-bridge.md`
