---
description: Create branch (if needed), stage, commit, push, and open a GitHub PR in the browser.
argument-hint: [branch-name?] [base-branch?]
context: fork
disable-model-invocation: true
allowed-tools: >
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
HAS_CHANGESET=!`test -d .changeset && echo "true" || echo "false"`
NEW_BRANCH: $1 (may be empty)
BASE_BRANCH: $2 (default to !`git rev-parse --abbrev-ref origin/HEAD 2>/dev/null | sed 's/^origin\///' || echo 'main'` if empty)
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

`git log $BASE_BRANCH..HEAD` (commits ahead of base):
!`git log --oneline $(git rev-parse --abbrev-ref origin/HEAD 2>/dev/null | sed 's/^origin\///' || echo 'main')..HEAD 2>/dev/null || true`
</git-status>

<task>
You are operating in a git repository. Perform an end-to-end "ship a PR" workflow.

IMPORTANT: The `<git-status>` section above already contains the output of `git status`, `git diff --cached`, `git diff`, `git log`, and commits ahead of base. Use this information directly—do NOT re-run these commands redundantly.

1. **Stop if there is nothing to ship.**
   - Check the `<git-status>` output above.
   - Stop ONLY if ALL of the following are true:
     - Working tree and index are clean (no staged or unstaged changes)
     - AND there are no commits ahead of `$BASE_BRANCH`
   - If there are commits ahead of base but no uncommitted changes, skip to step 6 (push and open PR).

2. **Check whether a changeset is actually required** (only if `$HAS_CHANGESET` is `true`).
  - Do not treat the presence of `.changeset/` by itself as proof that this PR needs a changeset.
  - Require a new staged changeset only after confirming the changed package or workspace participates in Changesets, for example through repository docs, changeset config, existing changesets for that package, or package metadata.
  - In monorepos where Changesets are used only for unrelated packages, do not create or require a changeset for paths outside that scope.
  - If package participation cannot be confirmed from the repo context, ask the user instead of generating a changeset.

3. **Create a new branch only if appropriate.**
   - Determine `$BASE_BRANCH` as `$2` or `main`.
   - If `$BRANCH` is empty (detached HEAD) OR `$BRANCH == $BASE_BRANCH` OR `$BRANCH == master`, create/switch to a new feature branch:
     - If `$1` is provided, use it.
     - Else derive a branch name from the changes (short, kebab-case) prefixed with username, e.g. `username/router-cache`
   - If already on a non-base branch:
     - Compare staged changes against current branch name:
       - If the name matches the changes, continue on that branch.
       - Else, create/switch to a new feature branch as above.

4. **Stage changes** (skip if no uncommitted changes).
   - Review the unstaged changes shown in `<git-status>` above.
     - If all changes are relevant to the PR, stage all (`git add -A`).
     - Else, stage only relevant changes (specific files/hunks).
   - After staging, only run `git diff --cached` if you staged new changes (the pre-fetched output may be stale).

5. **Write a world-class commit message and commit** (skip if no staged changes).
   - Follow existing commit message conventions in the repo if any.
   - Follow any documented contributing guidelines if present.
   - Otherwise:
     - Use Conventional Commits: `type(scope): subject`
     - Subject ≤ 72 chars, imperative mood, no trailing period.
   - When writing the commit body:
     - Explain _what and why_ (not how)
     - Do not invent changes not present in the staged diff.
     - Focus on intent and purpose, and not ephemeral details (like 'new' vs
       'old') that are unhelpful out of the current context.
   - Then commit using that message.

6. **Push to origin.**
   - Push current branch with upstream (`-u origin <branch>`).

7. **Open a GitHub PR in the browser.**
   - If a PR already exists for the branch, open it in the browser (`gh pr view --web`) and stop.
   - Otherwise, create the PR with `gh pr create --web`:
     - CRITICAL: You **must always** pass the `--web` flag. NEVER create the PR directly.
     - Use `--base $BASE_BRANCH`.
     - Use `--head <current-branch>`.
     - Craft a `--title` and `--body` that summarizes ALL commits on this branch:
       - If there's only one commit, use its subject as the title and body as the description.
       - If there are multiple commits:
         - Title: A concise summary of the overall change (not just the last commit).
         - Body: A cohesive description of the PR's purpose, optionally with a bullet list of the key changes. Do NOT just list commit messages verbatim—synthesize them into a clear narrative.
       - Anchor the title and body against `$BASE_BRANCH`, not against an earlier draft, abandoned approach, force-pushed commit, review iteration, or any other ephemeral work.
       - Before including any contrast such as "now", "no longer", "replaces", or "moves from", ask whether the referenced prior state is likely to be relevant to the intended audience, who was not following every twist and turn of active development. If not, omit that contrast.
     - After `gh pr create --web` succeeds, treat the browser handoff as complete:
       - Do NOT check whether the PR exists yet.
       - Do NOT poll for a PR URL.
       - Do NOT fall back to creating the PR without `--web`.
       - The user may submit the browser form asynchronously, so the absence of an immediate PR is expected.
</task>

<output>
At the end, print Markdown formatted output with the following structure:

```
## <pr-title>
<opened-pr-url-or-browser-handoff-note>
[`<branch-name>` → `<base-branch>`]

<pr-body>
```

If `gh pr create --web` opened a new PR form, state that the browser form is
open and that no PR URL exists until the user submits it.
</output>
