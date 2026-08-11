# Troubleshooting stacked pull requests

Source: [Troubleshooting stacked pull requests](https://docs.github.com/en/pull-requests/how-tos/merge-and-close-pull-requests/troubleshooting-stacked-pull-requests)

Public preview.

## Rebase reports a conflict

```shell
# fix <<<<<<< markers in listed files
git add .
gh stack rebase --continue
# give up:
gh stack rebase --abort
```

## Sync stopped because of a conflict

`gh stack sync` restores all branches to pre-sync state if it detects conflict
during its rebase step. Resolve interactively:

```shell
gh stack rebase
gh stack push
```

## Modify session will not start

Check all of:

- Active stack checked out
- Clean working tree
- No rebase in progress
- No PR queued to merge
- Linear history — if not, `gh stack rebase` first

## Modify session interrupted

Pre-modify snapshot is cached locally:

```shell
gh stack modify --abort
# or after fixing conflicts mid-apply:
git add .
gh stack modify --continue
```

Exit code **10** = modify interrupted; recovery required.

## Pull request cannot merge

Verify:

- This PR **and every PR below** have required reviews + passing checks
- History is linear (rebase if lower layer or trunk moved)

```shell
gh stack rebase && gh stack push
# or UI: Rebase stack
```

## Merge stopped partway through the stack

Pre-merge checks run first, but a later failure (unexpected conflict,
intermittent error) can stop mid-land:

- Successfully merged lower PRs **stay** on the base branch
- Failed PR and everything above stay open

Fix the failed PR, then merge again to land the rest.

Note: CLI/API stack merge is documented as all-or-nothing for the requested
group; partial land is called out for the general merge path in troubleshooting.

## PR removed from merge queue

Ejecting one stacked PR ejects **all above it**. Fix root cause, re-queue.

Large stacks may split across consecutive merge groups (queue allows +50% max
group size to keep stacks together when possible).

## Closed PR in the middle of the stack

Closing a mid-stack PR **blocks** all PRs above from merging. Stack links remain.

To replace structure: unstack (web or `gh stack unstack`) and recreate, or
`gh stack modify`. Unstack removes open/draft/closed only; merged/queued stay.

## Commits unsigned after rebase

UI **Rebase stack** produces **unsigned** commits. If signed commits are
required:

```shell
gh stack rebase
gh stack push
```

Local rebase honors local signing config.

## Cannot create stack across forks

Unsupported. All branches must live in the same repository. Fork-based
contribution workflows stay outside stacks for now.

## Diverged local vs remote stack

See [managing.md](managing.md) — `gh stack sync` divergence choices; or unstack
and recreate.

## Useful exit codes (`gh stack`)

| Code | Meaning |
| --- | --- |
| 2 | Not in a stack / not found |
| 3 | Rebase conflict |
| 4 | GitHub API failure |
| 6 | Branch in multiple stacks |
| 7 | Rebase already in progress |
| 8 | Stack locked by another process |
| 9 | Stacked PRs not enabled for repo |
| 10 | Modify recovery required |

Full table: [cli-commands.md](cli-commands.md)
