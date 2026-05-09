# tomdale

Personal Codex plugin content managed by chezmoi.

This source tree maps to `~/.local/share/agents/plugins/tomdale` on the target
machine. Keep plugin metadata in `dot_codex-plugin/plugin.json`, add reusable
skills under `skills/`, put shared helper scripts in `scripts/`, and add local
MCP servers in `.mcp.json` plus companion code under `mcp/`.

## Layout

- `dot_codex-plugin/plugin.json`: Codex plugin manifest
- `.mcp.json`: MCP server configuration (points to shared servers in `~/.local/share/mcp/`)
- `skills/`: personal skills, one directory per skill with a `SKILL.md`
- `scripts/`: shared helper scripts used by multiple skills

## Bundled Skills

- `interactive-shell`: run REPLs and prompt-driven CLIs safely
- `tui-development`: build and verify terminal UIs
- `benchmarking`: measure and improve performance methodically
- `fix-pr-checks`: diagnose and repair failing GitHub PR checks
- `tasks` and `write-task`: manage a portable markdown task queue
- `iterm2-python-api`: write and debug iTerm2 Python scripts
- `exec-summarizer`: compress technical output for executive readers
- `minify-prompt`: rewrite instruction-heavy files for lower token cost without
  losing meaning
- `refactoring`: redesign TypeScript code toward a greenfield-quality module
  layout, with aggressive decomposition of monolithic files
- `ship-pr`: stage, commit, push, and open a GitHub pull request, using the
  `narrative` skill to draft the PR description

## MCP Servers

- `iterm_status`: shared iTerm2 status server (lives in `~/.local/share/mcp/`; used by both Claude and Codex)

## Notes

Codex still expects the local marketplace registry at
`~/.agents/plugins/marketplace.json`, but the plugin payload itself can live in
an XDG-style data directory. The marketplace entry for this plugin points to
`./.local/share/agents/plugins/tomdale`.

## Adding A Skill

Create a new directory under `skills/` and add a `SKILL.md` file:

```text
skills/
  my-skill/
    SKILL.md
```

Keep skill names lowercase and hyphenated so they stay consistent with the
rest of the Codex skill ecosystem.
