# Stacked PRs — APIs and webhooks

Source: [Stacked pull requests APIs and webhooks](https://docs.github.com/en/pull-requests/reference/stacked-pull-requests-apis-and-webhooks)

Public preview.

## REST API

Two surfaces:

1. **`stack` object on PR resources** — when a PR is stacked, responses include
   stack membership (number, size, position, base). Standalone PRs: `stack` is
   `null` (existing integrations keep working).
2. **Stacks API** — list/read/create/extend/dissolve stacks  
   e.g. `GET /repos/{owner}/{repo}/stacks`  
   Full schemas: [REST pull requests](https://docs.github.com/en/rest/pulls/pulls)

Use REST to create/modify stacks in internal CLIs instead of forcing `gh stack`
on every developer.

### Asynchronous merge (required for stacks)

Legacy synchronous merge endpoints **cannot** merge a stacked PR.

Use the **asynchronous merge** endpoint, then poll for the result:

- [Merge a pull request asynchronously](https://docs.github.com/en/rest/pulls/pulls?apiVersion=2026-03-10#merge-a-pull-request-asynchronously)
- [Get the result of an asynchronous merge](https://docs.github.com/en/rest/pulls/pulls?apiVersion=2026-03-10#get-the-result-of-an-asynchronous-merge)

Behavior:

- Merging a stacked PR merges/queues **every PR from bottom through the
  requested PR**.
- Multi-PR land can take minutes → runs in background; poll status.
- Submit-time check is basic open-PR state; branch protection/rules evaluated
  when merge executes; failures appear in poll result.
- Requested group is **atomic**: whole group merges or queues, or none does.

Bots, ChatOps, and internal merge tools **must** move to async merge before
org-wide stack rollout.

## GraphQL API

Read-only `stack` / `stackEntry` fields on `PullRequest`.

- Query membership and position.
- **No** stack mutations in GraphQL — use REST to create/change stacks.

Reference: [GraphQL pull requests](https://docs.github.com/en/graphql/reference/pulls#object-pullrequeststack)

## Webhooks

When a PR is in a stack, `pull_request` event payloads include a `stack` object
(same idea as REST: target trunk context, not only direct parent).

- Present on lifecycle events while the PR remains stacked.
- Dedicated **`stacked`** action fires when a PR is first added to a stack.

Docs: [Webhook events — pull_request](https://docs.github.com/en/webhooks/webhook-events-and-payloads?actionType=stacked#pull_request)

## Actions expressions

In workflows: `github.event.pull_request.stack` — see
[optimizing-ci.md](optimizing-ci.md).

## Org checklist

Before rollout:

- [ ] Replace sync merge API usage with async merge
- [ ] Teach dashboards/bots to read `stack` (null-safe)
- [ ] Optionally handle `stacked` webhook action
- [ ] Optionally use Stacks API in internal developer tooling

See [org-rollout.md](org-rollout.md).
