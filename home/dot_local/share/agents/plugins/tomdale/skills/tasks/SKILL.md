---
name: tasks
description: Manage a portable markdown task queue in `.agent/tasks.md`. Use when the user wants work queued, split into follow-up tasks, or tracked outside the current conversation.
---

# Tasks

Use this skill for a lightweight personal task queue stored in
`.agent/tasks.md`.

The workflow is script-backed. Do not edit the task file directly when adding,
getting, completing, or archiving tasks.

## Default Task File

```text
.agent/tasks.md
```

## Helper Scripts

Resolve these relative to this skill directory:

- `../../scripts/task_add.js`
- `../../scripts/task_get.js`
- `../../scripts/task_complete.js`
- `../../scripts/task_archive.js`

## Task Format

```text
Task title
Path: /absolute/path/to/file.ts
Pattern: /absolute/path/to/reference-file.ts
Dependencies: What must already exist
Expected: Clear, verifiable completion criteria
Plan: Optional reference to a plan file
```

When stored in `.agent/tasks.md`, the first line becomes a markdown checkbox and
the context lines are indented under it.

## Common Operations

### Add A Task

Use the `write-task` skill first for validation, then call:

```bash
node ../../scripts/task_add.js .agent/tasks.md "<task text>"
```

### Get The Next Pending Task

```bash
node ../../scripts/task_get.js .agent/tasks.md
```

### Mark The First Pending Task Complete

```bash
node ../../scripts/task_complete.js .agent/tasks.md
```

### Mark The First Pending Task Blocked

```bash
node ../../scripts/task_complete.js .agent/tasks.md --blocked
```

### Archive A Finished Task File

```bash
node ../../scripts/task_archive.js .agent/tasks.md
```

## Working Rules

- Prefer one task per discrete unit of work.
- Keep tasks self-contained because the future executor may not have the full
conversation context.
- Use absolute file paths in the task body.
- Use specific pattern references instead of vague “follow conventions” notes.
