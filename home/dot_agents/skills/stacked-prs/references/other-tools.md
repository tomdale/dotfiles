# Use other tools with stacked pull requests

Source: [Use other tools with stacked pull requests](https://docs.github.com/en/pull-requests/reference/use-other-tools-with-stacked-pull-requests)

Public preview.

Stacks are ordinary Git branches + PR base chaining. Local branch management can
use **Jujutsu (jj)**, **Sapling**, **git-town**, or plain Git. GitHub only needs
the correct branch chain and stack linkage.

## Link without local `gh stack` tracking

`gh stack link` talks to the GitHub API only — **no** local stack tracking.

- Pushes named branches
- Reuses existing open PRs or creates **draft** PRs with correct bases
- Creates or additively updates the remote stack
- Never removes existing stack members

Args are **bottom → top**.

### Example (Jujutsu)

```shell
jj new main -m "first change"
jj bookmark create change1 --revision @

jj new -m "second change"
jj bookmark create change2 --revision @

jj new -m "third change"
jj bookmark create change3 --revision @

gh stack link change1 change2 change3
```

### Add more layers

Pass the **full** ordered list (existing PRs by number + new branches):

```shell
gh stack link 123 124 125 change4 change5
```

Or append via stack number (see CLI ref):

```shell
gh stack link 7 48 feature-ui
```

### Flags

```shell
gh stack link --base develop --open change1 change2 change3
```

| Flag | Effect |
| --- | --- |
| `--base` | Trunk for a new stack |
| `--open` | Ready for review instead of draft |
| `--remote` | Push remote |

## Full local tracking later

To unlock `rebase` / `sync` / navigation:

```shell
gh stack init change1 change2 change3
gh stack submit
```

`init` adopts existing branches; then use the normal `gh stack` workflow.

## When to choose what

| Approach | Use when |
| --- | --- |
| `gh stack` end-to-end | You want GitHub-native local UX |
| External VCS + `gh stack link` | Team already standardized on jj/Sapling/etc. |
| Website only | No CLI; create PRs with chained bases + Create stack |

## Related

- Full `link` semantics: [cli-commands.md](cli-commands.md)
- Creating on web: [creating.md](creating.md)
