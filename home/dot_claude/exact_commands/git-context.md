---
description: Print the git CONTEXT for the current repository.
argument-hint: "[branch-name?] [base-branch?]"
fork: true
disable-model-invocation: true
allowed-tools: >
  WebFetch(domain:api.github.com),
  Bash(git status:*),
  Bash(git diff:*),
  Bash(git rev-parse:*),
  Bash(git branch:*),
  Bash(git checkout:*),
  Bash(git add:*),
  Bash(git commit:*),
  Bash(git push:*),
  Bash(git log:*),
  Bash(gh auth status:*),
  Bash(gh repo view:*),
  Bash(gh pr create:*),
  Bash(gh pr view:*),
  Bash(date:*),
  Bash(sed:*),
  Bash(tr:*)
---
<arguments>
USERNAME=!`gh auth status --active --json hosts --jq '.hosts[][].login'`
REPO_NAME=!`gh repo view --json nameWithOwner --jq '.nameWithOwner' 2>/dev/null || true`
BRANCH=!`git branch --show-current 2>/dev/null || true`
NEW_BRANCH: `$1` (may be empty)
BASE_BRANCH: `$2` (default to !`git rev-parse --abbrev-ref origin/HEAD 2>/dev/null | sed 's/^origin\///' || echo 'main'` if empty)
</arguments>

<git-status>
`git status`:
!`git status --porcelain=v1`

`git diff --cached`:
!`git diff --cached`

`git diff`:
!`git diff`

`git log`:
!`git log --oneline -10`
</git-status>

Print JUST the results within the tags above **verbatim** and stop. If empty, stop and explain that the repository is not a git repository.
