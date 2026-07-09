---
description: Print concise git context for the current repository
argument-hint: "[base-branch]"
---
Print concise git context for the current repository. Use bash read-only git/gh commands.

Include:
- Current branch
- Repository name if `gh repo view` works
- Default/base branch, using `$1` if provided, otherwise the remote default branch or `main`
- `git status --porcelain=v1`
- Staged diff summary and unstaged diff summary
- Recent commits
- Commits ahead of the base branch

Do not modify files.
