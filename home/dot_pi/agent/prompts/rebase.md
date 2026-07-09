---
description: Fetch remote changes and rebase the current branch on the default branch
argument-hint: "[base-branch]"
---
Rebase the current branch on top of the default branch.

Base branch: `$1` if provided, otherwise detect `origin/HEAD` or use `main`.

Workflow:
1. Check `git status --porcelain=v1`.
2. If there are uncommitted changes, stop immediately and tell the user to commit or stash before rebasing.
3. Run `git fetch origin`.
4. Run `git rebase origin/<base-branch>`.
5. If conflicts occur, inspect each conflicted file carefully, resolve conflicts preserving the branch's intended changes while incorporating base changes, stage resolved files, and continue the rebase.
6. Report the result and list rebased commits.

Do not continue through ambiguity without asking.
