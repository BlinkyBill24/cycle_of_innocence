#!/usr/bin/env bash
# Headless GUT test runner — usable locally and in CI.
set -euo pipefail
cd "$(dirname "$0")/.."

# Refresh imports first: new class_name scripts aren't in the global class
# cache until an import pass, and edited .dialogue files keep their stale
# compile — both make GUT silently skip/miss things (2026-06-11).
godot --headless --import > /dev/null 2>&1 || true

log="$(mktemp)"
trap 'rm -f "$log"' EXIT
godot --headless -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit "$@" 2>&1 | tee "$log"

# GUT only WARNS when a test script fails to parse ("Ignoring script ...") and
# still reports the run as passing — that must be a hard failure.
if grep -q "Ignoring script" "$log"; then
	echo "FATAL: GUT ignored at least one test script (parse error above)." >&2
	exit 1
fi
