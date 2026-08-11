# Rules, CI, and stack evaluation

Source: [Stacked pull requests reference](https://docs.github.com/en/pull-requests/reference/stacked-pull-requests)

Public preview.

## Core rule

Every PR in a stack is evaluated against the **stack base (trunk)** — typically
`main` — **not** merely against the branch immediately below it. Mid-stack PRs
meet the same bar as the bottom PR.

## Branch protections and required checks

| Rule | Evaluation |
| --- | --- |
| Required reviews | Against stack base |
| Required status checks | Against stack base |
| CODEOWNERS | From stack base. A lower PR that changes `CODEOWNERS` does **not** change how higher PRs in the same stack are evaluated |
| Code scanning workflows | Against stack base |

## GitHub Actions

Workflows that run on `pull_request` targeting the default/trunk branch run for
**every** PR in the stack. Existing CI usually needs **no** path filter changes
to “light up” mid-stack PRs.

Implication: an *N*-PR stack can multiply CI cost ~*N*× per push wave. Use stack
metadata to skip expensive jobs where safe — see
[optimizing-ci.md](optimizing-ci.md).

Metadata path: `github.event.pull_request.stack` (null/absent for non-stacked
PRs).

## Merge requirements (summary)

For PR *k* to merge:

1. PR *k* satisfies stack-base protections.
2. Every PR below *k* also satisfies them.
3. History is fully linear across stack branches.

Example: `main ← PR1 ← PR2 ← PR3` — merging PR3 requires PR1 and PR2 green and
approved too.

## Linear history

Lost when:

- Commits are pushed to a lower branch without restacking above, or
- Trunk moves ahead of the bottom layer.

Restore:

```shell
gh stack rebase && gh stack push
# or UI: Rebase stack
```

## Merge methods and queue

See [merging.md](merging.md) for squash/merge/rebase semantics and merge-queue
stack behavior (50% size buffer, eject cascades upward).

## Availability constraints

- Same repository only (no forks in the chain).
- Not supported in GitHub Desktop.
- No special org “enable stacks” flag for basic use; rollout is process + tooling
  (async merge API for bots) — [org-rollout.md](org-rollout.md).
