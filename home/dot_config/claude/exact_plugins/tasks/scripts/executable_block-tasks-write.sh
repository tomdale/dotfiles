#!/usr/bin/env bash
# Block direct writes to .agent/tasks.md
# Reminds users to use task_add.js script instead

set -euo pipefail

FILE_PATH="${TOOL_INPUT_FILE_PATH:-}"

if [[ "$FILE_PATH" == *".agent/tasks.md" ]] || [[ "$FILE_PATH" == *"tasks.md" && "$FILE_PATH" == *".agent"* ]]; then
  echo "BLOCKED: Cannot write to .agent/tasks.md directly."
  echo ""
  echo "Use the task_add.js script instead:"
  echo '  node ${CLAUDE_PLUGIN_ROOT}/scripts/task_add.js .agent/tasks.md "Task title'
  echo "  Path: /absolute/path"
  echo "  Pattern: /reference/file"
  echo '  Expected: Success criteria"'
  echo ""
  echo "Or invoke the write-task skill: Skill(tasks:write-task)"
  exit 1
fi

exit 0
