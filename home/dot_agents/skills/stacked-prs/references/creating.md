# Creating stacked pull requests

Sources:

- [Quickstart](https://docs.github.com/en/pull-requests/get-started/stacked-prs-quickstart)
- [Creating stacked pull requests](https://docs.github.com/en/pull-requests/how-tos/create-pull-requests/creating-stacked-pull-requests)

Public preview. Same-repo only; no cross-fork stacks.

## Prerequisites

- GitHub CLI `gh` ≥ 2.90.0 (quickstart), Git ≥ 2.20
- `gh auth login`
- Push access to the repo

## Install

```shell
gh extension install github/gh-stack

# Optional: agent skill for Copilot / coding agents
gh skill install github/gh-stack
```

## CLI: first stack

```shell
# 1. Start stack (prompts for branch name, or pass it)
gh stack init
# or non-interactive:
gh stack init feature-auth
# custom trunk:
gh stack init --base develop feature-auth

# 2. Commit layer 1
git add .
git commit -m "helpful-commit-message"

# 3. Next layer
gh stack add feature-api
git add .
git commit -m "another-helpful-commit-message"

# Commit + new branch helpers:
# - If current branch has no commits yet, commit lands there
# - If it already has commits, creates the next branch
gh stack add -Am "Auth middleware"
gh stack add -Am "API routes"

# 4. Push branches only
gh stack push

# 5. Push + create/link PRs as a stack
gh stack submit

# 6. Inspect
gh stack view
gh stack view --short
gh stack view --json
```

`submit` sets each PR base correctly (bottom → trunk, each higher PR → branch
below). Reviewers see **per-layer** diffs only.

### Submit behavior notes

- Interactive TUI: edit titles/bodies, include/exclude branches, draft vs ready.
- Non-interactive / CI: `gh stack submit --auto` (new PRs default to **draft**
  unless `--open`).
- If all PRs in the old stack already merged, `submit` starts a **new** stack
  for remaining unmerged branches rather than extending the completed stack.
- Branches already with PRs but no stack: can link via submit UI (`Ctrl+B`) or
  `gh stack link`.

## CLI: adopt existing branches

```shell
gh stack init feature-auth feature-api feature-ui
gh stack submit
```

Existing branches are adopted; missing names are created. Enables `git rerere`
automatically.

## Website: create stack

1. Open first PR as usual (base = trunk, often `main`).
2. Open next PR with **base = previous PR’s head branch**.
3. Choose **Create stack** to link them.
4. Repeat: each new PR bases on the previous head.

UI shows stack icon/layer number and stack map in the merge box.

### Recommendation banner

If open PRs already form a correct base chain (each base is the head below),
GitHub may show a banner to turn the chain into a stack. Confirm the preview
(top → bottom order).

### Add to existing stack (web)

1. Open any PR in the stack → stack control → **Add to stack**.
2. Base is set to current top head; choose new head branch → create PR → add.

New PR lands on the **top** of the stack.

## After create

- Manage/rebase/restructure: [managing.md](managing.md)
- Review flow: [reviewing.md](reviewing.md)
- Merge: [merging.md](merging.md)
