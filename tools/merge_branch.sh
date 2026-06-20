#!/usr/bin/env bash
# merge_branch.sh — Claude Code owns merges (R6, 2026-06-20). Opens a PR for a
# pushed feature branch (if one doesn't exist yet), waits until Forgejo says it's
# mergeable, and merges it into main via the Forgejo API. Keeps the clean PR flow
# (records + main's protection) without anyone clicking the web button.
#
# Usage:  tools/merge_branch.sh <branch> "<PR title>"
#         tools/merge_branch.sh --pr <number>        # merge an existing PR by number
#
# Needs a Forgejo token at ~/.config/forgejo/token (repo read/write). The push to
# the branch must already be done. Never touches main locally (R1).
set -euo pipefail

API="http://192.168.178.32:3000/api/v1/repos/home/cycle_of_innocence"
TOKEN_FILE="${HOME}/.config/forgejo/token"
[ -s "$TOKEN_FILE" ] || { echo "ERROR: no Forgejo token at $TOKEN_FILE" >&2; exit 1; }
T="$(cat "$TOKEN_FILE")"

auth=(-H "Authorization: token $T" -H "Content-Type: application/json")

api_get()  { curl -s --max-time 10 "${auth[@]}" "$API/$1"; }
api_post() { curl -s --max-time 15 -o /tmp/mb_resp.txt -w "%{http_code}" "${auth[@]}" -X POST "$API/$1" -d "$2"; }

# resolve the PR number
if [ "${1:-}" = "--pr" ]; then
	PR="${2:?usage: merge_branch.sh --pr <number>}"
else
	BRANCH="${1:?usage: merge_branch.sh <branch> \"<title>\"}"
	TITLE="${2:?usage: merge_branch.sh <branch> \"<title>\"}"
	# existing open PR for this head?
	PR="$(api_get "pulls?state=open&limit=50" \
		| tr '}' '\n' | grep -F "\"ref\":\"$BRANCH\"" -B5 \
		| grep -oE '"number":[0-9]+' | head -1 | grep -oE '[0-9]+' || true)"
	if [ -z "${PR:-}" ]; then
		body="$(printf '{"head":"%s","base":"main","title":"%s"}' "$BRANCH" "${TITLE//\"/\\\"}")"
		code="$(api_post "pulls" "$body")"
		PR="$(grep -oE '"number":[0-9]+' /tmp/mb_resp.txt | head -1 | grep -oE '[0-9]+' || true)"
		[ -n "${PR:-}" ] || { echo "ERROR: could not open PR (HTTP $code): $(head -c 300 /tmp/mb_resp.txt)" >&2; exit 1; }
		echo "opened PR #$PR for $BRANCH"
	else
		echo "found open PR #$PR for $BRANCH"
	fi
fi

# wait until mergeable, then merge (Forgejo recomputes mergeability async)
for try in $(seq 1 8); do
	m="$(api_get "pulls/$PR" | grep -oE '"mergeable":(true|false)' | head -1)"
	if [ "$m" = '"mergeable":true' ]; then
		code="$(api_post "pulls/$PR/merge" '{"Do":"merge"}')"
		if [ "$code" = "200" ]; then echo "PR #$PR merged ✅"; exit 0; fi
		echo "  merge HTTP $code (try $try): $(head -c 160 /tmp/mb_resp.txt)"
	else
		echo "  PR #$PR not mergeable yet ($m) — waiting (try $try)…"
	fi
	sleep 3
done
echo "ERROR: PR #$PR did not merge after retries" >&2
exit 1
