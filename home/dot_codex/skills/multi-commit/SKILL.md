---
name: multi-commit
description: Analyze local uncommitted git changes, propose logical commit groupings, get user confirmation, and create multiple focused commits instead of one catch-all commit.
---

# Multi-Commit

Use this skill when the user wants the current worktree split into multiple commits, or asks to group unrelated changes into separate commits.

## Overview

This workflow should inspect the current git state, identify logical commit boundaries, present the proposed grouping first, and only create commits after the user confirms the plan.

## Workflow

1. Inspect the worktree before proposing anything.
   - Run `git status --short`.
   - Review staged changes with `git diff --cached`.
   - Review unstaged changes with `git diff`.
   - Review untracked files with `git ls-files --others --exclude-standard`.
   - Use `git log --oneline -5` if recent commit style is helpful context.
2. Stop early when appropriate.
   - If there are no uncommitted changes, say so and stop.
   - If everything clearly belongs in one commit, say that and ask whether the user still wants a single commit instead.
   - If a rebase, merge, or conflict is in progress, surface that before making changes.
3. Group changes into logical commits.
   - Separate feature work from bug fixes.
   - Separate refactors from behavior changes.
   - Separate configuration or tooling updates from product code where practical.
   - Keep tests with their implementation unless the test change is independently meaningful.
   - Keep docs-only changes separate when they do not need to travel with code.
   - Separate dependency updates when they are meaningfully independent.
4. Present the proposed commits before staging or committing.
   - Include a title for each commit.
   - Include a likely commit type such as `feat`, `fix`, `refactor`, `docs`, `test`, or `chore`.
   - List the files in each group.
   - Briefly explain why the grouping is coherent.
   - Call out any file that mixes concerns and may be hard to separate cleanly without manual editing.
5. Ask the user to confirm or adjust the grouping.
   - Offer to merge groups, split a group further, reorder commits, or keep everything together.
6. After confirmation, create the commits sequentially.
   - Stage only the explicit files for one group at a time.
   - Prefer explicit paths with `git add -- <paths>`.
   - If you need to unstage paths before regrouping, unstage only the relevant paths.
   - Commit each group with a focused message.
   - Re-check `git status --short` after each commit when the worktree is complex.
7. Finish by summarizing what was committed and what remains uncommitted, if anything.

## Output format

Use this structure when proposing the grouping:

```md
## Proposed Commits

### Commit 1: <brief description>
Type: feat/fix/refactor/docs/test/chore
Files:
- path/to/file1
- path/to/file2

Rationale: Why these changes belong together.
```

## Safety

- Never commit before showing the grouping and getting confirmation.
- Never use `git add .` or `git add -A` unless the user has explicitly confirmed the entire worktree belongs in scope.
- Prefer explicit file paths over broad staging.
- Do not use interactive staging commands such as `git add -p` unless the user explicitly asks for that workflow.
- If one file contains mixed changes that cannot be safely separated with non-interactive tooling, explain that constraint and ask whether to keep those changes together.
- Do not revert, rewrite, or discard unrelated user changes.

## Commit ordering

Prefer this order when possible:

1. Configuration or tooling changes that enable later work.
2. Pure refactors or preparatory cleanup.
3. Core implementation changes.
4. Tests.
5. Documentation.
