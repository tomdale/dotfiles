# `gh stack` CLI command reference

Source: [Stacked pull requests CLI commands](https://docs.github.com/en/pull-requests/reference/stacked-prs-cli-commands)

Extension: `gh extension install github/gh-stack`  
Requires authenticated `gh`. Docs note extension needs `gh` ≥ 2.0; quickstart
recommends ≥ 2.90.0.

## Command summary

| Command | Purpose |
| --- | --- |
| `gh stack init` | Initialize a new local stack |
| `gh stack add` | Add branch on top of current stack |
| `gh stack view` | Show stack (branches, PRs, latest commits) |
| `gh stack checkout` | Check out stack by number / PR / URL / branch |
| `gh stack modify` | Interactive restructure |
| `gh stack unstack` (`delete`) | Drop local tracking + unstack on GitHub |
| `gh stack submit` | Push + create/update PRs + stack object |
| `gh stack sync` | Fetch, reconcile, rebase if needed, push, sync PR state |
| `gh stack rebase` | Cascading rebase |
| `gh stack push` | Push active stack branches (`--force-with-lease` per branch) |
| `gh stack link` | Create/update remote stack without local tracking |
| `gh stack merge` | Merge contiguous bottom prefix / whole stack |
| `gh stack switch` | Interactive branch picker in stack |
| `gh stack up` / `down` | Move toward top / trunk |
| `gh stack top` / `bottom` / `trunk` | Jump |
| `gh stack alias` | Install short alias (default `gs`) into `~/.local/bin/` |
| `gh stack feedback` | Open feedback discussion on `github/gh-stack` |

Navigation clamps at ends; no-op with a message if already at bound. `up` from
trunk moves to first stack branch.

---

## Stack management

### `gh stack init [flags] [branches...]`

```shell
gh stack init
gh stack init feature-auth
gh stack init --base develop feature-auth
gh stack init feature-auth feature-api feature-ui
```

| Flag | Description |
| --- | --- |
| `-b, --base <branch>` | Trunk (default: repo default branch) |

- Interactive: prompt for first branch; can use current branch as first layer.
- Named branches: adopt existing or create missing.
- Enables `git rerere` automatically.

### `gh stack add [flags] [branch]`

Must run on **topmost** stack branch. Creates branch at HEAD, appends to stack,
checks it out.

| Flag | Description |
| --- | --- |
| `-A, --all` | Stage all incl. untracked; requires `-m` |
| `-u, --update` | Stage tracked only; requires `-m` |
| `-m, --message <string>` | Commit before creating branch |

`-A` and `-u` are mutually exclusive. With `-m` and no branch name, branch name
is auto-generated (`03-24-add_login` style).

```shell
gh stack add api-routes
gh stack add -Am "Add login endpoint"
gh stack add -um "Fix auth bug"
gh stack add -m "Add user model"
gh stack add -Am "Add tests" test-layer
```

### `gh stack view [flags]`

Pager respects `GIT_PAGER` / `PAGER` (default `less -R`).

| Flag | Description |
| --- | --- |
| `-s, --short` | Branch names only |
| `--json` | Machine-readable |

### `gh stack checkout [<stack-number> \| <pr-number> \| <pr-url> \| <branch>]`

- Bare number: try stack/PR number (repo-scoped UI ids), else branch name.
- Remote stack: fetch branches and set up local tracking; prompt if local and
  remote compositions differ.
- Branch name: local tracked stacks only.
- No args (interactive): searchable picker (local + remote); tabs All/Local/Remote;
  fully merged stacks omitted.

```shell
gh stack checkout 7
gh stack checkout 42
gh stack checkout https://github.com/owner/repo/pull/42
gh stack checkout feature-auth
gh stack checkout
```

### `gh stack modify [flags]`

Interactive TUI. Stage ops, apply with `Ctrl+S`. Cannot modify merged-PR
branches. Reordering and structural ops (drop/fold/insert/rename) **cannot mix
in the same session** (managing how-to).

| Flag | Description |
| --- | --- |
| `--continue` | After conflict resolution |
| `--abort` | Restore pre-modify snapshot |

**Preconditions:** active stack checked out; clean worktree; no rebase in
progress; no PR queued for merge; linear history (no merge commits / divergence).

| Op | Key | Effect |
| --- | --- | --- |
| Drop | `x` | Remove branch+commits from stack; local branch and PR kept |
| Fold down | `d` | Absorb into branch toward trunk; folded branch leaves stack |
| Fold up | `u` | Absorb into branch toward top |
| Insert below | `i` | Empty branch toward trunk |
| Insert above | `I` | Empty branch toward top |
| Move down/up | `Shift+↓` / `Shift+↑` | Reorder |
| Rename | `r` | Inline rename |
| Undo | `z` | Undo last staged action |

After modify with existing remote stack: `gh stack submit` (old stack replaced).

### `gh stack unstack [<stack-number>]` (= `gh stack delete`)

| Flag | Description |
| --- | --- |
| `--local` | Remove local tracking only; keep GitHub stack |

- No args: active stack (contains current branch).
- Stack number: API unstack from anywhere; drops local tracking if present.
- Merged / merging / queued PRs **cannot** be removed from the GitHub stack.
- If every removable PR is gone, stack dissolves; if some remain stacked, stack
  kept and local tracking unchanged (unless fully cleared).

Useful before large restructure: unstack → `gh stack init` with desired order.

---

## Remote operations

### `gh stack submit [flags]`

Push branches; create/update PRs; create/update stack object.

| Flag | Description |
| --- | --- |
| `--auto` | Skip editor; autogenerated titles |
| `--open` | Ready for review (new + mark existing ready) instead of draft default with `--auto` |
| `--remote <name>` | Push remote |

Interactive editor:

- Left: branches without PRs selected by default; `Ctrl+X` toggles. Deselecting
  a branch deselects dependents above; re-including restores required below.
- Existing PR branches locked (edit on web); `o` opens in browser.
- Right: title, body (template/commits, markdown preview, `$EDITOR`), draft toggle.
- `Ctrl+S` submits; `Ctrl+B` can link already-open PRs into a stack.

### `gh stack sync [flags]`

Single command pipeline:

1. Fetch `origin` (or `--remote`)
2. Reconcile remote stack (auto-append clean remote-ahead PRs; prompt on true divergence)
3. Fast-forward trunk if possible
4. Cascade rebase **only if trunk moved** (on conflict: restore all, advise `gh stack rebase`)
5. Push (`--force-with-lease` if rebased)
6. Sync PR state from GitHub
7. Link open PRs into stack object if ≥2 PRs (never opens new PRs)
8. Interactive prune prompt for merged local branches; `--prune` auto

| Flag | Description |
| --- | --- |
| `--remote <name>` | Remote |
| `--prune` | Delete local branches for merged PRs |

**Divergence choices (interactive):** use remote as source of truth; delete
stack object on GitHub (PRs/branches kept) then recreate via `submit`; or cancel.
Non-interactive: divergence aborts successfully without push/update.

### `gh stack rebase [flags] [branch]`

Fetch, then ensure each layer contains tip of parent, trunk → top. Merged-PR
layers use `--onto` against merge target.

| Flag | Description |
| --- | --- |
| `--downstack` | Trunk → current only |
| `--upstack` | Current → top only |
| `--no-trunk` | No fetch/trunk rebase; only restack layers on each other |
| `--continue` / `--abort` | Conflict control |
| `--remote <name>` | Fetch remote |
| `--committer-date-is-author-date` (`--preserve-dates`) | Preserve author date as committer date |

### `gh stack push [flags]`

Pushes active (non-merged, non-queued) branches in one `git push` with per-branch
`--force-with-lease`. **Not atomic** — some branches may update while another is
rejected. Does not create PRs.

### `gh stack link [flags] <stack-number | branch-or-pr> <branch-or-pr> [...]`

Remote-only stack create/update. No local tracking. For jj/Sapling/git-town.

Args **bottom → top**. Pushes branches; reuses open PRs or creates drafts;
fixes wrong bases; additive stack updates (never removes existing stack members).

First arg as stack number appends to that stack without re-listing members.
Numeric first arg is stack only if it matches an existing stack; else PR/branch.

| Flag | Description |
| --- | --- |
| `--base <branch>` | Trunk for new stack (ignored when appending) |
| `--open` | Ready for review |
| `--remote <name>` | Remote |

```shell
gh stack link feature-auth feature-api feature-ui
gh stack link 10 20 30
gh stack link 7 48 feature-ui
gh stack link --base develop --open feat-a feat-b feat-c
```

### `gh stack merge [<stack-number> | <pr-number>]`

Merges every PR up to and including selection into base — **all-or-nothing**.
Cannot bypass merge requirements.

| Flag | Description |
| --- | --- |
| `--merge-method <method>` | `merge` \| `squash` \| `rebase` |
| `--merge` / `--squash` / `--rebase` | Shorthands |
| `-y, --yes` | No prompt |

Merge queue: stack enqueued; method flags ignored with warning; selected PRs
enter queue together but may land in separate queue groups.

---

## Utilities

### `gh stack alias [flags] [name]`

Default alias name `gs` → `~/.local/bin/`. Windows: prints manual instructions.
`--remove` deletes alias.

### Environment

| Variable | Values | Meaning |
| --- | --- | --- |
| `GH_STACK_THEME` | `auto` (default), `light`, `dark` | TUI + colored output palette |

### Exit codes

| Code | Meaning |
| --- | --- |
| 0 | Success |
| 1 | Generic error |
| 2 | Not in a stack / stack not found |
| 3 | Rebase conflict |
| 4 | GitHub API failure |
| 5 | Invalid arguments/flags |
| 6 | Branch belongs to multiple stacks (disambiguation) |
| 7 | Rebase already in progress |
| 8 | Stack locked by another process |
| 9 | Stacked PRs not enabled for repository |
| 10 | Modify session interrupted; recovery required |
