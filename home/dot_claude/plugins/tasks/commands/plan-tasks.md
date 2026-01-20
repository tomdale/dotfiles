---
description: Break down a goal into multiple self-contained tasks
allowed-tools:
  - Bash(node:*)
  - Read
  - Grep
  - Glob
  - Task
argument-hint: [goal description]
---

# Plan Tasks

Break down a goal into discrete, self-contained tasks and add them to `.agent/tasks.md`.

## Instructions

1. If `$ARGUMENTS` is empty, ask the user what goal they want to accomplish

2. Analyze the goal:
   - Search the codebase to understand current structure
   - Identify files that need to be created or modified
   - Determine the logical order of tasks
   - Find existing patterns to reference

3. Break into discrete tasks where each task:
   - Does ONE thing
   - Is independently executable
   - Contains ALL context needed (no external references except plan files)
   - Can be completed without knowledge of other tasks

4. For each task, gather full context:
   - **Path**: Absolute path to target file(s)
   - **Pattern**: Reference to similar existing code
   - **Dependencies**: What's already in place
   - **Expected**: Clear success criteria
   - **Plan**: Reference to `.agent/plans/*.md` if applicable

5. Add tasks in execution order using the script:
   ```bash
   node "${CLAUDE_PLUGIN_ROOT}/scripts/task_add.js" .agent/tasks.md "Task title
   Path: /absolute/path/to/file.ts
   Pattern: Follow src/existing/similar.ts
   Dependencies: Package X installed, config Y exists
   Expected: Export function Z that does W"
   ```

## Task Isolation Principle

Each task must be **completely self-contained**. The task executor agent receives ONLY the task text - it has no access to:
- The original goal
- Other tasks in the list
- Previous conversation context

Include EVERYTHING needed in each task's context block.

## Example Output

For goal "Add user authentication":

```
- [ ] Create JWT utility functions
  Path: /project/src/utils/jwt.ts
  Pattern: Follow utility pattern in /project/src/utils/hash.ts
  Dependencies: jsonwebtoken package is installed
  Expected: Export signToken() and verifyToken() functions
- [ ] Create auth middleware
  Path: /project/src/middleware/auth.ts
  Pattern: Follow middleware pattern in /project/src/middleware/logging.ts
  Dependencies: JWT utils exist at src/utils/jwt.ts
  Expected: Export authMiddleware that validates JWT from cookies
- [ ] Add login endpoint
  Path: /project/src/routes/auth.ts
  Pattern: Follow route pattern in /project/src/routes/users.ts
  Dependencies: Auth middleware exists, User model exists
  Expected: POST /login that validates credentials and sets JWT cookie
```

## Goal to Plan

$ARGUMENTS
