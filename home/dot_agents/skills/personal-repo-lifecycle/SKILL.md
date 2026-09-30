---
name: personal-repo-lifecycle
description: >
  Required workflow for changing Tom's personal repositories — toolbelt (BB
  plugins, Pi packages and extensions, loaders), skills, dotfiles (chezmoi),
  and other github.com/tomdale checkouts — from first edit through live
  install, push, and cleanup. Read before editing any of them, and before
  installing, reloading, or applying anything they deploy.
---

# Personal repo lifecycle

Each repository has one canonical checkout, and it is live: the daily BB app
loads toolbelt plugins from it, Pi loads packages and extensions from it, and
chezmoi deploys from its source. Every change therefore follows the six steps
below in order. When a step fails, stop there, keep the work where it is, and
report the step, the failure, and the task path.

Canonical checkouts (branch):

- toolbelt `~/Code/Repos/toolbelt/main` (main): BB plugins `bb-plugin-*`,
  `claude-plugin-loader/`, small utilities. Its `AGENTS.md` covers the
  untracked `pi-extensions/` tree, which this workflow can't reach.
- skills `~/Code/Repos/skills/main` (main).
- dotfiles `~/.local/share/chezmoi` (master), deployed only by `chezmoi apply`.
- Other checkouts under `~/Code/Repos` whose origin is
  `github.com/tomdale/*`: same steps on their default branch.

toolbelt and dotfiles are public on GitHub. Scan every diff for secrets and
private material (tokens, credentials, thread transcripts or snapshots,
employer-internal details) before any push, including archive pushes.

## 1. Isolate

Work only in a task worktree you created. Workforest repos (toolbelt, skills,
most of `~/Code/Repos`): `cd <canonical> && wf task new <slug> --json`, then
`git -C <task> branch -m tomdale/<slug>`. dotfiles:
`git -C ~/.local/share/chezmoi worktree add ~/Code/Repos/dotfiles/<slug> -b tomdale/<slug> master`.

Uncommitted changes in a canonical checkout belong to someone else and are
live; leave them in place and mention them in your report. `wf task new
--force` starts the task from HEAD despite them.

## 2. Verify in the task

For a change inside a package, run that package's declared scripts from its
directory: install from the committed lockfile (`npm ci`, or
`pnpm install --frozen-lockfile` where a pnpm lock is committed), then
whichever of typecheck, test, and build it defines. `~/.npmrc` sets
`min-release-age=2`; when the committed lockfile pins newer packages, use
`NPM_CONFIG_MIN_RELEASE_AGE=0 npm ci` for that one install and leave
`~/.npmrc` unchanged.

BB plugins: after building, run
`~/Code/Repos/toolbelt/main/scripts/bb-plugin-smoke <task>/bb-plugin-<name>`.
It installs the plugin into a throwaway BB server with its own data directory
and ports, checks that it activates, and removes the server. The daily BB app
loads only canonical paths, so `bb plugin install`, `bb plugin dev`, and
`bb plugin reload` are used only in step 4, never with a task path.

dotfiles: `chezmoi --source <task> diff <destination>` previews what the
change would deploy. Agent instruction files: complete the review the
`write-agents-md` skill requires.

## 3. Integrate

Commit in the task, rebase onto the canonical branch, resolve conflicts, and
rerun step 2's checks. Then, from the canonical checkout,
`git merge --ff-only tomdale/<slug>`. If another change landed first, rebase
and verify again. The fast-forward refuses to overwrite someone else's
uncommitted file; stop and report when it does.

## 4. Deploy from the canonical checkout

Rebuild the changed package in the canonical checkout and rerun its checks
there.

- BB: `bb plugin reload <id>` (first install:
  `bb plugin install <canonical>/bb-plugin-<name> --yes`). Confirm
  `bb plugin list` shows the plugin `running` from `path:<canonical>/...`, then
  exercise the change in the app when it has UI.
- Pi: start a new session or run `/reload`.
- dotfiles: `chezmoi diff <destination>`, then `chezmoi apply <destination>`
  for each destination you changed. Script and link changes need a full
  `chezmoi apply`, which also deploys any unrelated source/live drift; run a
  full `chezmoi diff` first and ask Tom when it shows changes you didn't make.

## 5. Push

`git push origin <branch>` from the canonical checkout, then confirm that
`git rev-parse <branch> origin/<branch>` prints the same commit twice.

## 6. Clean up

Remove your task after its branch is contained in the pushed branch and its
worktree has no uncommitted files. Check both yourself, then run
`wf task delete <slug> --force --json` (non-interactive shells require
`--force`, which skips Workforest's own checks) or, for dotfiles,
`git -C ~/.local/share/chezmoi worktree remove ~/Code/Repos/dotfiles/<slug>`
and `git -C ~/.local/share/chezmoi branch -d tomdale/<slug>`.

BB deletes a BB-managed thread worktree when its threads are archived, so
archive a thread only when its worktree has no unmerged or uncommitted work.

## Stopping before the end

To set work aside, commit it on the task branch and leave the task in place,
reporting its path. Before removing a worktree, branch, or stash whose commits
are not on origin, push it as `archive/<slug>` after the secret scan; keep
material that must stay private local instead.
