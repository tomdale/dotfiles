---
name: omniagent-monorepo-migration
description:
  Migrate local vercel/omniagent repositories, worktrees, and in-flight PR
  branches after Omniagent was imported into the vercel/agents monorepo. Use
  when updating old Omniagent checkouts, rebasing or transplanting old
  Omniagent PR branches onto vercel/agents origin/main, fixing path/config
  drift from the monorepo import, or rewriting verification commands for the
  new apps/omniagent layout.
---

Migrate old `vercel/omniagent` work into the `vercel/agents` monorepo without
losing local changes or reintroducing the old root-level app layout.

## Known Merge Shape

Use these facts as the default structural baseline, then verify them against
the current `origin/main` before changing files:

- `f023a532` imported the old Omniagent repo as `apps/omniagent`.
- `d61ec59b` adapted the import to the agents monorepo.
- `origin/main` currently contains the merge of those commits.
- Old app-root files now live under `apps/omniagent/`.
- Old `sandbox-proxy/` now lives at `apps/omniagent-sandbox-proxy/`.
- Old `patches/` now lives at repo-root `patches/`.
- Old Omniagent workflows now live at repo-root `.github/workflows/` with
  `omniagent-` prefixes, for example `ci.yml` to `omniagent-ci.yml`.
- Old app-local `pnpm-lock.yaml`, `pnpm-workspace.yaml`, `.npmrc`, and
  `.vite-hooks/` were removed. The monorepo root owns package management.
- The monorepo root package is `agents`; the app package is still `omniagent`.

Refresh before relying on the hash details:

```sh
git fetch origin main
git log --oneline -4 origin/main
git show --summary --find-renames d61ec59b
```

## First Pass

Start by locating the repository shape and preserving state:

```sh
git status --short --branch
git remote -v
git worktree list --porcelain
git ls-tree --name-only origin/main
git ls-tree --name-only origin/main:apps
```

If `origin` still points at `vercel/omniagent`, update it to
`https://github.com/vercel/agents.git`, fetch, and re-check status. Never run a
destructive reset. If a worktree has uncommitted changes, either migrate them in
place deliberately or create a named stash/patch backup first.

Identify old-shape worktrees by root-level `src/`, `next.config.ts`,
`drizzle.config.ts`, `sandbox-proxy/`, or root package name `omniagent` without
`apps/omniagent/`. Identify migrated worktrees by root `apps/omniagent/`,
`apps/omniagent-sandbox-proxy/`, root `turbo.json`, and root package name
`agents`.

When creating new migration branches, always use a `tomdale/` prefix.

## Local Config Migration

Ignored local config moved with the app, not with the monorepo root:

- Move or copy old root `.env.local` to `apps/omniagent/.env.local`.
- Move or copy old root `.vercel/` to `apps/omniagent/.vercel/`.
- Move or copy old `sandbox-proxy/.vercel/`, if present, to
  `apps/omniagent-sandbox-proxy/.vercel/`.
- Keep these ignored files out of commits.

After a checkout has the new monorepo shape, install from the monorepo root:

```sh
pnpm install
```

From the monorepo root, run app commands with `--dir`:

```sh
pnpm --dir apps/omniagent dev
pnpm --dir apps/omniagent check
pnpm --dir apps/omniagent test
pnpm --dir apps/omniagent typecheck
pnpm --dir apps/omniagent db:check
pnpm --dir apps/omniagent-sandbox-proxy typecheck
```

When writing PR verification steps, report these project-level commands. Do not
include local shell workarounds such as `proto run` or `proto exec`.

## Branch Migration Strategy

Prefer creating a fresh migrated branch from `origin/main` instead of force
rebasing an old checkout in place:

```sh
old_branch="$(git branch --show-current)"
old_base="$(git merge-base "$old_branch" f023a532^2 2>/dev/null || git merge-base "$old_branch" origin/main 2>/dev/null)"
case "$old_branch" in
  tomdale/*) new_branch="${old_branch}-agents" ;;
  *) new_branch="tomdale/${old_branch}-agents" ;;
esac
git switch -c "$new_branch" origin/main
```

If `old_base` is empty, stop and inspect the branch history manually. Do not
guess a transplant range.

Before applying anything, classify changed paths from the old branch:

```sh
git diff --name-status "$old_base" "$old_branch"
```

Path mapping:

- App files: prefix with `apps/omniagent/`.
- `sandbox-proxy/**`: move to `apps/omniagent-sandbox-proxy/**`.
- `patches/**`: keep as root `patches/**`.
- `.github/actions/**`: keep at root `.github/actions/**`, but check content
  for `apps/omniagent` working-directory or `pnpm --dir apps/omniagent`.
- `.github/workflows/base-image-ensure.yml`: rename to
  `.github/workflows/omniagent-base-image-ensure.yml`.
- `.github/workflows/ci.yml`: rename to
  `.github/workflows/omniagent-ci.yml`.
- `.github/workflows/evals.yml`: rename to
  `.github/workflows/omniagent-evals.yml`.
- `.github/workflows/preview-e2e.yml`: rename to
  `.github/workflows/omniagent-preview-e2e.yml`.
- `.cursor/environment.json`, `.vscode/extensions.json`, `.zed/settings.json`:
  root-level monorepo files; merge manually if changed.
- Old `pnpm-lock.yaml`, `pnpm-workspace.yaml`, `.npmrc`, `.vite-hooks/**`, and
  old app-local `.vscode/settings.json`: do not transplant directly.

## Applying Changes

If the old branch only touched app files, preserve individual commits with:

```sh
git format-patch --stdout "$old_base..$old_branch" | git am --3way --directory=apps/omniagent
```

If the branch touched mixed areas, use a cumulative transplant and make one new
commit. Apply app-root changes first:

```sh
git diff --binary "$old_base" "$old_branch" -- \
  ':(exclude)sandbox-proxy/**' \
  ':(exclude)patches/**' \
  ':(exclude).github/**' \
  ':(exclude)pnpm-lock.yaml' \
  ':(exclude)pnpm-workspace.yaml' \
  ':(exclude).npmrc' \
  ':(exclude).vite-hooks/**' \
  ':(exclude).cursor/**' \
  ':(exclude).vscode/**' \
  ':(exclude).zed/**' \
  | git apply --3way --directory=apps/omniagent
```

Apply sandbox-proxy changes by stripping `sandbox-proxy/` and prefixing the new
sibling app:

```sh
git diff --binary "$old_base" "$old_branch" -- sandbox-proxy \
  | git apply --3way -p2 --directory=apps/omniagent-sandbox-proxy
```

Apply patch-file changes at the monorepo root:

```sh
git diff --binary "$old_base" "$old_branch" -- patches \
  | git apply --3way
```

Handle workflow and editor/config changes manually with the path mapping above;
these files were intentionally reshaped by `d61ec59b`.

After applying patches, inspect and stage only intended files:

```sh
git status --short
git diff --stat
pnpm install --lockfile-only
pnpm --dir apps/omniagent check
pnpm --dir apps/omniagent test
```

If the branch needs a single migration commit, use the old PR title or branch
intent as the subject, following the target repo's conventional commit style.

## PR Migration

For each in-flight PR, inspect both the old branch and the visible GitHub PR
before pushing:

```sh
gh pr view --json number,state,title,url,baseRefName,headRefName,headRepositoryOwner
```

If the existing PR is already in `vercel/agents` and its head branch is safe to
update, ask before force-pushing a rewritten branch. Otherwise push the migrated
branch as a new `tomdale/...` branch and create a new PR against
`vercel/agents:main`.

For PR descriptions, explain that the branch was transplanted from the old
Omniagent root layout to `apps/omniagent` in the agents monorepo only when that
context helps reviewers. Keep verification commands in monorepo form, for
example:

```markdown
Verification:
- pnpm --dir apps/omniagent check
- pnpm --dir apps/omniagent test
```

Do not include local environment setup, `proto` commands, or ignored-file copy
steps in PR verification.

## Completion Checklist

Before handing back a migrated branch:

- `origin` points to `vercel/agents`.
- Branch starts with `tomdale/` when newly created.
- No old root-level app files were reintroduced.
- No old app-local lock/workspace files were reintroduced.
- `sandbox-proxy` changes landed under `apps/omniagent-sandbox-proxy`.
- Local `.env.local` and `.vercel/` are under `apps/omniagent/` if needed.
- Verification commands ran from the monorepo root with `pnpm --dir`, or any
  skipped command is reported with the reason.
