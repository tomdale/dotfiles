---
name: chezmoi
description: >
  Manage and operate this machine's chezmoi dotfiles. Use when adding or
  editing managed files under `home/`, running chezmoi apply/diff, working with
  templates or scripts, mapping source files to destinations, or diagnosing
  apply/render state. Covers the mechanics of how chezmoi works here; use the
  agent-config skill to decide which agent-config target to change.
---

# Chezmoi dotfiles operations

This machine manages dotfiles with chezmoi. The source repo is
`~/.local/share/chezmoi`; `.chezmoiroot` is `home/`, so all managed source lives
under `home/`. Always operate on destination paths, never on source attributes.

## Reference: paths and naming

- Managed source lives under `home/`; only files there are deployed.
- Source names encode the destination: `dot_X` → `.X`, `private_X` → private
  perms (0600), `symlink_X` → symlink, `.tmpl` suffix → Go template.
- `home/.chezmoitemplates/` — shared Go templates rendered into other files.
- `home/.chezmoiscripts/` — ordered setup/sync/link scripts run on apply.
- `home/.chezmoiexternal.toml` — external files pulled from other repos.
- Custom template vars used here: `.isWork` (work/personal email switch) and
  built-ins `.chezmoi.os`, `.chezmoi.hostname`, `.chezmoi.homeDir`.
- Ask for the source of a destination: `chezmoi source-path DEST`.
- List managed files: `chezmoi managed [PATH]`.

## Reference: type guidance

Prefer plain files over templates unless values truly vary by machine, need
compile-time conditionals, runtime detection is impossible, or secrets require
templating. Keep dynamic template sections small and document why. Changes
should support macOS and Linux; prefer runtime detection and portable commands;
use chezmoi conditionals only when runtime detection is not feasible. macOS
package installs use Homebrew.

## Workflow: preview before applying

- `chezmoi diff` — preview pending source→destination changes.
- `chezmoi cat DEST` — render a destination as it would be applied.
- `chezmoi data` — show template data (`.isWork`, `chezmoi.*`, etc.).
- `chezmoi execute-template '{{ .isWork }}'` — evaluate a template expression.
Use `chezmoi cat`/`execute-template` to confirm a `.tmpl` renders the intended
content before applying. If chezmoi reports inconsistent state because both a
plain file and a `.tmpl` source exist, remove the obsolete plain file from the
repo after confirming the template renders correctly, then re-apply.

## Workflow: apply

- One target: `chezmoi apply DEST`.
- Several related files / scripts / links / skill installs: full `chezmoi apply`.
- Dry run first: `chezmoi apply -n`.
A targeted apply may not run unrelated `run_after_` scripts, so prefer a full
`chezmoi apply` when changing scripts, symlinks, skill installation, or any
generated configuration. If apply reports an unrelated conflict or prompts for
confirmation, stop and diagnose it rather than bypassing it blindly.

## Workflow: scripts

Scripts under `home/.chezmoiscripts/` may install dependencies, sync repos,
create directories, or create links. Read a script before running it. Preserve
idempotence, avoid destructive operations, and make missing optional
dependencies non-fatal. When a script creates a link, do not overwrite an
existing non-link path — report the conflict and leave existing data untouched.
After changing a managed link or script, apply and verify the final target with
`ls -ld` and `readlink`.

## Workflow: verify after applying

Confirm both the rendered destination and the source mapping:

- `chezmoi source-path DEST`
- `chezmoi managed PATH`
- `ls -ld` / `readlink` on symlinked targets

## Rules: safety and git

Never edit deployed destinations under `~/.claude`, `~/.codex`, `~/.pi`,
`~/.agents`, etc. as the permanent fix; edit managed source under `home/`, then
apply. Never fix by editing generated files; the source is authoritative. Treat
`~/.codex/plugins/cache` and similar as tool-generated state, not source. Do not
commit secrets (private keys, tokens, credentials, machine/account IDs, PATs,
session material, high-entropy values): inspect `git diff --check` and
`git diff` before committing, and keep unrelated user changes intact — no broad
resets or `git add -A`.
