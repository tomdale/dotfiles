# Roll out stacked pull requests to an organization

Source: [Roll out stacked pull requests](https://docs.github.com/en/pull-requests/tutorials/roll-out-stacked-prs)

Public preview. **No enablement toggle** — if the team already uses PRs, they
can stack. Rollout is preparation, pilot, support, and tooling updates.

## 1. Fit check

Good signals:

- High code volume (humans and/or coding agents)
- Large features / monorepos hard to split into **independent** PRs

Hard constraint to accept:

- Single repo, **linear** branch chain only
- No forks inside a stack; heavy fork contributors stay on non-stack flows

## 2. Foundations

No new branch-protection product required. Existing rules apply via stack base:

- Required reviews, status checks, CODEOWNERS → every layer vs trunk
- Actions on `pull_request` → trunk already run per stacked PR
- Optional: use `github.event.pull_request.stack` to tame CI cost  
  → [optimizing-ci.md](optimizing-ci.md)

Recommend **`gh stack`** when developers need in-place reorder without
dissolve/recreate (`gh stack modify`). Web-only teams unstack + recreate to
reorder.

Teach lifecycle:

- Stack **closes** when every PR has merged
- Further work on top → **new** stack on next `submit`, not an extension of the
  completed stack
- Keep a stack open until the related body of work is done if continuity matters

## 3. Pilot

- Small group with real high-volume or agent-assisted work
- Real feature, not a toy
- Point at [creating.md](creating.md) / upstream quickstart
- Collect feedback: planning fit, need for `modify`, review load with per-layer
  checks, doc gaps

## 4. Broad rollout

Share day-to-day links (create, review, manage, merge). For agent-heavy teams,
add [ai-generated-stacks.md](ai-generated-stacks.md).

## 5. Programmatic tooling (blocking)

| Item | Action |
| --- | --- |
| Merge bots / ChatOps | **Must** use asynchronous merge API; legacy sync merge cannot merge stacks |
| Dashboards | Read null-safe `stack` on PR payloads |
| Webhooks | Optional `stacked` action + `stack` object on `pull_request` |
| Internal CLIs | Optional Stacks REST API so devs need not all adopt `gh stack` |

Details: [apis-and-webhooks.md](apis-and-webhooks.md)

## Success criteria (practical)

- Reviewers get small layer diffs without losing trunk-level quality gates
- Rebase/restack is routine (`sync` / `rebase`), not heroics
- No production merge bot still on sync merge endpoints
- CI cost understood and gated where appropriate
