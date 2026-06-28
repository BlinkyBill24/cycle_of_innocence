---
name: Claude-Godot-MCP-Servers-Research-2026-06-28
date: 2026-06-28
source: Targeted web research (June 2026) — GitHub repos + READMEs + commit histories, Godot Asset Library, official Godot docs, and project sites (gdaimcp.com, godotiq.com, prajnaavidya/godot-peek-mcp, Erodenn/godot-mcp-runtime). Single-pass Claude research, no cross-model review.
prompt: Research Godot MCP servers for Claude Code with two goals — (1) live scene-tree visibility to stop invented node paths/signals, (2) run the game + read runtime errors so the AI can self-check. Constraints: Linux Mint, Godot 4.4, typed GDScript only, Web/HTML5 export hard constraint (no C#/.NET). Setup hassle acceptable.
status: integrated
---

> **Note on framing:** An MCP server is workflow tooling, not a game feature, so the four-pillar filter (story / companion arc / horror beat / replay value) is the wrong lens here. The right lens is: *does it reduce the wiring failures, invented signals, and legibility-diagnosis gaps that have cost authored content?* That is the filter applied below.

> **What an MCP server is, in one line:** a small program that gives Claude Code a live connection to your actual running Godot project, so it can *see* real nodes and *read* real errors instead of guessing. [training knowledge]

---

## Bottom line

No single free server does both jobs perfectly on Linux today, but a simple stack gets you there. [verified 2026-06-28]

1. **Do this first, regardless of any server** — add a `CLAUDE.md` documenting your autoloads + GameEvents method/signal contract, and a tiny `@tool` script that writes the live scene tree to `SCENE_TREE.md` on save. Free, zero risk, attacks the invented-path problem directly. [training knowledge]
2. **Primary MCP server: `Erodenn/godot-mcp-runtime`** — runs the game, reads output, walks the live tree, runs GDScript in the running game. Its key advantage for you: it injects its bridge at runtime and removes it afterward, so **there is nothing to exclude from your web export**. Best fit for your hard constraint. [verified 2026-06-28]
3. **Add for deeper debugging: `PrajnaAvidya/Godot-Peek-MCP`** — best free runtime-visibility tool (live runtime tree, stack traces, variable values, performance monitors). Directly useful for diagnosing the Briar "yellow blob" failure. **Verify its Linux x86_64 binary runs on your Mint machine first** — it does not support other CPU types. [verified 2026-06-28] [FLAG]

**Avoid:** `IvanMurzak/Godot-MCP` (needs the C#/.NET build — disqualified by your no-C# rule). Treat the original `Coding-Solo/godot-mcp` as launch-and-read-errors only; it has an unpatched command-injection advisory and does not see your live editor tree. [verified 2026-06-28]

---

## The landscape (three kinds)

[verified 2026-06-28]

- **Launch-only.** Runs Godot, captures console errors, reads scene *files*. Does **not** see the live tree. (Coding-Solo and basic forks.)
- **Live editor bridge.** Installs a plugin in your editor so the AI reads your real scene tree, node properties, and signals while you work. (GodotIQ, GDAI, Godot MCP Pro, ee0pdt, tugcantopaloglu, hi-godot.)
- **Runtime-focused.** Centres on the play loop — run the game, read the *running* tree, capture debugger errors/stack traces/screenshots. (Godot-Peek-MCP, godot-mcp-runtime.)

For your two goals: scene-tree visibility needs a bridge or runtime server; run-and-read-errors needs a launch-only (basic) or runtime server (best).

---

## Shortlist for your setup

### Erodenn/godot-mcp-runtime — recommended primary
- **Repo:** github.com/Erodenn/godot-mcp-runtime. TypeScript, built on the Coding-Solo base, indexed Jan 2026. [verified 2026-06-28]
- **Does:** Runs the project, captures debug output, takes screenshots, simulates input, walks the live scene tree (UI discovery), and runs GDScript against the running scene. Can also create scenes/nodes/scripts headlessly. [verified 2026-06-28]
- **Why it fits you:** **No addon stays in your project.** It injects an `McpBridge` autoload at runtime, then auto-cleans up and auto-adds ignore entries — so **nothing to strip from web/Android export.** This is the cleanest answer to your hard web constraint. [verified 2026-06-28]
- **Setup:** `npx -y godot-mcp-runtime`, point it at your Godot binary (PATH or `GODOT_PATH`). Node.js. Linux fine. [verified 2026-06-28]
- **Limitation:** If you launch the game yourself instead of via the server ("attached mode"), it can't capture console output — output only flows through the run it starts itself. [verified 2026-06-28]

### PrajnaAvidya/Godot-Peek-MCP — recommended for debugging power
- **Repo:** github.com/PrajnaAvidya/godot-peek-mcp. MIT. v1.3.0 (Mar 1, 2026). Small project, one maintainer, actively iterated Feb–Mar 2026. [verified 2026-06-28]
- **Does:** Run/stop/restart scenes; read all output (print + errors + warnings); read the **live runtime scene tree** and any node's properties; **stack traces, local variable values, breakpoints, performance monitors** (FPS/memory/draw calls); screenshots; run GDScript in the running game; override autoload variables at startup. This is the strongest free tool for "run it and tell me what actually happened." [verified 2026-06-28]
- **Godot 4.4:** Minimum supported version is 4.4 — exactly your version. [verified 2026-06-28]
- **Linux:** Ships a **Linux x86_64 binary** (standard desktop Mint). **But only Linux x86_64 and macOS Apple-Silicon are supported — no Windows, no Intel Mac, no ARM Linux.** [verified 2026-06-28] [FLAG] Verify it launches on your specific machine before relying on it.
- **Setup:** Download the release tarball, copy `addons/godot_mcp/` into your project, enable the plugin, then register it with `claude mcp add`. It's a C++ extension + Go server talking to the running game. [verified 2026-06-28]
- **Web export:** The addon **must be excluded from every export build** (a one-time export-filter line covering `addons/godot_mcp/bin/*`, `addons/godot_mcp/godot_peek.gdextension`, `addons/godot_mcp/plugin.*`) or your exported game errors on startup. [verified 2026-06-28] [FLAG]
- **Note:** Breakpoints work only with Godot's built-in script editor, not an external one. [verified 2026-06-28]

### GodotIQ — cleanest cross-platform bridge (free tier)
- **Repo:** github.com/salvo10f/godotiq. Free Community tier (~22–24 tools) is MIT; Pro (~14 tools) is paid, ~$19. Active Mar–May 2026; on PyPI and the Godot Asset Library. [verified 2026-06-28] [FLAG: confirm current Pro price/feature split yourself]
- **Does (free):** Scene editing, game control, screenshots, scripts, filesystem, `read_debug_console` (so the AI reads runtime errors instead of asking you to paste them), `verify_project_runs` (PASS/FAIL with the debug buffer), live UI mapping, scene-tree/node ops, error checks. [verified 2026-06-28]
- **Why consider it:** The addon is **pure GDScript (~500 lines, no compiled binary), so it runs on any OS** — the safest cross-platform story, no native file to trust. [verified 2026-06-28]
- **Setup:** `uvx godotiq` (Python) + copy the GDScript addon (WebSocket on port 6007). [verified 2026-06-28]
- **Caveat:** Its marketing and Pro features lean toward 3D; the free tier still covers both your goals for a 2D project. [verified 2026-06-28]

### tugcantopaloglu/godot-mcp — free all-in-one alternative
- **Repo:** github.com/tugcantopaloglu/godot-mcp. MIT. v2.0.0 (Mar 2, 2026). A 149-tool fork of Coding-Solo. [verified 2026-06-28]
- **Does:** Adds a runtime bridge autoload (port 9090) giving the runtime scene tree, `game_get_errors`, `game_get_logs`, run GDScript in the game, read/set properties, call methods, signals, performance, screenshots, input simulation. One free tool covering both goals. [verified 2026-06-28]
- **Caveats:** You copy an autoload into your project, so **exclude/guard it for web export.** It inherits the Coding-Solo base — verify the command-injection issue (below) is addressed in this fork. [verified 2026-06-28] [FLAG]

### Paid bridges (if you want polish/support)
- **GDAI MCP** (3ddelano) — $19 one-time editor addon from a reputable Godot plugin author. Live editor control + debugger integration + screenshots. Godot 4.2+. Ships a precompiled `.so` for Linux (you must trust the binary); closed-source server; exclude from export. [verified 2026-06-28] [FLAG: confirm current price]
- **Godot MCP Pro** (youichi-uda) — $15 one-time. ~160+ tools (the count is stated inconsistently across its own docs as 162/163/175 — treat as "~160"). WebSocket bridge into the live editor; runtime inspection (19 tools); error log; `--lite`/`--minimal` modes to avoid overwhelming the agent. Requires Godot 4.4+. Exclude from export. [verified 2026-06-28]

### Disqualified / handle with care
- **IvanMurzak/Godot-MCP** — polished (Apache-2.0, 39 tools) **but requires the C#/.NET (mono) build of Godot + a .NET 8 SDK. The GDScript-only build cannot compile it.** ❌ Disqualified by your web-export / no-C# rule. [verified 2026-06-28]
- **Coding-Solo/godot-mcp** — the original and most popular (~4.3k stars, MIT) but only launches/reads-output and parses scene files; **no live editor tree.** Has a **command-injection (RCE) advisory** from an unsanitised project-path argument (issue #64) — only ever point it at trusted paths. Its forks above are better. [verified 2026-06-28]
- **Minor note:** `mkdevkit/godot-mcp` includes Android deploy tools, which could be marginally relevant to your Android target later. Newer/less proven. [verified 2026-06-28]

---

## How to use it (plain steps)

[training knowledge]

1. **Install the server** (e.g. `godot-mcp-runtime` via `npx`, or copy in the Godot-Peek addon).
2. **Register it with Claude Code** using its `claude mcp add ...` command (each repo's README gives the exact line). This tells Claude Code the server exists.
3. **Point it at your Godot** so it can find the engine binary on your machine.
4. **Work as normal.** When you ask Claude Code to write or fix code, it can now ask the server things like "what does the live tree look like?" or "run this and show me the errors" — without you pasting anything.
5. **The loop becomes:** Claude writes → Claude runs it via the server → Claude reads the real error/tree → Claude fixes → repeat. You still review against the vault and guardrails; the server just removes the blind guessing and the manual copy-paste of errors.

One-time housekeeping: if the server installs an addon (Godot-Peek, GodotIQ, GDAI, Pro, tugcantopaloglu), add its export-exclude filter **before your next web/Android build** so it never ships. `godot-mcp-runtime` skips this entirely. [verified 2026-06-28] [FLAG]

---

## Where this helps Cycle of Innocence specifically

[training knowledge — these are mappings to your recorded systems, not claims about the tools' marketing]

- **Invented signals / wrong node paths — your stated wariness.** Your GameEvents bus uses a direct-method-call pattern with *no invented signals*. A server that reads the real tree and your real scripts lets Claude Code reference actual methods and node paths instead of fabricating them. This is the core reason to adopt one.
- **The Briar "yellow blob" playtest failure.** Your open diagnosis is *wiring failure vs legibility failure*, pending a dev debug-overlay walkthrough. A runtime server (Godot-Peek especially) can run the game and inspect the live tree to confirm whether Briar's seek/point behaviour node actually fired and what state it's in. That settles the *wiring* half quickly. **Caveat:** whether a human can *read* the tell is still a human-playtest question — the tool can't judge legibility, only execution.
- **The locked-door no-feedback issue.** Same mechanism: runtime inspection can confirm whether the door logic ran at all.
- **Your autoloads (DreadManager, HollowingClock, VillageState, ZoneManager, SaveManager).** These are runtime singletons — they do **not** appear in scene files, so the free `SCENE_TREE.md` dump can't show their live state. A runtime server can read it (e.g. "is DreadManager's value what I expect here?"). This is the gap only a live/runtime server fills.
- **Your GUT test suite.** Pair it: GUT gives deterministic pass/fail; the MCP server gives observational "what's happening at runtime." Together that's a stronger self-check loop than either alone.

---

## Web/HTML5 reality check (your hard constraint)

[verified 2026-06-28]

Two facts matter:
- **Any installed addon must be excluded from web export** or the exported game errors on startup. `godot-mcp-runtime` avoids this because nothing stays in the project.
- **Godot's own debugger over HTML5 lacks breakpoints** (browser networking limits). **But this rarely bites you:** these servers run the game on your **Linux desktop in debug mode**, not in a browser. So Claude's self-check happens on the desktop build; you export to web separately. The web debugger limit only matters if you specifically try to debug the *web* build.

---

## Caveats / verify before committing

[FLAG] unless noted.

- **Immature, fast-moving ecosystem.** Most of these shipped in 2025–2026; many have one maintainer and few stars. Star counts and "last updated" dates here are June-2026 spot-checks and will drift — re-check commit history before installing. [verified 2026-06-28]
- **A live tree is not hallucination-proof.** Even bridge/runtime servers *reduce*, not eliminate, wrong paths — the model can still mis-call a tool or work from stale context. Keep the `CLAUDE.md` + `SCENE_TREE.md` discipline as a backstop. [training knowledge]
- **Editor tree vs runtime tree.** Bridges (GodotIQ/GDAI/Pro/ee0pdt) show the *editor* tree while you build; runtime servers (Godot-Peek/godot-mcp-runtime) show the *running game's* tree. For "stop inventing paths while writing code," the editor tree or your file dump is usually what you want; the runtime tree is for debugging dynamic/instanced nodes and autoloads.
- **Security.** The original Coding-Solo server has an unpatched command-injection advisory; precompiled binaries (GDAI's `.so`, Godot-Peek's C++ extension) require trusting the maintainer's build. All these bind to localhost — keep it that way; don't expose ports. [verified 2026-06-28]
- **Specific things to check yourself:** (1) that the `tugcantopaloglu` fork fixed Coding-Solo's project-path injection; (2) that Godot-Peek's binary runs on your Mint/glibc; (3) the current price/feature split of GDAI and GodotIQ Pro (both ~$19); (4) that an installed/injected MCP autoload name (`McpBridge`, `McpInteractionServer`) doesn't collide with your autoloads or LimboAI/Dialogue Manager.
- **Self-interested sources.** Much of the "file-level tools can't press play, use our product" narrative online comes from paid products (Summer Engine, Ziva). The underlying technical point (file parsing ≠ runtime) is true; their conclusions favour their own tools. Findings above are corroborated against the actual repo READMEs where possible. [verified 2026-06-28]

---

## Reference list

[verified 2026-06-28 — URLs visited during research]

- github.com/Erodenn/godot-mcp-runtime
- github.com/PrajnaAvidya/godot-peek-mcp
- github.com/salvo10f/godotiq  ·  godotiq.com  ·  godotengine.org/asset-library/asset/5245
- github.com/tugcantopaloglu/godot-mcp
- github.com/Coding-Solo/godot-mcp  ·  issue #64 (RCE advisory)
- github.com/3ddelano/gdai-mcp-plugin-godot  ·  gdaimcp.com
- github.com/youichi-uda/godot-mcp-pro  ·  godotengine.org/asset-library/asset/4961
- github.com/IvanMurzak/Godot-MCP (disqualified — C#/.NET)
- github.com/hi-godot/godot-ai  ·  github.com/ee0pdt/Godot-MCP  ·  github.com/mkdevkit/godot-mcp (secondary)
