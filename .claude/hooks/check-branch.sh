#!/bin/bash
# Claude Code PreToolUse(Bash) hook — block `git commit` on main/master (R1).
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | python3 -c "import sys,json;print(json.load(sys.stdin).get('tool_input',{}).get('command',''))" 2>/dev/null)
CWD=$(echo "$INPUT" | python3 -c "import sys,json;print(json.load(sys.stdin).get('cwd',''))" 2>/dev/null)
echo "$COMMAND" | grep -qE "(^|[;&|])[[:space:]]*git[[:space:]]+commit" || exit 0
BRANCH=$(git -C "${CWD:-.}" rev-parse --abbrev-ref HEAD 2>/dev/null)
if [ "$BRANCH" = "main" ] || [ "$BRANCH" = "master" ]; then
  echo "BLOCKED (R1): cannot commit to '$BRANCH'. Branch first: git switch -c feature/<name>" >&2
  exit 2
fi
exit 0
