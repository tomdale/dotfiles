# Optimizing CI for stacked pull requests

Source: [Optimizing CI for stacked pull requests](https://docs.github.com/en/pull-requests/how-tos/merge-and-close-pull-requests/optimizing-ci-for-stacked-pull-requests)

Public preview.

## How workflows run

Each stacked PR is treated as targeting the **stack base**. A workflow on
`pull_request` → `main` runs once **per PR in the stack**, not once per stack.
No change is required for checks to appear on mid-stack PRs.

Cost scales with stack height and push frequency. Gate expensive jobs with stack
metadata.

## Stack metadata fields

Available only when the PR is in a stack. Always null-check first.

| Expression | Meaning |
| --- | --- |
| `github.event.pull_request.stack.number` | Repo-scoped stack number |
| `github.event.pull_request.stack.size` | PR count in stack |
| `github.event.pull_request.stack.position` | 1-based index; `1` = bottom |
| `github.event.pull_request.stack.base.ref` | Ultimate trunk branch name |
| `github.event.pull_request.stack.base.sha` | HEAD SHA of trunk |

## Useful job conditions

**Lowest unmerged PR** (currently targets stack base directly):

```yaml
if: github.event.pull_request.stack != null && github.event.pull_request.stack.base.ref == github.event.pull_request.base.ref
```

After bottom merges, the next PR retargets trunk and becomes the new lowest
unmerged on subsequent runs.

**Top PR** (full cumulative tip of the feature):

```yaml
if: github.event.pull_request.stack != null && github.event.pull_request.stack.position == github.event.pull_request.stack.size
```

**Original bottom only:**

```yaml
if: github.event.pull_request.stack != null && github.event.pull_request.stack.position == 1
```

**Stack targets release trunk:**

```yaml
if: github.event.pull_request.stack != null && startsWith(github.event.pull_request.stack.base.ref, 'release/')
```

## Example workflow fragment

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v6

      - name: Show stack info
        if: github.event.pull_request.stack != null
        run: |
          echo "Stack base ref: ${{ github.event.pull_request.stack.base.ref }}"
          echo "PR ${{ github.event.pull_request.stack.position }} of ${{ github.event.pull_request.stack.size }}"

      - name: Expensive suite on top only
        if: github.event.pull_request.stack != null && github.event.pull_request.stack.position == github.event.pull_request.stack.size
        run: echo "full integration suite"

      - name: Deploy preview on lowest unmerged
        if: github.event.pull_request.stack != null && github.event.pull_request.stack.base.ref == github.event.pull_request.base.ref
        run: echo "preview against trunk"
```

## Design guidance

- Keep **required** checks honest: do not skip jobs that branch protection
  requires on every layer unless the required check set is intentionally
  split.
- Prefer skipping **optional expensive** work (large e2e, image builds) on
  middle layers while still running fast unit/lint everywhere.
- Remember position `1` is the **original** bottom; after merges, “lowest
  unmerged” is the `base.ref == pull_request.base.ref` check, not `position == 1`.
