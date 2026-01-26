---
description: Generate tasks from .agent/backlog.md
allowed-tools:
  - Task
  - Bash(:>*)
---

# Generate Tasks from Backlog

Read `.agent/backlog.md` and break down its contents into discrete, self-contained tasks.

## Backlog Contents

!`cat .agent/backlog.md 2>/dev/null || echo ""`

## Instructions

1. If the backlog above is empty or missing, inform the user there's nothing to process and stop

2. Spawn the `task-planner` agent with the backlog contents:
   - Pass the full backlog as the goal
   - The agent will analyze, search the codebase, and create tasks
   - Wait for the agent to complete

3. After the agent completes, clear the backlog:
   ```bash
   : > .agent/backlog.md
   ```

4. Report what tasks were created
