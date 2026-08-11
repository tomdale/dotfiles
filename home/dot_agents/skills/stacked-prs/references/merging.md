# Merging stacked pull requests

Sources:

- [Merging stacked pull requests](https://docs.github.com/en/pull-requests/how-tos/merge-and-close-pull-requests/merging-stacked-pull-requests)
- [Stacked pull requests reference](https://docs.github.com/en/pull-requests/reference/stacked-pull-requests)

Public preview.

## Order

Stacks merge **bottom-up** (closest to trunk first).

- You may merge any **contiguous prefix** of unmerged PRs starting at the lowest
  unmerged PR.
- You **cannot** merge a mid-stack PR alone; everything below it merges with it.
- Merging the **top** PR merges the entire remaining stack beneath it.

After a partial merge, the next open PR is automatically rebased to target the
stack base directly and becomes the new bottom.

## Merge requirements

The merge box reflects **stack** status, not only the current PR. Before merge:

1. Current PR meets all branch protection rules for the **stack base**.
2. **All PRs below it** are approved and have passing checks (same base rules).
3. Stack has a **fully linear** history between branches.

If non-linear (lower push or trunk moved): **Rebase stack** (UI) or
`gh stack rebase` + `gh stack push` before merge.

### Not supported

- **Auto-merge** is not supported for stacked pull requests.
- Legacy **synchronous** merge API endpoints cannot merge stacks — use
  **asynchronous** merge API (see [apis-and-webhooks.md](apis-and-webhooks.md)).
- You cannot bypass merge requirements when merging stacked PRs.

## Merge methods

All three methods work; the selected group lands as one atomic operation:

| Method | Result |
| --- | --- |
| Merge commit | One merge commit for the group; preserves each PR’s full history |
| Squash | One squashed commit **per PR** (`n` PRs → `n` commits on base) |
| Rebase | Replays each PR’s commits onto base; linear, no merge commits |

Resulting history matches merging each PR individually bottom-up.

## Merge queue

- Entire selected stack enters the queue in order.
- Eject/remove one PR → all PRs **above** it also leave the queue.
- Queue may exceed configured max group size by **up to 50%** to keep a stack
  together; oversized stacks split across consecutive groups.
- Queue chooses merge method; CLI method flags are ignored with a warning when
  queueing.

## CLI merge

```shell
gh stack merge                 # interactive: choose prefix + method
gh stack merge 7               # by stack number (remote ok)
gh stack merge 42              # up to and including PR 42
gh stack merge --yes --squash  # whole current stack, no prompt
```

Pre-check is basic state only (open, not draft). Protections evaluated when
merge runs. Failure → none of the group merges (API/CLI all-or-nothing for the
requested group). See troubleshooting if a multi-step land stops mid-way on the
website path.

## After the stack fully merges

- Stack is **complete** and cannot be extended.
- New branches on top + `gh stack submit` → **new** stack at trunk.
- Local cleanup: `gh stack sync --prune`

## Related

- Rules details: [rules-and-ci.md](rules-and-ci.md)
- Problems: [troubleshooting.md](troubleshooting.md)
