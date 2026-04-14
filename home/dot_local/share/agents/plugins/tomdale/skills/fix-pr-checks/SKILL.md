---
name: fix-pr-checks
description: Diagnose and fix failing GitHub PR checks for the current branch. Use when CI is red, PR checks are failing, or the user asks to fix checks or pipeline failures.
---

# Fix PR Checks

Use this skill when the relevant source of truth is GitHub CI, not just local
test output.

## Workflow

1. Identify the current PR.
2. Inspect failing checks.
3. Pull failed logs for each check.
4. Group failures by root cause.
5. Fix the underlying issue locally.
6. Re-run the closest local verification you can.
7. Re-check PR status.

## Core Commands

Find the PR:

```bash
gh pr view --json number,state,title,headRefName
```

Inspect checks:

```bash
gh pr checks --json name,bucket,state,description,link,workflow
```

Fetch failed logs from a run URL:

```bash
gh run view <run-id> --log-failed
```

If that is sparse, inspect jobs:

```bash
gh run view <run-id> --json jobs
```

## Working Rules

- Do not treat each failed check as independent until you have grouped them.
- Prefer fixing a shared root cause over chasing symptoms one by one.
- Map remote failures to local commands whenever possible before editing.
- If the failure is infra-only or permission-related, say so quickly instead of
pretending it is a code bug.

## What To Extract From Each Failure

- Category: lint, typecheck, test, build, packaging, deploy, other
- Root cause
- Affected files or modules
- Fastest local verification command

## Good Output

After inspection, summarize:

- which checks are failing
- which ones share a cause
- what you changed
- what you verified locally
- what still requires GitHub to confirm
