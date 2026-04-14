# Scripts

Shared helper scripts for the `tomdale` plugin live here.

Use this directory for utilities that are reused across multiple skills. If a
script should be executable after chezmoi applies the repo, name it with the
usual chezmoi executable prefix, for example:

```text
scripts/executable_refresh-context
```

Keep skill-specific helpers next to the skill unless they are reused elsewhere.

## Current Scripts

- `task_add.js`: append a new task to `.agent/tasks.md`
- `task_get.js`: print the first pending task
- `task_complete.js`: mark the first pending task complete or blocked
- `task_archive.js`: archive a fully completed task file
