#!/usr/bin/env bash
# check-brain.sh — guard against drift in the central AGENTS.md brain.
# Fails (exit 1) if rules leak back into shim files or stale terminology
# reappears in living design docs. Historical records (decisions/, sessions/)
# are exempt.
set -uo pipefail
cd "$(dirname "$0")/.."
fail=0

err() { echo "BRAIN DRIFT: $1"; fail=1; }

# 1. Stale tech terms in living docs (decisions/ and sessions/ are history and exempt;
#    docs/_compiled/ is generated from them and equally exempt;
#    lines explaining the replacement are exempt).
stale=$(grep -rn "Yarn Spinner" docs/ AGENTS.md --include="*.md" 2>/dev/null \
  | grep -v "docs/decisions/\|docs/sessions/\|docs/_compiled/" \
  | grep -vi "replaced\|dropped\|instead of\|not yarn\|→")
[ -n "$stale" ] && err "stale 'Yarn Spinner' reference(s):
$stale"

# 1b. The rpg-adventure mirror was retired 2026-06-10 — no living doc should
#     instruct syncing/publishing to it (mentions of the retirement itself are exempt).
stale_mirror=$(grep -rn "sync-to-rpg-adventure\|publish-standalone" docs/ AGENTS.md CLAUDE.md GROK.md tools/ --include="*.md" --include="*.sh" 2>/dev/null \
  | grep -v "docs/decisions/\|docs/sessions/\|docs/_compiled/\|check-brain.sh" \
  | grep -vi "removed\|retired\|replaced")
[ -n "$stale_mirror" ] && err "living doc still references the retired rpg-adventure sync/publish workflow:
$stale_mirror"

# 2. Shims must still point at AGENTS.md and stay thin.
grep -q "^@AGENTS.md" CLAUDE.md || err "CLAUDE.md lost its @AGENTS.md import"
grep -q "AGENTS.md" AGENT_RULES.md || err "AGENT_RULES.md lost its pointer to AGENTS.md"
grep -q "AGENTS.md" GROK.md || err "GROK.md lost its pointer to AGENTS.md"
[ "$(wc -l < AGENT_RULES.md)" -le 15 ] || err "AGENT_RULES.md grew beyond a shim — move rules to AGENTS.md"

# 3. Canonical file must exist and keep its core sections.
for section in "Critical rules" "Tool roles" "Locked tech stack" "Vertical slice"; do
  grep -q "$section" AGENTS.md || err "AGENTS.md missing section: $section"
done

if [ "$fail" -eq 0 ]; then
  echo "brain OK — AGENTS.md canonical, shims intact, no stale terminology"
fi
exit $fail
