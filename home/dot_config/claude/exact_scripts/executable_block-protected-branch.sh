#!/usr/bin/env bash
# Block git commit/push on main or master branches
# Used as a PreToolUse hook for the code-committer agent

set -euo pipefail

COMMAND="${TOOL_INPUT_COMMAND:-}"

if echo "$COMMAND" | grep -qE '^git (commit|push)'; then
  BRANCH=$(git branch --show-current 2>/dev/null || true)
  if [ "$BRANCH" = "main" ] || [ "$BRANCH" = "master" ]; then
    echo "BLOCKED: Cannot commit or push directly to '$BRANCH' branch."
    echo "Create a feature branch first: git checkout -b <branch-name>"
    exit 1
  fi
fi

exit 0
