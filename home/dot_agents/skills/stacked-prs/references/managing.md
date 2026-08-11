# Managing stacked pull requests

Source: [Managing stacked pull requests](https://docs.github.com/en/pull-requests/how-tos/create-pull-requests/managing-stacked-pull-requests)

Public preview. Prefer `gh stack` cascading ops over manual multi-branch rebase.

## Change a lower layer

Do **not** workaround a lower-layer bug on the top branch. Fix the owning layer,
then rebase upward.

```shell
gh stack down                    # or: gh stack checkout BRANCH-NAME
git add .
git commit -m "helpful-commit-message"
gh stack rebase --upstack
gh stack push
gh stack top
```

## Rebase the stack

Linear history between stack branches is required before merge.

```shell
gh stack rebase                  # full cascade from trunk upward
gh stack rebase --downstack      # trunk → current
gh stack rebase --upstack        # current → top
gh stack push                    # uses --force-with-lease
```

### Conflicts

`gh stack rebase` stops and lists conflicted files:

```shell
# fix markers, then:
git add .
gh stack rebase --continue
# or restore everything:
gh stack rebase --abort
```

### Server-side rebase (website)

When the stack is non-linear, merge box shows **Rebase stack**:

1. Rebases entire stack onto latest trunk.
2. Rebases each unmerged branch onto its parent, bottom → top.
3. Force-pushes each branch; PRs update; CI re-runs.

**Unsigned commits:** server-side rebase does not sign. If the repo requires
signed commits, use `gh stack rebase` + `gh stack push` instead.

## Restructure with `gh stack modify`

Preconditions:

- Active stack checked out
- Clean working tree
- No rebase in progress
- No PR queued to merge
- Linear history

```shell
gh stack modify
# stage ops, then Ctrl/Cmd+S to apply
# conflict: fix → git add → gh stack modify --continue
# or: gh stack modify --abort
gh stack submit                  # push + recreate remote stack
```

| Key | Operation |
| --- | --- |
| `x` | Drop branch + commits from stack (branch/PR kept) |
| `d` | Fold into branch below (toward trunk) |
| `u` | Fold into branch above (toward top) |
| `i` / `I` | Insert empty branch below / above |
| `r` | Rename |
| `Shift+↑` / `Shift+↓` | Reorder |
| `z` | Undo last staged action |

Do not mix reordering with structural changes (drop/fold/insert/rename) in one
modify session.

## Unstack (website)

**Unstack** dissolves linkage for open/draft/closed PRs. Each keeps its current
base but loses stack map and stack merge requirements.

- **Merged and queued PRs stay in the stack** and cannot be unstacked.
- Stack fully dissolves only if nothing is merged/queued; otherwise it persists
  with those PRs still stacked.

Prefer `gh stack modify` to reorder without dissolving. CLI:
`gh stack unstack` / `gh stack unstack --local`.

## Sync after merges / remote changes

```shell
gh stack sync --prune
```

Does: fetch → reconcile remote stack → FF trunk → cascade rebase if trunk moved
→ push → sync PR statuses → ensure stack object → optional prune of merged
local branches.

### Remote-ahead (safe)

PRs added on GitHub on top of your local stack are pulled and appended
automatically — safe for automation.

### Diverged stacks

Neither side is a clean prefix of the other (e.g. local add + different remote
adds). Interactive choices:

1. **Remote wins** — replace local composition (needs clean worktree).
2. **Delete stack on GitHub** — stack object only; PRs/branches kept; recreate
   with `gh stack submit` (optionally `modify` first). This is how to make
   GitHub match local when structures differ.
3. **Cancel**

Non-interactive: abort without push/PR updates; unstack + recreate to fix.

## Related

- Command flags: [cli-commands.md](cli-commands.md)
- Review fixes: [reviewing.md](reviewing.md)
- Merge: [merging.md](merging.md)
- Failures: [troubleshooting.md](troubleshooting.md)
