---
name: Solo Indie Dev — Project Setup, Workflow & Godot 4.4 Web Production (Vertical-Slice Stage)
date: 2026-06-20
source: "Grok (project_setup.md, user-provided) expanded + verified via Claude web research"
prompt: "Based on Grok's project-setup findings, further expand research on solo-dev project setup and how to apply it to Cycle of Innocence. Split into (A) workflow/milestone practice and (B) Godot 4.4 + Web production setup, tailored to a project STILL PROVING ITS VERTICAL SLICE. Verify/correct the Grok document. Deliver as a vault-ready inbox note."
status: integrated
related: "[[plan/slice-implementation-roadmap]] · [[plan/playtest-protocol-2026-06]] · [[design/game-features]] · [[AGENTS.md]]"
---

> **Librarian pass — integrated 2026-06-20** (branch `docs/research-solo-dev-setup`).
> Almost entirely process/setup that *endorses* existing rules — no new mechanics, no
> locked decision reopened. Applied:
> 1. Fixed the stale **"Aseprite"** toolchain references (`docs/home.md`, and the
>    `slice-implementation-roadmap` A1 row) → GIMP/Pixelorama + PixelLab, "no Aseprite installed".
> 2. Added a **de-risk Web audio in an exported build** task → [[ideas]] (load-bearing for dread).
> 3. Added a `[FLAG]` caveat to [[plan/playtest-protocol-2026-06]]: ~5 testers validates
>    *usability*, not *tone/dread*.
> 4. Added **Derek Yu "Finishing a Game"** + **NN/g "5 users"** to the roadmap's references.
>
> Verify-on-integration checklist (below): the Stardew/Undertale date items are about the
> *source* doc — **no COI doc cites them**, so no vault edit needed. `.godot/`/`exports/` are
> already gitignored. LimboAI-on-Web already proven (2026-06-20). Exact source URLs left as the
> note records them; not re-pinned. Folder structure & autoloads endorsed (kept, no restructure).

# Solo Indie Dev — Project Setup, Workflow & Godot 4.4 Web Production

> **Inbox note for librarian triage.** Reliability markers, inline:
> - `[verified 2026-06-20]` = rests on a citable source I'm confident exists and was checked this session.
> - `[cross-model]` = Grok asserted it **and** Claude's research independently supports it.
> - `[training knowledge]` = established/general practice, not re-pinned to a specific source this session.
> - `[FLAG]` = uncertain, overstated, wrong, or contradicts COI's actual setup — needs a decision on integration.
>
> Exact source URLs and the two date figures (Stardew/Undertale) should be spot-checked before this leaves the inbox — see "Verify on integration" at the end.

---

## TL;DR for where COI is right now (still proving the slice)

- The Grok document is **mostly right and mostly already what you do** — vertical-slice-first, iterate, control scope, track in Obsidian, test Web early. `[cross-model]`
- Its main weaknesses are **survivorship-bias framing** ("passion beats planning") and **two setup details that don't match your real project** (it assumes Aseprite; it doesn't address whether your addons survive Web export). `[FLAG]`
- The single most useful *new* thing for you: **before you scope the slice any further, prove the risky Web pieces actually work in an exported Web build.** Your addon (LimboAI) is already confirmed Web-safe; **Web audio is the most common thing left that breaks.** `[verified 2026-06-20]`
- Your own existing rules (content-complete-per-zone, the slice gate "did the choice matter / did dread land / did the bond feel real", the drafted playtest protocol) are *better discipline* than the romantic "just keep iterating" advice. Keep them.

---

## Verdict on the Grok document (what's right, overstated, wrong)

**Correct, and worth keeping** `[cross-model]`:
- Vertical-slice-first is the make-or-break early milestone for solo devs.
- Iterative "build one system/zone deep, polish, move on, revisit" matches how shipped solo games were actually made.
- Ruthless scope control + a per-task filter (does it serve story / companion / horror / replay).
- Obsidian for milestones, tasks, living bible.
- Test the Web build from day one.
- The phase ladder Research → Pre-Production (Vertical Slice) → Production (Feature Complete → Content Complete) → Polish is the standard production framing. `[training knowledge]`

**Overstated / missing nuance** `[FLAG]`:
- *"Passion + iterative slicing beats perfect upfront planning."* Half-true. The honest version: you need **enough** design to know your core loop and tone, **then** iterate — and the thing that actually ships a game is **deliberate cutting**, not passion. Stardew and Undertale are survivorship outliers; most projects that "just followed passion" did not finish. Treat them as inspiration, not as a method. `[training knowledge]`
- *Stardew "~4.5 years" and Undertale "~3 years."* Roughly in the right range but loose — see corrections below. `[FLAG]`

**Wrong / mismatched with your actual project** `[FLAG]`:
- The recommended folder structure lists **"Aseprite 32×32 exports."** You do **not** use Aseprite (your toolchain is GIMP / Pixelorama / scripted pixel cleanup, plus PixelLab for generation). Any setup doc derived from this must not assume Aseprite. `[verified 2026-06-20 — your own vault/AGENTS toolchain]`
- The folder structure is **generic and doesn't reflect what you already have** (GameEvents bus, PlayerData, DreadManager, HollowingClock, VillageState, ZoneManager, SaveManager autoloads already exist). Don't reorganize to match a template — your structure is already further along than the example. `[verified 2026-06-20 — your vault]`
- Grok marks LimboAI "locked" but **never checks whether it exports to Web** — the one question that actually mattered for your hard constraint. It does (see Track B). `[verified 2026-06-20]`

**Date corrections** (Grok's two examples):
- **Stardew Valley** — Eric Barone began ~2011–2012, released Feb 2016; commonly cited as **~4–5 years** solo. "~4.5" is within range but cite a real interview, not a round number. He also famously **redrew the art many times** (the iteration point Grok makes is sound). `[training knowledge]` `[FLAG: pin exact start date on integration]`
- **Undertale** — Kickstarter mid-2013, released **15 Sept 2015**. Often summarized as **~32 months / ~2.7 years**, not "~3 years," and the art help (Temmie Chang) was real but limited. Grok's "~3 years, mostly solo with limited art help" is *close enough to true* but the number should be tightened. `[training knowledge]` `[FLAG: confirm 32-month figure]`

---

## TRACK A — Workflow & milestone practice (process, not game mechanics)

### A1. What a "vertical slice" actually is — and what it isn't
- A **vertical slice** is a *small but complete, shippable-quality* cross-section of the final game: one short stretch where **every layer is present at the same time** — art, audio, a real mechanic, UI, save — and it *feels like the finished game*. `[training knowledge]`
- A **prototype** is the opposite: throwaway, ugly-is-fine, exists only to answer one risky question ("does soothing a monster feel good?"). `[training knowledge]`
- **Pitfall:** conflating the two, or letting the slice quietly grow into "the whole first hour." Keep the slice to ~10–20 minutes, one zone. Grok keeps these separate (Phase 1 prototypes vs Phase 2 slice) — that's correct; just hold the line on size. `[cross-model]`
- **Maps to your project:** your AGENTS slice definition (child Rowan + Briar, playground→fringes, one real choice, one dread beat, one mercy resolution, save, Web export <10s) is already a textbook slice. You don't need to re-scope it; you need to *finish proving it*. `[verified 2026-06-20 — your vault]`

### A2. Scope control & finishing (the part that actually ships games)
- The most-cited solo-dev wisdom on this is **Derek Yu's essay "Finishing a Game"** — scope down hard, finish the thing, a finished small game beats an unfinished big one. Highly recommended as a vault reference. `[verified 2026-06-20 — Derek Yu, "Finishing a Game" (makegames blog); widely cited]`
- **Survivorship-bias warning:** Stardew/Undertale are the games people *remember*; thousands of equally passionate projects died mid-development. The lesson is not "work hard and it'll happen" — it's "cut relentlessly and finish." `[training knowledge]`
- **Your content-complete-per-zone rule already encodes this.** It is *more* disciplined than the Grok advice. Keep it. `[verified 2026-06-20 — your vault]`

### A3. Avoiding burnout / sustainable pace (solo-specific)
- **Weekly themes over daily to-do lists** is a real, commonly-recommended solo practice — pick a focus for the week (systems / art-integration / dialogue / playtest) instead of a guilt-inducing daily checklist. Reduces context-switching and pressure. `[training knowledge]` `[cross-model]`
- **Role-cycling** (code → art → story → playtest) keeps a solo dev from staring at one hard problem too long. `[training knowledge]`
- Build in breaks and small celebrations at milestones; intense crunch periods (Stardew) are common but are a *risk*, not a model to copy. `[training knowledge]`
- *Filter note:* this is pure process — the story/companion/horror/replay filter doesn't apply.

### A4. Milestone gating — when is the slice "done"?
- Standard exit criteria: **Feature Complete (Alpha)** = all core systems exist and the golden path is playable; **Content Complete (Beta)** = all story/zones/arcs in, a new player can finish; then **Polish**. `[training knowledge]`
- **For a *slice* specifically, the exit test is qualitative, not a checklist.** Your own gate is the right kind: *did the choice matter, did dread land, did the bond feel real?* Add one practical line: *did it run on the Web target at an acceptable load time?* (You already have <10s in AGENTS.) `[verified 2026-06-20 — your vault]`
- **Don't move from slice → production until the slice passes its gate with outside testers**, not just you. (You've drafted exactly this.) `[cross-model]`

### A5. Playtesting a vertical slice (and a horror one specifically)
- **Small-n is fine and expected.** The classic usability finding is that **~5 testers surface the large majority of usability problems** (Nielsen Norman Group). Borrow it, but with a caveat. `[verified 2026-06-20 — NN/g "Why You Only Need to Test with 5 Users"]`
- **Caveat / `[FLAG]`:** that "5 users" rule is about *usability* (can they operate it), **not** about *fun or atmosphere*. Whether dread *lands* is a different question and needs more, varied testers over time. Don't over-trust 5 testers on tone.
- **Observe, don't coach.** A stuck tester is data. Record the session if you can; watch where they look. `[training knowledge]`
- **For horror, measure where dread *lands* vs where it *dissipates*** — the exact thing to log. Your drafted protocol already does this; this research confirms it's the right instrument. `[cross-model]`
- **Maps to your project:** [[plan/playtest-protocol-2026-06]] is already aligned with best practice. No change needed; just run it.

### A6. Upfront planning vs iterative discovery — what credible sources actually say
- The defensible middle: **plan enough to lock the core promise and the core verbs; discover the rest by building and playing.** `[training knowledge]`
- Lock your "verbs" (move, interact, choose, dread-response, soothe/mercy) at the *end* of the slice, not the start — let the slice tell you how they should feel, then freeze them before content production. This is consistent with Grok and with standard production guidance. `[cross-model]`

---

## TRACK B — Godot 4.4 + Web production setup (technical; kept brief, Details optional)

> Plain framing: most of this **confirms what you already have**. The new, important parts are the three Web "lock these in early" items (B2) and the addon-on-Web confirmation (B3).

### B1. Project / folder / scene organization
- Godot is deliberately flexible about structure. The common, recommended pattern is exactly yours: **autoloads (always-loaded global scripts) for an event bus and managers, scenes grouped by feature, and Resources (`.tres` data files) for configuration/state.** `[verified 2026-06-20 — Godot docs, "Project organization" / "Best practices"]`
- **Recommendation: do not restructure to match Grok's template.** Your autoload set (GameEvents, PlayerData, DreadManager, HollowingClock, VillageState, ZoneManager, SaveManager, adaptive audio) is already the idiomatic shape. `[verified 2026-06-20 — your vault]`

### B2. Web/HTML5 export — the things that affect architecture *early*
These are the ones worth knowing *now* because they're expensive to retrofit:
- **Rendering:** Godot 4.x Web export runs on the **Compatibility renderer** (WebGL2-class). Design visuals/shaders to that, not to the desktop renderers. `[verified 2026-06-20 — Godot docs, "Exporting for the web"]`
- **Threading (multi-core):** Web threading needs `SharedArrayBuffer`, which needs the server to send **cross-origin isolation headers (COOP/COEP)**. Many simple hosts (and some itch.io setups) don't, so you often ship the **single-threaded** export. **Practical takeaway: don't architect anything that *requires* background threads.** `[verified 2026-06-20 — Godot docs, "Exporting for the web"]`
- **Audio (most likely thing left to break):** browsers **block audio until the first user interaction**, and Web audio has higher latency/quirks. Your hand-rolled adaptive-stem system must (a) not try to play before a click/tap, and (b) tolerate crossfade timing being looser on Web. **Test this in an actual exported build, not just in-editor.** `[verified 2026-06-20 — browser autoplay policy is standard; Godot Web audio caveats in docs]`
- **Payload size:** keep the initial download small (aim tens of MB), since players wait for it before anything starts. Compressed textures / WebP help. `[training knowledge]` `[cross-model — matches your vault's "tens of MB" note]`
- **Browser differences:** test **Firefox and Chromium first**; Safari's WebGL2 has more quirks. `[training knowledge]` `[cross-model — your vault]`

### B3. Your addons on Web (the question Grok skipped)
- **LimboAI is a GDExtension** (native compiled code, not pure GDScript), so it only works on Web if a Web-compatible build is bundled. **Confirmed: LimboAI exports cleanly to Web in your setup** — a headless release export succeeds and bundles the LimboAI Web `.wasm`. `[verified 2026-06-20 — your own vault test, 2026-06-20]`
- **Dialogue Manager** is GDScript-based, so no native-build concern on Web. `[training knowledge]`

### B4. Version control habits for Godot
- Use a Godot-appropriate **`.gitignore`**: ignore the **`.godot/`** folder (Godot 4.x import/cache, regenerated automatically) and export output; **do** commit your source, scenes, and `.import` settings. Godot's docs publish a recommended ignore list. `[verified 2026-06-20 — Godot docs, version control / standard Godot .gitignore]`
- **Commit per small feature/milestone with descriptive messages.** You already go further (branch-per-feature, R1) — keep it. `[cross-model]`
- Binary assets (PNGs, audio) live in Git fine at your scale; only consider Git LFS if the repo balloons. `[training knowledge]`

### B5. Godot 4.4 gotchas worth knowing (beginner-relevant)
- **Typed GDScript:** when reading from a Dictionary or an untyped value you usually need to **state the type explicitly** (your AGENTS already notes this). `[verified 2026-06-20 — your vault; consistent with Godot 4.x typing behavior]`
- **Autoload order matters:** a manager that depends on another must load after it. `[training knowledge]`
- **Re-export and re-test on Web after addon or engine bumps** — addon builds are pinned to the engine version; bump them together. `[training knowledge]` `[cross-model — your vault pins addon↔engine versions]`

*Details (optional, deeper): "cross-origin isolation" just means the web page is served with two special HTTP headers that tell the browser it's safe to use shared memory across threads; without them the browser disables `SharedArrayBuffer`, and Godot falls back to single-thread. This is purely a hosting/header concern, not a code change — but it's why "it threaded fine on desktop" doesn't guarantee Web.*

---

## Design-filter pass (story / companion / horror / replay)

Almost everything above is **process and setup, so the filter mostly doesn't apply** — there's no game mechanic to judge. The two places it *does* touch design:
- **The slice must contain one real horror beat + one companion moment** to be a valid slice. That's the filter built into the milestone itself — your slice definition already satisfies it. ✔ serves *horror* + *companion arc*.
- **Web-audio reliability is a horror dependency**, not just a tech chore: if the adaptive stems don't play on Web, the dread doesn't land. So "prove Web audio" quietly serves the *horror* pillar. ✔
- Nothing here introduces a mechanic that *fails* the filter, and nothing touches the patent/cozy-reuse guardrails.

---

## Recommendation (what to actually do next)

1. **De-risk Web before scoping further (this week).** LimboAI-on-Web is already proven; **the open risk is audio.** Export the current build to Web and confirm the adaptive stems start (after a click) and crossfade acceptably. If they don't, that's your next fix — it's load-bearing for dread. `[verified 2026-06-20]`
2. **Keep the slice small; resist polishing it to death.** Its job is to prove tone + loop + pipeline, then you *lock the verbs*. Don't let it grow into the first hour. `[cross-model]`
3. **Run the playtest protocol you already drafted**, with 3–5 outside testers, and specifically log **where dread lands vs dissipates**. Treat the "5 users" rule as enough for *usability*, not for *tone*. `[verified 2026-06-20]`
4. **Don't adopt the "passion beats planning" framing as a method.** Your content-complete-per-zone rule and slice gate are stronger discipline and already correct — this research endorses keeping them. `[training knowledge]`
5. **Fix the toolchain mismatch** in any setup doc you keep: you use **GIMP/Pixelorama/scripted + PixelLab**, *not* Aseprite. `[verified 2026-06-20 — your vault]`
6. **Do not reorganize folders** to match Grok's template — your structure is already idiomatic and further along. `[verified 2026-06-20 — your vault]`

---

## Verify on integration (librarian to-do)

- [ ] Pin **Stardew Valley** start date and total dev time to a citable interview (GDC 2016 talk / interviews). Replace "~4.5 years" with the sourced figure.
- [ ] Confirm **Undertale** "~32 months" against a citable source; adjust if needed.
- [ ] Confirm exact **Godot 4.4 Web threading** header requirement wording against the current "Exporting for the web" page (COOP/COEP / `SharedArrayBuffer`).
- [ ] Decide whether to attribute the vertical-slice-vs-prototype distinction to a **named source** (Rami Ismail talk/post) or keep it as general production knowledge.
- [ ] Optional: add **Derek Yu, "Finishing a Game"** to the vault's reference list — strong fit for your scope discipline.
- [ ] Re-confirm **LimboAI Web export** still passes after any future Godot/addon version bump.
