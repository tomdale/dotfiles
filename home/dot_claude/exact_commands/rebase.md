---
description: Fetch changes from remote and rebase current branch on default branch
allowed-tools: Bash(git:*)
---

Rebase the current branch on top of the default branch.

**Default branch:** !`git rev-parse --abbrev-ref origin/HEAD 2>/dev/null | sed 's@origin/@@'`

**IMPORTANT: First check for uncommitted changes:**

Uncommitted changes check: `git status --porcelain`

If there are any uncommitted changes (the output is non-empty), STOP IMMEDIATELY and alert the user:
"Cannot rebase: You have uncommitted changes. Please commit or stash your changes before rebasing."
Do not proceed with any further steps.

**If no uncommitted changes, proceed with the rebase:**

1. Fetch the latest changes from origin:
   ```
   git fetch origin
   ```

2. Rebase the current branch on top of the default branch (shown above):
   ```
   git rebase origin/<default-branch>
   ```

3. If there are merge conflicts:
   - Examine each conflicted file carefully
   - Resolve conflicts by preserving our changes (the current branch's work) while incorporating any non-conflicting changes from the default branch
   - Be careful not to lose important work from either branch
   - After resolving each file, stage it with `git add <file>`
   - Continue the rebase with `git rebase --continue`
   - Repeat until all conflicts are resolved

4. Report the result:
   - If successful: List the commits that were rebased
   - If there were conflicts: Summarize what conflicts were resolved and how
