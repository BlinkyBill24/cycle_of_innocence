#!/usr/bin/env bash
# Agentic playtest smoke — headless checks agents (and humans) run before
# claiming a slice path still works. Does NOT replace human F5 dread/feel.
#
# What it does:
#   1) GUT: wiring + quest-path smoke (test_playtest_smoke_path + hollow house)
#   2) Headless boot of the main scene for N frames — fail on SCRIPT ERROR
#   3) Headless boot of hollow_house.tscn — fail on SCRIPT ERROR
#
# Usage:
#   bash tools/playtest_smoke.sh           # full smoke
#   bash tools/playtest_smoke.sh --gut-only
#   bash tools/playtest_smoke.sh --boot-only
#   bash tools/playtest_smoke.sh --frames 180
#
# See docs/design/agentic-playtest-smoke.md for the live MCP walk recipe.
set -euo pipefail
cd "$(dirname "$0")/.."

GUT_ONLY=0
BOOT_ONLY=0
FRAMES=120
GODOT_BIN="${GODOT_BIN:-godot}"

while [[ $# -gt 0 ]]; do
	case "$1" in
		--gut-only) GUT_ONLY=1; shift ;;
		--boot-only) BOOT_ONLY=1; shift ;;
		--frames) FRAMES="${2:?}"; shift 2 ;;
		-h|--help)
			sed -n '2,20p' "$0"
			exit 0
			;;
		*)
			echo "Unknown arg: $1" >&2
			exit 2
			;;
	esac
done

fail() { echo "SMOKE FAIL: $*" >&2; exit 1; }
ok() { echo "SMOKE OK: $*"; }

# Refresh imports so new class_name / tests are visible (same as run-tests.sh).
"$GODOT_BIN" --headless --import > /dev/null 2>&1 || true

run_gut() {
	echo "=== GUT playtest smoke path ==="
	local log
	log="$(mktemp)"
	# GUT -gselect takes ONE script name (no commas). Wiring + dig→truth logic
	# both live in test_playtest_smoke_path.gd so one select is enough for smoke.
	if ! "$GODOT_BIN" --headless -s addons/gut/gut_cmdln.gd \
		-gdir=res://tests -ginclude_subdirs -gexit \
		-gselect=test_playtest_smoke_path \
		2>&1 | tee "$log"; then
		rm -f "$log"
		fail "GUT returned non-zero"
	fi
	if grep -q "Ignoring script" "$log"; then
		rm -f "$log"
		fail "GUT ignored a test script (parse error)"
	fi
	if grep -q "Could not find script matching" "$log"; then
		rm -f "$log"
		fail "GUT -gselect matched no script (import lag or wrong name?)"
	fi
	if ! grep -q "All tests passed" "$log"; then
		rm -f "$log"
		fail "GUT did not report All tests passed"
	fi
	if ! grep -Eqe 'Tests[[:space:]]+[1-9]' "$log"; then
		rm -f "$log"
		fail "GUT ran zero tests"
	fi
	rm -f "$log"
	ok "GUT smoke suite finished"
}

boot_scene() {
	local scene="$1"
	local label="$2"
	echo "=== Headless boot: $label ($scene, ${FRAMES} frames) ==="
	local log
	log="$(mktemp)"
	# --quit-after counts frames; enough for _ready + a few physics ticks.
	set +e
	"$GODOT_BIN" --headless --path . --quit-after "$FRAMES" "$scene" >"$log" 2>&1
	local ec=$?
	set -e
	# Godot sometimes exits non-zero on headless quit; only fail on real script noise.
	if grep -Eiq 'SCRIPT ERROR|Parse Error|Failed to load script|Assertion failed' "$log"; then
		echo "----- boot log (tail) -----" >&2
		tail -n 80 "$log" >&2
		rm -f "$log"
		fail "SCRIPT ERROR / parse error while booting $label"
	fi
	# Soft note if process crashed hard with no script error line.
	if [[ $ec -ne 0 ]] && ! grep -qiE 'quit|Godot Engine' "$log"; then
		echo "----- boot log (tail) -----" >&2
		tail -n 40 "$log" >&2
		rm -f "$log"
		fail "Godot exited $ec booting $label (no SCRIPT ERROR line; see log)"
	fi
	rm -f "$log"
	ok "boot $label clean"
}

if [[ "$BOOT_ONLY" -eq 0 ]]; then
	run_gut
fi

if [[ "$GUT_ONLY" -eq 0 ]]; then
	boot_scene "res://scenes/zones/playground_fringes.tscn" "main playground_fringes"
	boot_scene "res://scenes/zones/hollow_house.tscn" "hollow house hall"
	boot_scene "res://scenes/zones/hollow_house_back.tscn" "hollow house back"
	boot_scene "res://scenes/zones/village_green.tscn" "village green"
fi

echo
ok "all playtest smoke checks passed"
echo "Next (optional live MCP): see docs/design/agentic-playtest-smoke.md § Live MCP walk"
