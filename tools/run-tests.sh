#!/usr/bin/env bash
# Headless GUT test runner — usable locally and in CI.
set -euo pipefail
cd "$(dirname "$0")/.."
godot --headless -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit "$@"
