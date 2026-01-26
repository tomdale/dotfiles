---
description: Add a single task with context to .agent/tasks.md
allowed-tools:
  - Read
  - Grep
  - Glob
  - Skill
  - Bash(node:*)
argument-hint: [task description]
---

# Add Task

Add a new task to the task list at `.agent/tasks.md`.

## Instructions

1. If `$ARGUMENTS` is empty, ask the user what task they want to add

2. Gather context for the task by searching the codebase:
   - **Path**: Absolute path to file(s) to create/modify (REQUIRED)
   - **Pattern**: Specific existing file to follow as reference (REQUIRED for code tasks)
   - **Dependencies**: What must already exist
   - **Expected**: Clear, verifiable success criteria (REQUIRED)
   - **Plan**: Reference to `.agent/plans/*.md` if applicable

3. Format the task as a multiline string:
   ```
   Task title here
   Path: /absolute/path/to/file.ts
   Pattern: /absolute/path/to/similar/existing/file.ts
   Dependencies: Required packages are installed
   Expected: Export specificFunction() that does X
   Plan: .agent/plans/related-plan.md (if applicable)
   ```

4. **Invoke the write-task skill** to validate and add the task:
   ```
   Use the Skill tool with skill="tasks:write-task"
   ```
   Then run the task_add.js script with the formatted task.

## Task Requirements

The write-task skill will guide you to REJECT tasks that don't meet these requirements:

- **Single Responsibility**: Task does ONE thing (no "and")
- **Absolute Path**: Path field must start with `/`
- **Specific Pattern**: Reference a SPECIFIC file, not vague guidance
- **Verifiable Expected**: Someone must be able to CHECK if it's done
- **Self-Contained**: ALL context needed (executor has no conversation history)

## CRITICAL: Never Edit tasks.md Directly

Tasks are ONLY added via the task_add.js script (guided by the write-task skill).
DO NOT use Edit or Write tools on `.agent/tasks.md` for any reason.

## User Request

$ARGUMENTS
