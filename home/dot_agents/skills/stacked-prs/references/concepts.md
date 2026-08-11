# Concepts — stacked pull requests

Source: [About stacked pull requests](https://docs.github.com/en/pull-requests/get-started/about-stacked-prs),
[Stacked pull requests reference](https://docs.github.com/en/pull-requests/reference/stacked-pull-requests)

Public preview; subject to change.

## Definition

A **stack** is two or more pull requests in the **same repository** where:

1. The **bottom** PR targets the stack **trunk** (default branch, or any chosen base such as a release branch).
2. Each subsequent PR targets the **head branch of the PR below it**.

```text
   ┌── feat/frontend     → PR #3 (base: feat/api-endpoints)  ← top
  ┌── feat/api-endpoints → PR #2 (base: feat/auth-layer)
 ┌── feat/auth-layer     → PR #1 (base: main)               ← bottom
main (trunk)
```

Each PR is one discrete, reviewable layer (one or more commits). The UI diff for
a layer is **only** the changes between that branch and the branch below it.

## Dependency principle

If code in one layer depends on code in another, the dependency must live in:

- the **same** branch, or
- a **lower** branch.

Create a new branch when you start a different concern that depends on what you
already built (backend → frontend, core → tests, or when the current branch is
already large enough to review).

## Why stacks exist

| Problem without stacks | What stacks fix |
| --- | --- |
| Wait for base work to merge before starting dependents | Open the next PR on top of still-open work |
| Huge PRs get skimmed / go stale | Small per-layer diffs |
| Hand-maintained dependent branches | Cascading rebase (CLI or server-side) |
| CI/rules only feel real on bottom PR | Every layer evaluated against stack base |
| AI/agents dump large multi-step diffs | One PR per task with explicit dependency order |

## Where stacks work

| Surface | Support |
| --- | --- |
| GitHub CLI (`gh stack` extension) | Full local workflow |
| github.com | Create, view stack map, rebase, merge, unstack |
| GitHub Mobile | Supported |
| Webhooks, REST, GraphQL | Programmatic (GraphQL read-only for stack shape) |
| Agents | Official `gh-stack` skill (`gh skill install github/gh-stack`) |
| GitHub Desktop | **Not** supported |
| Cross-fork | **Not** supported |

CLI is optional for creation on the website; it is the best path for rebase,
restructure (`modify`), navigation, and sync.

## Trunk

- **Trunk** = base branch of the bottom PR.
- Default: repository default branch.
- Override CLI: `gh stack init --base <branch> ...`
- Override web: open bottom PR against the desired trunk.

Branch protection, required checks, and CI for the stack are evaluated against
**that trunk**, not only against `main` if trunk differs.

## UI signals on github.com

When a PR is in a stack:

- **Stack icon** + layer number in the PR header.
- **Stack map** in the merge box: every PR, status, one-click navigation; trunk
  at the bottom.

## Rebase model

Rebasing is the hard part of dependent branches; GitHub treats the chain as a
unit:

- **Local cascading rebase:** `gh stack rebase` (+ `gh stack push`).
- **Server-side cascading rebase:** **Rebase stack** in the merge box when
  history is non-linear.
- **On bottom merge:** remaining open branches are automatically rebased so the
  next PR targets the stack base.

Server-side rebase commits are **not signed**. Prefer CLI rebase when signed
commits are required.

## Related references

- Creating: [creating.md](creating.md)
- Rules/CI details: [rules-and-ci.md](rules-and-ci.md)
- Merging: [merging.md](merging.md)
