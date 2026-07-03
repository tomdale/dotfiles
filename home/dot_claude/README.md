# Claude Code Configuration

This directory contains Claude Code configuration files managed by chezmoi.

## Structure

- `settings.json` - Claude Code settings
- `commands/` - Custom slash commands (markdown files)

## Symlink Setup

These files are symlinked to `~/.claude/` via chezmoi configuration since Claude Code doesn't yet support XDG Base Directory specification.
