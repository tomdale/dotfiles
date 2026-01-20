---
description: Execute the next pending task from .agent/tasks.md
allowed-tools:
  - Bash(node:*)
  - Task
---

# Do One Task

Execute the next pending task from the task list.

## Instructions

1. Get the next pending task:
   ```bash
   node "${CLAUDE_PLUGIN_ROOT}/scripts/task_get.js" .agent/tasks.md
   ```

2. If no pending tasks, inform the user and stop

3. Spawn the `task-executor` agent with the task content:
   - Pass the FULL task output (title + all context lines)
   - The agent will execute the task independently
   - Wait for the agent to complete

4. Based on the agent's result:

   **If successful:**
   ```bash
   node "${CLAUDE_PLUGIN_ROOT}/scripts/task_complete.js" .agent/tasks.md
   ```
   Report what was accomplished.

   **If blocked/failed:**
   ```bash
   node "${CLAUDE_PLUGIN_ROOT}/scripts/task_complete.js" .agent/tasks.md --blocked
   ```
   Report the blocker and what needs to be resolved.

5. Summarize the result to the user

## Important

- Do NOT read `.agent/tasks.md` directly with the Read tool
- The task-executor agent handles ALL implementation
- Only use the scripts to interact with the tasks file
