# Reviewing stacked pull requests

Source: [Reviewing stacked pull requests](https://docs.github.com/en/pull-requests/how-tos/review-pull-requests/reviewing-stacked-pull-requests)

Public preview.

## What reviewers see

Each stacked PR shows **only its layer diff** (branch vs parent branch), not the
cumulative feature. Reviewers can approve or request changes **per PR**.

Merge requirements still require the PR **and all PRs below it** to satisfy stack
base rules before that PR can merge — see [merging.md](merging.md).

## Addressing review feedback

Put the fix on the branch that owns the change, then cascade upward.

```shell
gh stack checkout BRANCH-NAME
# or: gh stack bottom | down | up | top

git add .
git commit -m "helpful-commit-message"

gh stack rebase          # cascade so higher branches include the fix
gh stack push            # --force-with-lease on rebased branches
```

After push, higher PRs reflect the update and CI re-runs.

## Review strategy tips

From the AI stacking tutorial and concepts docs:

- Prefer review **bottom-up** when layers are tightly coupled so fixes propagate
  before upper-layer review.
- Parallel review is fine when layers have different owners/concerns (e.g. data
  model vs endpoints).
- Keep titles/descriptions focused on **this layer’s** purpose.
- Author should self-review each small layer before requesting review.

## Anti-patterns

- Committing a lower-layer fix onto the top branch “for now”
- Force-pushing a single mid-stack branch without rebasing dependents
- Expecting auto-merge on stacked PRs (unsupported)

## Related

- Managing/rebase: [managing.md](managing.md)
- AI authoring loop: [ai-generated-stacks.md](ai-generated-stacks.md)
