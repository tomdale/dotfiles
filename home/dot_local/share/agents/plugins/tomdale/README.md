# tomdale

Personal Codex plugin content managed by chezmoi.

This source tree maps to `~/.local/share/agents/plugins/tomdale` on the target
machine. Keep plugin metadata in `dot_codex-plugin/plugin.json`, add reusable
skills under `skills/`, and put shared helper scripts in `scripts/`.

## Layout

- `dot_codex-plugin/plugin.json`: Codex plugin manifest
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
