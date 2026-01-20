---
description: Add a single task with context to .agent/tasks.md
allowed-tools:
  - Bash(node:*)
  - Read
  - Grep
  - Glob
argument-hint: [task description]
---

# Add Task

Add a new task to the task list at `.agent/tasks.md`.

## Instructions

1. If `$ARGUMENTS` is empty, ask the user what task they want to add
2. Gather context for the task:
   - Relevant file paths (use absolute paths)
   - Patterns to follow (reference existing similar code)
   - Dependencies or prerequisites
   - Expected outcome
   - Reference to any relevant plan file in `.agent/plans/`

3. Format the task as a multiline string with the title on the first line and context on subsequent lines:
   ```
   Task title here
   Path: /absolute/path/to/file.ts
   Pattern: Follow existing code in src/similar.ts
   Dependencies: Required packages are installed
   Expected: What the completed task should accomplish
   Plan: .agent/plans/related-plan.md (if applicable)
   ```

4. Run the add script:
   ```bash
   node "${CLAUDE_PLUGIN_ROOT}/scripts/task_add.js" .agent/tasks.md "Task title
   Path: /path/to/file
   Context: Additional context here"
   ```

## Task Format

Each task should be **self-contained** with ALL information needed to execute it:

- **Path**: Absolute path to the file(s) to create or modify
- **Pattern**: Reference to existing code that demonstrates the expected style/approach
- **Dependencies**: What's already in place (packages, other files, etc.)
- **Expected**: Clear description of what "done" looks like
- **Plan**: Reference to detailed plan if one exists

## User Request

$ARGUMENTS
