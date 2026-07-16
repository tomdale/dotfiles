# Repository instructions

This is a public chezmoi-managed dotfiles repository. The `.chezmoiroot` is
`home/`, so managed files live under `home/`; root-level documentation and
configuration are not deployed to `~`.

Before modifying agent or harness configuration, read the shared `agent-config`
skill. The source repository is authoritative; do not make permanent fixes by
editing generated files under `~/.claude`, `~/.codex`, `~/.pi`, or `~/.agents`.

## Branching and commits

Do all work directly on the default branch (`master`). Do not create feature
branches for changes in this repository. Commit directly to `master`; do not use
a commit workflow that requires a feature branch.

This repository deploys straight to live machine state via `chezmoi apply`, so
only one version of the tracked files can ever be active at a time. Branches
model parallel variants that cannot coexist once applied; here they add friction
and divergence with no payoff. Keep a single linear history on `master`.

When an agent is running in a sandboxed harness, it should always run
`chezmoi apply` and related `chezmoi apply...` commands unsandboxed.

If an agent needs to clarify ambiguous behavior in how an agent CLI operates, it
may consult the checked-out source repositories for Codex at `~/Code/codex` and
Pi at `~/Code/pi`. Claude Code is not open source, so no corresponding local
source reference is available.

## Safety and secrets

This is a public repository. Do not commit, stage, or push secrets or anything
potentially compromising. Treat private keys, tokens, credentials, machine IDs,
account IDs, signing keys, personal access tokens, session material, local-only
hostnames, and unexplained high-entropy values as sensitive until proven
otherwise. Before any commit, PR, push, or patch that adds configuration values,
scan the diff for sensitive material. If sensitive or potentially compromising
material appears in tracked source, stop all work immediately and warn the user;
do not continue, stage, commit, or push until it has been removed from tracked
files or replaced with a documented local-only mechanism.

## Agent plugins

When modifying a local agent plugin managed by this repository, update the
plugin source under `home/`, bump the plugin manifest version after edits are
done so CLIs pick up the changed plugin, run `chezmoi apply` for the affected
plugin path, and restart the affected harness so the next session loads the
applied plugin.

Local plugins are installed into the Codex cache under
`~/.codex/plugins/cache/<marketplace-name>/<plugin-name>/<version>/`; the
manifest version tells Codex and related CLIs that a new plugin cache entry
should be installed.

If a local plugin change is not picked up after applying and restarting Codex,
bust the installed cache for that plugin. For example, after changing the
`tomdale` plugin:

```sh
rm -rf ~/.codex/plugins/cache/tomdale-codex-plugins/tomdale/local
```

Do not edit files directly in `~/.codex/plugins/cache`; treat that directory as
Codex-managed generated state.

## Repository layout and chezmoi

`.agent/inspo/` contains example chezmoi dotfiles and a README summarizing
common patterns and techniques. Explore relevant examples before implementing
new configuration patterns.

Important source locations include:

- `home/.chezmoitemplates/` — shared templates used to render agent config.
- `home/.chezmoiscripts/` — ordered setup, synchronization, and linking scripts.
- `home/dot_claude/` — Claude Code configuration deployed to `~/.claude`.
- `home/dot_codex/` — Codex configuration deployed to `~/.codex`.
- `home/dot_pi/agent/` — Pi configuration deployed to `~/.pi/agent`.
- `home/dot_agents/skills/` — shared skills deployed to `~/.agents/skills`.
- `home/private_dot_gitconfig.tmpl` — private Git configuration with
  work/personal email switching.

Use actual destination paths with `chezmoi` commands, not source attributes:
`dot_` becomes `.`, `private_` controls permissions, `symlink_` creates a
symlink, and `.tmpl` marks a Go template. For example, use
`chezmoi apply ~/.claude/agents/foo`, not a path containing `exact_`.

Detailed chezmoi procedures belong in the chezmoi documentation or the harness's
chezmoi skill. Prefer plain files over templates unless values truly vary by
machine, the format requires compile-time conditionals, runtime detection is
impossible, or secrets require templating. When templates are necessary, keep
dynamic sections small and document why.

Changes should support macOS and Linux where relevant. Prefer runtime detection
and portable commands; use chezmoi conditionals only when runtime detection is
not feasible. macOS package installation uses Homebrew; Linux installation
should account for the relevant distribution.

Use `chezmoi diff` to preview changes. For managed changes, apply affected files
with `chezmoi apply <destination>`. Use a full `chezmoi apply` when changing
scripts, links, or several related managed files. If apply reports an unrelated
conflict, stop and diagnose it rather than bypassing it.

Common inspection commands:

```bash
chezmoi diff
chezmoi cat ~/.config/file
chezmoi data
chezmoi execute-template '{{ .isWork }}'
```

The primary custom template variable is `.isWork`, which controls the work or
personal Git email and may be used for work-specific configuration. Built-ins
include `.chezmoi.os`, `.chezmoi.hostname`, and `.chezmoi.homeDir`.

`home/dot_config/Brewfile.tmpl` is macOS-only, and external files are declared
in `home/.chezmoiexternal.toml`.

## Shared configuration boundaries

Rules that apply to Claude Code, Codex, and Pi belong in
`home/.chezmoitemplates/AGENTS.shared.md`. Harness-specific rules belong in the
corresponding source template. Shared skills belong in
`home/dot_agents/skills/<skill-name>/SKILL.md`; do not duplicate them under
harness-specific skill directories.

Claude and Codex plugins are maintained in their separate marketplaces rather
than vendored in this repository. This repository deploys configuration, not
plugin authoring or marketplace manifests.
