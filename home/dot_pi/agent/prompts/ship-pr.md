---
description: Prepare branch, commit changes, push, and open a GitHub PR
argument-hint: "[branch-name] [base-branch]"
---
Perform an end-to-end PR shipping workflow for the current git repository.

Arguments:
- Desired branch name: `$1` optional
- Base branch: `$2` optional, otherwise detect remote default or use `main`

Rules:
1. Stop if there are no uncommitted changes and no commits ahead of base.
2. If on the base branch or `master`, create/switch to a feature branch. If no branch name was provided, derive a short kebab-case name prefixed with `tomdale/`.
3. Review `git status`, staged/unstaged diffs, untracked files, recent commits, and commits ahead of base.
4. Stage only files that belong to the current logical change. Do not blindly `git add .`.
5. Use the `code-committer` subagent for commit creation when uncommitted changes need committing.
6. Push the branch and open a PR with `gh pr create`.
7. Write a concise PR title and body. Include verification steps as project-level commands, not local environment workarounds.

Ask before doing destructive or ambiguous git operations.
