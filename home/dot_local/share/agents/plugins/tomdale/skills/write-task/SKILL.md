---
name: write-task
description: Validate and add a well-formed task to `.agent/tasks.md`. Use when adding a task to the markdown task queue.
---

# Write Task

Use this skill before appending anything to `.agent/tasks.md`.

The helper script to use lives at `../../scripts/task_add.js`, resolved
relative to this skill directory.

## Hard Rules

Reject the task if any of these fail:

1. Single responsibility
2. Absolute `Path:`
3. Specific `Pattern:` reference for code tasks
4. Clear, verifiable `Expected:`
5. Enough context for isolated execution

## Validation Checklist

### Single Responsibility

If the task is naturally described with “and”, it is probably too large.

### Absolute Path

`Path:` must begin with `/`.

### Specific Pattern

Prefer:

```text
Pattern: /absolute/path/to/existing/file.ts
```

Avoid vague guidance like:

```text
Pattern: Follow existing conventions
```

### Verifiable Expected Outcome

Someone should be able to check whether the task is done without guessing.

### Self-Contained Context

Assume the future executor sees only the task text.

## Add The Task

Once the task is valid, add it with:

```bash
node ../../scripts/task_add.js .agent/tasks.md "<task text>"
```

## Rejection Style

When rejecting a task:

- say exactly which requirement failed
- say what concrete detail is missing
- do not write the task until it is fixed
