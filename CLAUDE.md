@AGENTS.md

## Claude Code specifics (shim — rules live in AGENTS.md only)

- Auto-memory: `~/.claude/projects/-home-seitanist-game/memory/` (project pivot, tooling pins, deploy workflow).
- Drive the other tools from here: `codex:rescue` skill for second-opinion review/rescue; `mcp__Grok__*` tools for Imagine art generation and vision/story passes.
- The `check-branch` PreToolUse hook enforces R1 (blocks `git commit` on main).
- Run `bash tools/check-brain.sh` before declaring done — it catches drift between this brain and the docs.
