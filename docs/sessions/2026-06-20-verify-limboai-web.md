---
name: Verify LimboAI exports cleanly to Web
date: 2026-06-20
branch: chore/verify-limboai-web
tags: [session, web-export, limboai, verification, risk-closed]
---

# 2026-06-20 — LimboAI Web export verification

## Result: ✅ PASS (toolchain) — exports cleanly, LimboAI wasm bundled
Closes the risk logged from [[research/done/2026-06-20-ai-assisted-gamedev-orchestration-survey]]
(GDExtension Web export "historically fragile").

## Evidence
- `addons/limboai/bin/limboai.gdextension` declares **`web.*` libraries** (both
  nothreads + threads, editor + template_release) and the `.wasm` files are on disk.
- `export_presets.cfg` Web preset is correctly configured:
  `variant/extensions_support=true` (GDExtension **dlink** template) +
  `variant/thread_support=false` (**nothreads** → no COOP/COEP / cross-origin
  isolation needed; serves from any static host).
- Godot **4.4.1** has the matching template installed (`web_dlink_nothreads_release.zip`).
- **Headless release export succeeded** (`godot --headless --export-release "Web"`,
  `rc=0`, no errors). Output is a complete build — `index.html/.js/.pck/.wasm`,
  `index.side.wasm` (dlink side module), and crucially
  **`liblimboai.web.template_release.wasm32.nothreads.wasm`** included.

## Still owed (human — agents are runtime-blind in-browser)
Serve the build and open `index.html` in a browser to confirm the wasm
**initializes** and a `LimboHSM`/behavior tree actually **runs in-page** (the
classes work in-engine — 280 GUT tests pass — so this is the last 5%). Nothreads
serves from a plain static host, e.g.:
`python3 -m http.server -d <export_dir>` → open `http://localhost:8000`.

## Guardrail recorded
Keep `extensions_support=true` + `thread_support=false` in the Web preset; the
nothreads LimboAI wasm is the one that ships. **Re-verify after any Godot or
LimboAI version bump** (addon versions are pinned to Godot 4.4 — bump together).
No source changes were needed; the export was to a throwaway dir (no build
artifacts committed). check-brain green; docs only.
