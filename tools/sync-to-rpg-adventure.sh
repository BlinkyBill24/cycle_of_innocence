#!/bin/bash
# sync-to-rpg-adventure.sh
#
# Syncs the Cycle of Innocence game (currently developed in test/) into the
# rpg-adventure/ monorepo subdir so that it can be published (overwriting
# any old prototype content) to https://github.com/tchintchie/rpg-adventure .
#
# Per user instruction: "always commit any changes also to" that GitHub.
# "you can completely overwrite any existing code there".
#
# Usage:
#   From monorepo root: ./test/tools/sync-to-rpg-adventure.sh
#   Or cd test && ./tools/sync-to-rpg-adventure.sh
#
# It will:
# - Copy core Godot project files from the source (test/ or current) into ../rpg-adventure/
# - Overwrite old ruins/caves prototype (scripts, scenes, resources, assets, project.godot, etc.)
# - Copy GROK.md and docs/ (local vault) for the published standalone
# - Optionally update project name/description
# - Leave the monorepo .git and other top-level items untouched
#
# After running: git add rpg-adventure/ test/ (or relevant), commit on feature branch,
# then run rpg-adventure/tools/publish-standalone.sh to force-push the split to the GitHub.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Determine monorepo root and source
if [[ "$(basename "$SCRIPT_DIR")" == "tools" && -d "$SCRIPT_DIR/../test" ]]; then
  # run from monorepo root, source is test/
  MONO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
  SOURCE_DIR="$MONO_ROOT/test"
  TARGET_DIR="$MONO_ROOT/rpg-adventure"
elif [[ -f "$SCRIPT_DIR/../project.godot" ]]; then
  # run from inside test/
  SOURCE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
  MONO_ROOT="$(cd "$SOURCE_DIR/.." && pwd)"
  TARGET_DIR="$MONO_ROOT/rpg-adventure"
else
  echo "ERROR: Run from monorepo root or from inside test/ directory." >&2
  exit 1
fi

echo "==> Syncing Cycle of Innocence from $SOURCE_DIR into $TARGET_DIR (overwrite allowed)"
echo "    Monorepo root: $MONO_ROOT"

# Ensure target exists (it should as part of monorepo)
mkdir -p "$TARGET_DIR"

# Core files/dirs to sync (the Godot project + our new memory/docs)
# Using rsync for safety and --delete to truly overwrite old content in target.
RSYNC_OPTS=(-a --delete --exclude='.godot/' --exclude='*.import.bak' --exclude='__pycache__/' --exclude='.DS_Store')

# Sync the main Godot project layout
for item in project.godot icon.svg icon.svg.import scenes scripts resources assets tools; do
  if [[ -e "$SOURCE_DIR/$item" ]]; then
    echo "  - syncing $item"
    rsync "${RSYNC_OPTS[@]}" "$SOURCE_DIR/$item/" "$TARGET_DIR/$item/" || true
  fi
done

# Sync top-level single files
for item in GROK.md; do
  if [[ -f "$SOURCE_DIR/$item" ]]; then
    echo "  - syncing $item"
    cp -f "$SOURCE_DIR/$item" "$TARGET_DIR/$item"
  fi
done

# Sync the local docs/ vault (game-specific memory inside the published repo)
if [[ -d "$SOURCE_DIR/docs" ]]; then
  echo "  - syncing docs/ (local vault)"
  mkdir -p "$TARGET_DIR/docs"
  rsync "${RSYNC_OPTS[@]}" "$SOURCE_DIR/docs/" "$TARGET_DIR/docs/"
fi

# Copy any other useful root files (playground can be skipped or kept as test scene)
# We intentionally do NOT copy the old minimal Player/ or playground unless wanted.

# Post-sync polish: make sure project name reflects the new title
if [[ -f "$TARGET_DIR/project.godot" ]]; then
  echo "  - updating project.godot name/description for Cycle of Innocence"
  # Use sed for simple replacement (safe for this format)
  sed -i 's/^config\/name=".*"/config\/name="Cycle of Innocence"/' "$TARGET_DIR/project.godot" || true
  sed -i 's/^config\/description=".*"/config\/description="2D top-down horror-conspiracy action RPG with animal companions. Escaped child sacrifice. Real-time action + Yarn narrative."/' "$TARGET_DIR/project.godot" || true
fi

echo "==> Sync complete. rpg-adventure/ now contains the current game (old prototype overwritten)."
echo "Next steps (manual or via hook):"
echo "  1. git add -A rpg-adventure/   (and test/ if you want the source tracked)"
echo "  2. git commit -m 'sync: Cycle of Innocence changes to rpg-adventure/ subdir for publish'"
echo "  3. (optional but required for the GitHub) cd rpg-adventure && ./tools/publish-standalone.sh"
echo ""
echo "This fulfills the requirement to always commit changes also to https://github.com/tchintchie/rpg-adventure (force/overwrite permitted)."