---
description: Analyze uncommitted changes, group them logically, and create separate commits for each group
---

# Multi-Commit

Analyze all uncommitted changes and create multiple well-organized commits.

## Context

- Current git status: !`git status --porcelain=v1`
- Current branch: !`git branch --show-current`
- Recent commits (for style reference): !`git log --oneline -5`

## Staged changes

!`git diff --cached`

## Unstaged changes

!`git diff`

## Untracked files

!`git ls-files --others --exclude-standard`

## Instructions

You are tasked with analyzing uncommitted changes and organizing them into
logical commit groups. This is useful when a developer has accumulated multiple
unrelated changes that should be committed separately.

### Step 1: Analyze Changes

Review all staged changes, unstaged changes, and untracked files above.
Categorize them into logical groups based on:

- **Feature boundaries**: Changes implementing different features
- **Bug fixes vs features**: Separate fixes from new functionality
- **Configuration vs code**: Infrastructure/config changes separate from
  implementation
- **Refactoring vs behavior changes**: Pure refactors separate from functional
  changes
- **Test additions vs implementation**: Tests can sometimes be grouped with
  implementation, but large test additions may warrant separate commits
- **Documentation**: Doc-only changes separate from code changes
- **Dependencies**: Package/dependency changes separate from code using them

### Step 2: Present Proposed Groupings

Present a clear summary of your proposed commit groupings in this format:

```
## Proposed Commits

### Commit 1: <brief description>
**Type**: feat/fix/refactor/docs/chore/test
**Files**:
- path/to/file1
- path/to/file2

**Rationale**: Why these changes belong together

---

### Commit 2: <brief description>
...
```

Include:
- A descriptive title for each commit
- The conventional commit type
- List of files in each group
- Brief rationale for the grouping

### Step 3: Get User Confirmation

After presenting the groupings, ask the user to confirm or request adjustments
using the AskUserQuestion tool. Offer options like:
- Proceed with proposed groupings
- Merge some groups together
- Split a group further
- Reorder the commits

### Step 4: Execute Commits

Once the user confirms, execute each commit group sequentially by spawning the
`code-committer` agent for each group.

For each group:
1. Stage ONLY the files for that group (use `git add <files>`)
2. Spawn the `code-committer` agent with a prompt like:
   "Commit the currently staged changes. These changes are: <description of the
   group>. Use commit type: <type>."
3. Wait for the agent to complete before proceeding to the next group

**Important**: Reset staging between groups if needed (`git reset HEAD`) to
ensure only the intended files are committed.

### Edge Cases

- **Single logical change**: If all changes belong together, inform the user and
  offer to use the regular `/commit` command instead.
- **No changes**: If there are no uncommitted changes, inform the user and stop.
- **Conflicts in grouping**: If files have interdependent changes that are hard
  to separate, explain this and suggest keeping them together.

### Commit Order

Order commits logically:
1. Infrastructure/config changes first (they often enable other changes)
2. Refactoring/preparation commits
3. Core implementation
4. Tests
5. Documentation

This ordering creates a clean, reviewable git history.
