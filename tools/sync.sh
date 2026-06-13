#!/usr/bin/env bash
# sync.sh — pull latest main + reimport assets, before an F5 test session.
#
# Why: merging a PR on GitHub does NOT update this working copy. Run this in
# test/ before testing so the editor isn't showing stale code (the recurring
# "I merged but don't see my change" trap). Safe with uncommitted editor edits
# (collider tweaks etc.) — it auto-stashes and restores them.
#
# Usage:  bash tools/sync.sh        (godot must be on PATH, or set GODOT=…)
set -uo pipefail
cd "$(dirname "$0")/.."  # -> test/ project root
GODOT="${GODOT:-godot}"

echo "→ fetching origin…"
git fetch -q origin || { echo "✗ git fetch failed"; exit 1; }

branch="$(git rev-parse --abbrev-ref HEAD)"
behind="$(git rev-list --count "HEAD..origin/${branch}" 2>/dev/null || echo 0)"

if [ "$behind" -eq 0 ]; then
	echo "✓ already up to date with origin/${branch}"
else
	stashed=0
	if ! git diff --quiet || ! git diff --cached --quiet; then
		echo "→ stashing your local edits…"
		git stash push -u -m "sync.sh auto-stash" >/dev/null && stashed=1
	fi
	echo "→ fast-forwarding ${branch} (${behind} commit(s) behind)…"
	if git merge --ff-only "origin/${branch}"; then
		echo "✓ now at $(git log --oneline -1)"
	else
		echo "✗ cannot fast-forward — your branch has diverged; resolve manually."
		[ "$stashed" -eq 1 ] && git stash pop
		exit 1
	fi
	if [ "$stashed" -eq 1 ]; then
		echo "→ restoring your local edits…"
		git stash pop || echo "⚠ stash pop conflicted — your edits are safe in 'git stash list'"
	fi
fi

echo "→ reimporting assets (godot --headless --import)…"
if "$GODOT" --headless --import >/dev/null 2>&1; then
	echo "✓ reimport done"
else
	echo "⚠ reimport reported warnings — open the editor once to finish importing"
fi
echo "Ready to F5. (Reopen the scene in an already-open editor to drop its stale copy.)"
