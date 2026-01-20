---
description: Execute all pending tasks from .agent/tasks.md
allowed-tools:
  - Bash(node:*)
  - Task
---

# Do All Tasks

Execute all pending tasks from the task list, one at a time.

## Instructions

1. Initialize counters:
   - completed = 0
   - blocked = 0

2. Loop until no pending tasks remain:

   a. Get the next pending task:
      ```bash
      node "${CLAUDE_PLUGIN_ROOT}/scripts/task_get.js" .agent/tasks.md
      ```

   b. If exit code is 1 (no tasks), exit the loop

   c. Spawn the `task-executor` agent with the task content:
      - Pass the FULL task output (title + all context lines)
      - Wait for completion

   d. Based on agent result:

      **If successful:**
      ```bash
      node "${CLAUDE_PLUGIN_ROOT}/scripts/task_complete.js" .agent/tasks.md
      ```
      Increment completed counter.

      **If blocked/failed:**
      ```bash
      node "${CLAUDE_PLUGIN_ROOT}/scripts/task_complete.js" .agent/tasks.md --blocked
      ```
      Increment blocked counter. **Continue with remaining tasks.**

3. After loop completes, if ALL tasks completed (blocked = 0):
   ```bash
   node "${CLAUDE_PLUGIN_ROOT}/scripts/task_archive.js" .agent/tasks.md
   ```

4. Report summary:
   - Total tasks processed
   - Completed count
   - Blocked count (with brief descriptions)
   - Whether tasks were archived

## Important

- Do NOT read `.agent/tasks.md` directly with the Read tool
- Continue processing even if some tasks are blocked
- Only archive when ALL tasks are complete (no blocked tasks)
- Each task-executor runs in isolation with full context
