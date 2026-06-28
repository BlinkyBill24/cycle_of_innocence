---
name: 2026-06-28-adopt-godot-mcp-runtime
date: 2026-06-28
tags: [session, tooling, mcp, godot]
---

# 2026-06-28 — Adopt godot-mcp-runtime (runtime-visibility MCP server)

Follow-through on the librarian pass ([[2026-06-28-librarian-godot-mcp-research]]).
Goal: give the AI eyes on the *running* game, not just scene files.

## Step 0 — boot-smoke with the existing server (validated the loop)
Ran the project through the installed `Coding-Solo/godot-mcp` v0.1.1 via MCP
(`run_project` → `get_debug_output`). **Result: game boots and loads the main
scene `playground_fringes.tscn` cleanly — no fatal errors.** The console surfaced
a baseline of non-fatal warnings:
- ~40 "signal declared but never explicitly used" — harmless GameEvents-bus noise
  (signals emitted/connected across scripts the analyzer can't see).
- Worth a future hygiene pass: 1× integer-division warning; 2× `village_state.gd`
  static methods (`resolve_slot`, `effective_notice_rate`) called from an instance;
  ~4× ternary type-mismatch; several `name`/`age` shadowing/unused-var warnings.
- 2× stale-UID warnings in `playground_fringes.tscn` (campfire_frames.tres,
  fog_frames.tres → falls back to text path; fix via `update_project_uids`).
This proved the "Claude runs it → reads the real console" loop end-to-end.

## Step 1 — adopted godot-mcp-runtime v3.1.2
- Verified on npm (v3.1.2) and **smoke-tested the MCP handshake** standalone
  (`initialize` + `tools/list` over stdio): server starts, finds Godot, lists
  the runtime tools — `get_scene_tree`, `get_node_properties`, `list_autoloads`,
  `run_script`, `take_screenshot`, `simulate_input`, plus `run_project`/
  `get_debug_output` (so it fully supersedes the Coding-Solo base).
- `.mcp.json`: replaced the `godot` server with `npx -y godot-mcp-runtime@3.1.2`
  (pinned for reproducibility/supply-chain), env `GODOT_PATH=~/.local/bin/godot`.
- Why this one: addon-free — injects its bridge at runtime and leaves **nothing
  in the project**, so there's no web/Android export-exclude to maintain (the hard
  Web constraint), and it avoids Coding-Solo's command-injection advisory.
- Synced docs: `ai-production-setup.md` (Code-agents row + installed note now say
  runtime server adopted, FLAG resolved) and `ideas.md` (entry marked DONE, with
  the next jobs it unlocks + the cleanup tail).

## ⚠️ Restart gate
Project-scoped MCP servers load at Claude Code startup and prompt for approval on
first load. **The new runtime tools are NOT available in the session that made the
change.** Steps 2–4 (Briar yellow-blob, locked-door, autoload spot-checks) need a
Claude Code restart first, then approve the `godot` server when prompted.

## Not done (deliberate)
- Didn't delete the old `~/godot-mcp` install (unused, off-repo — leave for now).
- Didn't fix the warning baseline — folded into a future chore (captured in ideas).
