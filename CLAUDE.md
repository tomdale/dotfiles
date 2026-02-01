# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Chezmoi-managed dotfiles repository. The `.chezmoiroot` is set to `home/`, so all managed files are under the `home/` directory. Files at the repository root (like this CLAUDE.md) are not deployed to `~`.

For comprehensive chezmoi documentation, use the `chezmoi` skill which provides detailed reference on templating, file naming conventions, scripts, external files, and secrets management.

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

Zsh sources files in a specific order. Understanding this helps decide where config belongs.

### Startup Order

| File | When Sourced | Use For |
|------|--------------|---------|
| `.zshenv` | **Always** (login, interactive, scripts) | Environment variables, PATH |
| `.zprofile` | Login shells only | Login-specific setup (rare) |
| `.zshrc` | Interactive shells | Aliases, functions, prompt, completions, plugins |
| `.zlogin` | Login shells, after .zshrc | Rarely used |

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

The key insight: `.zprofile` only runs for login shells, but modern terminals often start non-login interactive shells. Put environment setup in `.zshenv` to ensure it runs everywhere.

## Template Variables

The primary custom variable is `.isWork` (boolean), prompted during `chezmoi init`:
- Determines email in git config (work vs personal)
- Can be used to conditionally include work-specific config

Access chezmoi builtins: `.chezmoi.os`, `.chezmoi.hostname`, `.chezmoi.homeDir`

## Patterns in This Repo

### File Naming (chezmoi conventions)
- `dot_` prefix → leading dot in target (e.g., `dot_zshrc` → `.zshrc`)
- `.tmpl` suffix → Go template processing
- `run_onchange_after_N-` → script runs after file changes, numbered order
- `symlink_` prefix → creates symlink to specified target
- `exact_` prefix → removes unmanaged files in directory

### Claude Code Configuration
`home/dot_claude/` contains symlinks pointing to `home/dot_config/claude/`:
- `symlink_CLAUDE.md` → `../.config/claude/CLAUDE.md`
- `symlink_skills` → `../.config/claude/exact_skills`
- etc.

This allows managing Claude Code config in `~/.config/claude/` while chezmoi deploys symlinks to `~/.claude/`.

### Plugin Versioning (MANDATORY)

**After modifying any Claude plugin component (commands, skills, agents, hooks, scripts), you MUST bump the version in the plugin's `plugin.json`.**

This is required for Claude to pick up changes. Version bumps follow semver:

| Change Type | Version Bump | Examples |
|-------------|--------------|----------|
| Small tweaks | Patch (0.0.X) | Typo fixes, minor wording changes, small bug fixes |
| Significant improvements | Minor (0.X.0) | New commands/skills, improved functionality, refactors |
| Major overhauls | Major (X.0.0) | Breaking changes, complete rewrites, architectural changes |

```bash
# Example: After updating a command in the tasks plugin
# Edit home/dot_config/claude/exact_plugins/tasks/dot_claude-plugin/plugin.json
# Change: "version": "1.0.0" → "version": "1.1.0"
```

### Plugin Marketplace (MANDATORY)

**When creating a new plugin, you MUST add it to the marketplace registry.**

Edit `home/dot_config/claude/exact_plugins/dot_claude-plugin/marketplace.json` and add an entry:

```json
{
  "name": "plugin-name",
  "source": "./plugin-name",
  "description": "Brief description of what the plugin does"
}
```

This allows Claude Code to discover and load plugins from the shared plugins directory.

### Homebrew Dependencies
`home/dot_config/Brewfile.tmpl` is macOS-only (wrapped in `{{ if eq .chezmoi.os "darwin" }}`).
The script `run_onchange_after_3-install-homebrew.sh` re-runs `brew bundle` when Brewfile changes.

### External Files
`home/.chezmoiexternal.toml` fetches files from URLs:
- Glow solarized theme from GitHub

## Testing Templates

```bash
chezmoi execute-template '{{ .isWork }}'
chezmoi execute-template < home/dot_gitconfig.tmpl
```

## Always `chezmoi apply`

After making changes, always run `chezmoi apply` scoped to affected files:
```bash
chezmoi apply ~/.config/claude/settings.json
```

If there are conflicts, stop and alert the user.
