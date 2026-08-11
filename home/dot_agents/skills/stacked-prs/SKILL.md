---
name: stacked-prs
description: >
  Create, manage, review, rebase, merge, and automate GitHub stacked pull
  requests with gh stack. Use when the user mentions stacked PRs, PR stacks,
  gh stack, dependent pull requests, cascading rebase, stack submit/sync/merge,
  mid-stack review fixes, stacking AI-generated code, or splitting a large
  change into ordered reviewable layers.
---

# Stacked pull requests

GitHub stacked PRs break one large change into a linear chain of smaller PRs in
the **same repository**. Bottom PR targets trunk (usually `main`); each PR above
targets the branch below it. Each layer shows only its own diff.

Public preview — behavior can change. Cross-fork stacks and GitHub Desktop are
unsupported. No org enablement step: if the repo can open PRs, it can stack.

## When to load this skill

Load when the task involves any of:

- splitting work into dependent PRs / a stack
- `gh stack` install, init, add, submit, sync, rebase, modify, merge, link
- fixing review feedback mid-stack and cascading changes upward
- merge-from-bottom / partial stack merge / merge queue + stacks
- CI, branch protection, CODEOWNERS, or API/webhook behavior for stacks
- stacking agent/AI-generated code into reviewable layers

## Mental model (read first)

```text
   ┌── feat/frontend     → PR #3 (base: feat/api)     ← top
  ┌── feat/api           → PR #2 (base: feat/auth)
 ┌── feat/auth           → PR #1 (base: main)         ← bottom
main  (trunk / stack base)
```

**Dependency rule:** if layer A needs code from layer B, B is the same branch or
a **lower** one. Foundational work (schema, shared types) at the bottom;
dependents (API, UI, tests that need the feature) higher.

**Evaluation rule:** every PR is judged against the **stack base** (trunk), not
only its direct parent: required reviews, status checks, CODEOWNERS, and
`pull_request` Actions that target trunk run for **every** layer.

**Merge rule:** bottom-up only. Merging a mid/top PR also merges everything
below it (contiguous prefix). Auto-merge is **not** supported for stacked PRs.
Stacks are merge-queue aware.

## Default agent workflow

Prefer `gh stack` over hand-rolled branch base juggling.

```shell
# one-time
gh extension install github/gh-stack
# optional agent skill from GitHub
gh skill install github/gh-stack

gh stack init <bottom-branch>          # or: gh stack init --base <trunk> ...
# commit on bottom layer
gh stack add <next-branch>             # or: gh stack add -Am "msg"
# commit per layer...
gh stack submit                        # push + create/link PRs (use --auto in CI)
gh stack view
```

Day-to-day:

| Goal | Command |
| --- | --- |
| Navigate | `gh stack up` / `down` / `top` / `bottom` / `trunk` / `switch` / `checkout` |
| Lower-layer fix | checkout layer → commit → `gh stack rebase --upstack` → `gh stack push` |
| Full refresh | `gh stack sync` or `gh stack sync --prune` |
| Restructure | `gh stack modify` then `gh stack submit` |
| Merge | `gh stack merge` (or UI); bottom-up / contiguous |
| External branch tool | `gh stack link <bottom> ... <top>` (no local tracking) |
| Adopt existing branches | `gh stack init b1 b2 b3` then `gh stack submit` |

Non-interactive submit: `gh stack submit --auto` (drafts by default; add
`--open` for ready-for-review).

## Load references by task

Do **not** dump every reference into context. Open only what the task needs:

| Task | Read |
| --- | --- |
| Concepts, constraints, why stacks | [references/concepts.md](references/concepts.md) |
| First stack / create on CLI or web | [references/creating.md](references/creating.md) |
| Full `gh stack` command/flag map | [references/cli-commands.md](references/cli-commands.md) |
| Lower-layer edits, rebase, modify, unstack, sync | [references/managing.md](references/managing.md) |
| Review feedback on a layer | [references/reviewing.md](references/reviewing.md) |
| Merge rules, partial merge, merge queue | [references/merging.md](references/merging.md) |
| Branch protection, linear history, merge methods | [references/rules-and-ci.md](references/rules-and-ci.md) |
| Actions metadata + cut redundant CI | [references/optimizing-ci.md](references/optimizing-ci.md) |
| Conflicts, blocked merge, queue eject, forks | [references/troubleshooting.md](references/troubleshooting.md) |
| REST / GraphQL / webhooks / async merge | [references/apis-and-webhooks.md](references/apis-and-webhooks.md) |
| jj / Sapling / git-town → GitHub stack | [references/other-tools.md](references/other-tools.md) |
| Org rollout checklist | [references/org-rollout.md](references/org-rollout.md) |
| Agent/AI layering workflow | [references/ai-generated-stacks.md](references/ai-generated-stacks.md) |

## Hard constraints (do not violate)

1. Same repository only — no cross-fork stacks.
2. Single linear chain — no branching stack graphs.
3. Keep history linear before merge (`gh stack rebase` or UI **Rebase stack**).
4. Server-side UI rebase commits are **unsigned** — if the repo requires signed
   commits, rebase with `gh stack rebase` locally, then `gh stack push`.
5. Programmatic merge of stacks requires the **asynchronous** merge API; legacy
   sync merge endpoints cannot merge a stack.
6. A fully merged stack cannot be extended; new work on top becomes a **new**
   stack rooted at trunk on next `gh stack submit`.
7. Closed mid-stack PR blocks everything above until the stack is restructured.
8. Do not put a fix on the wrong layer; fix the owning branch, then rebase up.

## Prerequisites

- `gh` ≥ 2.90.0 recommended (extension docs also mention ≥ 2.0 for install)
- Git ≥ 2.20
- `gh auth login` completed
- Push access to the repository

## Upstream docs

- https://docs.github.com/en/pull-requests/how-tos/stacked-pull-requests
- https://docs.github.com/en/pull-requests/get-started/about-stacked-prs
- https://docs.github.com/en/pull-requests/reference/stacked-prs-cli-commands
