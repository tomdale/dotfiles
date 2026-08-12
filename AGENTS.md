# Repository instructions

Public chezmoi-managed dotfiles repo; root-level files are not deployed. Terms:
- Repository root: this checkout; `AGENTS.md`, `CLAUDE.md`, `.agents/`, `.agent/` are repo-local, not deployed.
- Managed source: under `home/` (the `.chezmoiroot`); source names encode destinations — `dot_`→`.`, `private_`→permissions, `symlink_`→symlink, `.tmpl`→Go template.
- Deployed destination: the rendered live path under `$HOME` (e.g. `$HOME/.agents/skills`); never edit deployed destinations as the permanent fix.
- `.agent/` (scratch + local plugin material) vs `.agents/skills/` (repo-local skills): both repo-local, neither a chezmoi destination — do not confuse them.
- User-global shared skill: managed `home/dot_agents/skills/<name>/SKILL.md` → deployed `$HOME/.agents/skills/<name>/SKILL.md`.

Before modifying agent/harness config read the `agent-config` skill. Managed source is authoritative; do not fix by editing deployed `$HOME/{.claude,.codex,.pi,.agents}`.

## Branching
Work directly on `master`; no feature branches. The repo deploys live state via `chezmoi apply`, so only one file version can be active — branches cannot coexist; keep a single linear history. In a sandboxed harness run `chezmoi apply` (and `chezmoi apply...`) commands unsandboxed. If unsure how an agent CLI behaves, consult checked-out Codex/Pi source under `$HOME/Code/` when present.

## Safety and secrets
Public repo — never commit/stage/push secrets or anything potentially compromising. Treat private keys, tokens, credentials, machine/account IDs, signing keys, personal access tokens, session material, local-only hostnames, and unexplained high-entropy values as sensitive until proven otherwise. Scan every diff before commit/PR/push. If sensitive material appears in tracked source, stop and warn the user; do not continue/commit/push until it is removed or replaced with a documented local-only mechanism.

## Agent plugins
Editing a user-global local plugin: edit managed source under `home/`, bump the plugin manifest version, run `chezmoi apply` for the deployed destination, and restart the harness so the next session loads it. Codex installs local plugins under `$HOME/.codex/plugins/cache/<marketplace>/<plugin>/<version>/`; the version bump tells CLIs to install the new entry. If a change isn't picked up after apply+restart, bust the cache, e.g. `rm -rf "$HOME/.codex/plugins/cache/tomdale-codex-plugins/tomdale/local"`. Never edit files under `$HOME/.codex/plugins/cache` — treat as Codex-generated state.

## Repository layout and chezmoi
For full chezmoi operations (templates, scripts, source↔destination mapping, verification, apply/conflict handling) read the repo-local `chezmoi` skill (`.agents/skills/chezmoi/`). Essential basics below.
`.agent/inspo/` holds example dotfiles + a README; consult it before adding new patterns.
Managed locations: `home/.chezmoitemplates/` (templates), `home/.chezmoiscripts/` (ordered setup/sync/link scripts), `home/dot_claude/`→`.claude`, `home/dot_codex/`→`.codex`, `home/dot_pi/agent/`→`.pi/agent`, `home/dot_agents/skills/`→`.agents/skills`, `home/private_dot_gitconfig.tmpl` (work/personal email switch).

Use destination paths with chezmoi, not source attributes: `chezmoi apply "$HOME/.claude/agents/foo"`, not paths containing `exact_`. Prefer plain files over templates unless values truly vary by machine, require compile-time conditionals, runtime detection is impossible, or secrets need templating; keep dynamic sections small and documented. Support macOS and Linux; prefer runtime detection and portable commands; package installs use Homebrew on macOS.

Preview with `chezmoi diff`; apply managed files with `chezmoi apply <dest>`; use a full `chezmoi apply` for scripts/links/multiple files. On an unrelated apply conflict, stop and diagnose — don't bypass.
Inspect: `chezmoi diff`, `chezmoi cat "$HOME/.config/file"`, `chezmoi data`, `chezmoi execute-template '{{ .isWork }}'`.
Custom template variable `.isWork` controls work/personal Git email and may gate work-specific config; built-ins `.chezmoi.os`, `.chezmoi.hostname`, `.chezmoi.homeDir`.
`home/dot_config/Brewfile.tmpl` is macOS-only; external files are declared in `home/.chezmoiexternal.toml`.

## General workflow
Comments explain why, not what; put change history in commit message/PR description. Use `./.agent/` for scratch files when available, else OS temp; don't leave generated files in the workspace. The shell is non-interactive — use the `interactive-shell` skill + a PTY (tmux) for REPLs, prompts, TUIs, and progress displays.

## Shared configuration boundaries
Shared rules (all harnesses): `home/.chezmoitemplates/AGENTS.shared.md`. Harness-specific rules live in the target harness config (`home/dot_claude/`, `home/dot_codex/`, `home/dot_pi/agent/`); no per-harness AGENTS template exists. Don't duplicate shared skills under harness-specific skill directories. Claude/Codex plugins live in their separate marketplaces, not vendored here; this repo deploys configuration, not plugin/marketplace manifests.
