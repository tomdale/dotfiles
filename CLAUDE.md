# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with
code in this repository.

## Overview

Chezmoi-managed dotfiles repository. The `.chezmoiroot` is set to `home/`, so
all managed files are under the `home/` directory. Files at the repository root
(like this CLAUDE.md) are not deployed to `~`.

For comprehensive chezmoi documentation, use the `chezmoi` skill which provides
detailed reference on templating, file naming conventions, scripts, external
files, and secrets management.

## Inspiration

`.agent/inspo/` contains example chezmoi dotfiles and a README that summarizes
common patterns, techniques, and best practices. You should explore these to:

- Find inspiration for configuration patterns and approaches
- See how others structure similar setups
- Reference working examples before implementing features

## Chezmoi Template Drawbacks

**Templates break the `chezmoi add` workflow.** When a file uses `.tmpl`, you
can no longer easily reflect local edits back to source using `chezmoi add`.

**All else equal, default to plain files.** Only use templates when truly
necessary. Ask: "Does this file actually need to vary by machine, or can it
handle differences at runtime?"

### Alternatives to Templates

| Instead of...                        | Consider...                             |
| ------------------------------------ | --------------------------------------- |
| Template conditionals for OS         | Runtime detection in the file itself    |
| Template for optional config blocks  | Conditional sourcing/loading at runtime |
| Template to include/exclude sections | Separate files with runtime `source`    |
| Template for paths that vary         | Environment variables set elsewhere     |

### Runtime Detection (Preferred for Shell Config)

Shell scripts can detect the OS at runtime instead of compile-time:

```bash
# Runtime detection—no template needed
if [[ "$OSTYPE" == darwin* ]]; then
  export HOMEBREW_PREFIX="/opt/homebrew"
elif [[ "$OSTYPE" == linux* ]]; then
  export HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
fi
```

```bash
# Conditional sourcing—file exists check
[[ -f ~/.config/zsh/work.zsh ]] && source ~/.config/zsh/work.zsh
```

### When Templates ARE Appropriate

- **Config formats that don't support conditionals** (JSON, TOML, YAML without
  anchors)
- **Values that genuinely differ per-machine** (email addresses, hostnames)
- **Files where runtime detection is impossible** (git config, static config
  files)
- **Secrets** (use `secretJSON`, `bitwarden`, etc.)

### Keeping Templates Minimal

When you must use a template:

1. **Isolate dynamic parts.** Put the templated value in one small file,
   source/include it from the main config
2. **Use `.chezmoiignore`** to skip OS-specific files entirely rather than
   templating them
3. **Document why** the template is necessary in a comment

### OS-Specific File Patterns

For files that are entirely different per-OS, use `.chezmoiignore`:

```
# .chezmoiignore
{{- if ne .chezmoi.os "darwin" }}
dot_config/Brewfile
{{- end }}
{{- if ne .chezmoi.os "linux" }}
dot_config/apt-packages.txt
{{- end }}
```

This keeps the actual config files template-free while controlling which files
deploy where.

## Cross-Platform Support (MANDATORY)

**All changes MUST support both Linux and macOS environments where relevant.**

Prefer runtime detection over templates when possible (see above). When runtime
detection isn't feasible, use chezmoi templating:

```go
{{- if eq .chezmoi.os "darwin" }}
# macOS-specific config
{{- else if eq .chezmoi.os "linux" }}
# Linux-specific config
{{- end }}
```

### Common Patterns

**Package managers:**

- macOS → Homebrew (`brew install`)
- Linux → apt/dnf/pacman (detect distro via `.chezmoi.osRelease`)

**Paths:**

- Use `~/.config` (XDG Base Directory) over `~/Library/Application Support`
- macOS system paths: `/usr/local`, `/opt/homebrew` (Apple Silicon)
- Linux system paths: `/usr`, `/usr/local`, `/opt`

**Commands:**

- Test availability: `command -v tool` or `type tool`
- Prefer POSIX-compatible commands in scripts
- Use `[[` over `[` for bash conditionals (supported on both)

**Example OS-conditional file:**

```bash
{{- if eq .chezmoi.os "darwin" }}
# Install with Homebrew
brew install tool
{{- else if eq .chezmoi.os "linux" }}
# Install with apt
apt-get install -y tool
{{- end }}
```

**Example tool detection:**

```bash
if command -v tool >/dev/null 2>&1; then
  # Tool is available on this system
  tool --setup
fi
```

When in doubt, make behavior conditional and test on both platforms.

## Key Commands

```bash
chezmoi diff                    # Preview changes before applying
chezmoi apply ~/.config/file    # Apply specific file
chezmoi apply -n -v             # Dry run with verbose output
chezmoi cat ~/.bashrc           # View rendered template output
chezmoi data                    # View all template variables
```

**Always run `chezmoi apply` after making changes, scoped to affected files.**

## Repository Structure

```
home/
├── .chezmoi.toml.tmpl          # Config template (prompts for .isWork)
├── .chezmoiexternal.toml       # External git repos/files to fetch
├── .chezmoiscripts/            # Setup scripts (numbered execution order)
│   ├── run_onchange_after_1-setup-zsh-directories.sh
│   ├── run_onchange_after_2-install-oh-my-zsh.sh
│   └── run_onchange_after_3-install-homebrew.sh
├── dot_config/
│   ├── Brewfile.tmpl           # Homebrew dependencies (macOS only)
│   ├── claude/                 # Claude Code config (skills, commands, agents)
│   └── zsh/                    # Shell configuration
├── dot_claude/                 # Symlinks to dot_config/claude for ~/.claude
└── dot_gitconfig.tmpl          # Git config with work/personal email switching
```

## Zsh Startup Files

Zsh sources files in a specific order. Understanding this helps decide where
config belongs.

### Startup Order

| File        | When Sourced                             | Use For                                          |
| ----------- | ---------------------------------------- | ------------------------------------------------ |
| `.zshenv`   | **Always** (login, interactive, scripts) | Environment variables, PATH                      |
| `.zprofile` | Login shells only                        | Login-specific setup (rare)                      |
| `.zshrc`    | Interactive shells                       | Aliases, functions, prompt, completions, plugins |
| `.zlogin`   | Login shells, after .zshrc               | Rarely used                                      |

### Decision Guide

**Put in `.zshenv`** (or sourced from it):

- `export` statements for environment variables (`XDG_*`, `EDITOR`, `LANG`)
- PATH modifications
- Tool home directories (`CARGO_HOME`, `PNPM_HOME`)
- Anything needed by non-interactive scripts

**Put in `.zshrc`**:

- Oh-my-zsh configuration and plugins
- Aliases and functions
- Prompt/theme configuration
- Completion settings
- Tool hooks that only matter interactively (`direnv`, `fnm`)

**Put in `.zprofile`** (rarely needed):

- `typeset -U path` (dedupe PATH, login optimization)
- Commands that should only run once per login session

### This Repo's Structure

```
~/.zshenv               → Sets ZDOTDIR, sources env.zsh
~/.config/zsh/
├── env.zsh             → Environment variables & PATH (sourced from .zshenv)
├── .zprofile           → Minimal (typeset -U path)
├── .zshrc              → Main interactive config (oh-my-zsh, plugins, tools)
├── iterm2_user_vars.zsh → iTerm2 status bar variables
├── functions/          → Modular functions and aliases
│   ├── aliases.zsh     → Shell aliases (tt, reload, cat)
│   ├── core.zsh        → Utilities (killport, slink, find-closest)
│   ├── git.zsh         → Git helpers (clone, gitignore)
│   └── claude.zsh      → Claude/agent functions (claude, tasks)
└── custom/themes/      → Oh-my-zsh custom themes
    └── tomdale.zsh-theme → Fork of agnoster for customization
```

The key insight: `.zprofile` only runs for login shells, but modern terminals
often start non-login interactive shells. Put environment setup in `.zshenv` to
ensure it runs everywhere.

## Template Variables

The primary custom variable is `.isWork` (boolean), prompted during
`chezmoi init`:

- Determines email in git config (work vs personal)
- Can be used to conditionally include work-specific config

Access chezmoi builtins: `.chezmoi.os`, `.chezmoi.hostname`, `.chezmoi.homeDir`

## Patterns in This Repo

### File Naming (chezmoi conventions)

**Important:** These prefixes are chezmoi _source state_ attributes—they control
how chezmoi processes files, not the literal target path. When referencing
target files (with `chezmoi apply`, `chezmoi cat`, etc.), use the actual
destination path.

| Source Name            | Target Path              | Attribute Meaning                         |
| ---------------------- | ------------------------ | ----------------------------------------- |
| `dot_zshrc`            | `~/.zshrc`               | `dot_` → adds leading `.`                 |
| `exact_plugins/`       | `~/.config/.../plugins/` | `exact_` → removes unmanaged files in dir |
| `executable_script.sh` | `~/script.sh`            | `executable_` → sets +x permission        |
| `private_secret.txt`   | `~/secret.txt`           | `private_` → sets 0600 permissions        |
| `symlink_foo`          | `~/foo` → (symlink)      | `symlink_` → creates symlink              |
| `foo.tmpl`             | `~/foo`                  | `.tmpl` → process as Go template          |

Prefixes can combine: `private_dot_ssh/` → `~/.ssh/` with 0700 permissions.

**Never use these prefixes in target paths:**

```bash
# Wrong - these are source attributes, not path components
chezmoi apply ~/.config/claude/exact_plugins/foo

# Correct - use the actual target path
chezmoi apply ~/.config/claude/plugins/foo
```

### Claude Code Configuration

`home/dot_claude/` contains symlinks pointing to `home/dot_config/claude/`:

- `symlink_CLAUDE.md` → `../.config/claude/CLAUDE.md`
- `symlink_skills` → `../.config/claude/exact_skills`
- etc.

This allows managing Claude Code config in `~/.config/claude/` while chezmoi
deploys symlinks to `~/.claude/`.

### Plugin Versioning (MANDATORY)

**After modifying any Claude plugin component (commands, skills, agents, hooks,
scripts), you MUST bump the version in the plugin's `plugin.json`.**

This is required for Claude to pick up changes. Version bumps follow semver:

| Change Type              | Version Bump  | Examples                                                   |
| ------------------------ | ------------- | ---------------------------------------------------------- |
| Small tweaks             | Patch (0.0.X) | Typo fixes, minor wording changes, small bug fixes         |
| Significant improvements | Minor (0.X.0) | New commands/skills, improved functionality, refactors     |
| Major overhauls          | Major (X.0.0) | Breaking changes, complete rewrites, architectural changes |

```bash
# Example: After updating a command in the tasks plugin
# Edit home/dot_config/claude/exact_plugins/tasks/dot_claude-plugin/plugin.json
# Change: "version": "1.0.0" → "version": "1.1.0"
```

### Plugin Marketplace (MANDATORY)

**When creating a new plugin, you MUST add it to the marketplace registry.**

Edit `home/dot_config/claude/exact_plugins/dot_claude-plugin/marketplace.json`
and add an entry:

```json
{
  "name": "plugin-name",
  "source": "./plugin-name",
  "description": "Brief description of what the plugin does"
}
```

This allows Claude Code to discover and load plugins from the shared plugins
directory.

### Homebrew Dependencies

`home/dot_config/Brewfile.tmpl` is macOS-only (wrapped in
`{{ if eq .chezmoi.os "darwin" }}`). The script
`run_onchange_after_3-install-homebrew.sh` re-runs `brew bundle` when Brewfile
changes.

### External Files

`home/.chezmoiexternal.toml` fetches files from URLs:

- Glow solarized theme from GitHub

## Testing Templates

```bash
chezmoi execute-template '{{ .isWork }}'
chezmoi execute-template < home/dot_gitconfig.tmpl
```

## When to Run `chezmoi apply`

**Only files inside `home/` are managed by chezmoi.** Files at the repo root
(like this CLAUDE.md, .gitignore, etc.) are not deployed—editing them takes
effect immediately with no `chezmoi apply` needed.

After making changes to files in `home/`, run `chezmoi apply` scoped to affected
files:

```bash
chezmoi apply ~/.config/claude/settings.json
chezmoi apply ~/.zshrc
```

Use `chezmoi diff` first to preview what will change. If there are conflicts,
stop and alert the user.
