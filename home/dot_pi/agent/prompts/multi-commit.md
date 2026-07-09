---
description: Analyze uncommitted changes and create multiple logical commits
argument-hint: "[instructions]"
---
Analyze all uncommitted changes and organize them into multiple well-crafted commits.

First gather:
- Current branch
- `git status --porcelain=v1`
- `git diff --cached`
- `git diff`
- `git ls-files --others --exclude-standard`
- Recent commit style with `git log --oneline -5`

Then propose logical commit groupings by feature boundary, bug fix vs feature, configuration vs implementation, refactor vs behavior change, tests, documentation, and dependencies.

Present the grouping plan and ask for confirmation before staging or committing. After confirmation, stage files or hunks carefully. Never use `git add .`, `git add -A`, or `git commit -am`.

Additional instructions:
$ARGUMENTS
