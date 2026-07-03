# Codex Config Reference Notes

Source: https://developers.openai.com/codex/config-reference

This file is a distilled working reference for the keys that usually matter when editing Codex CLI configuration.

## Paths and precedence

- User config lives at `~/.codex/config.toml`.
- Project overrides can live at `.codex/config.toml`.
- Project-scoped config is loaded only for trusted projects.
- `requirements.toml` is admin-enforced and can constrain security-sensitive settings.

## Common keys

- `approval_policy`
  Controls when Codex pauses for approval before executing commands.
- `sandbox_mode`
  Valid values include `read-only`, `workspace-write`, and `danger-full-access`.
- `sandbox_workspace_write.writable_roots`
  Additional writable roots used when `sandbox_mode = "workspace-write"`.
- `sandbox_workspace_write.network_access`
  Enables outbound network access inside the workspace-write sandbox.
- `sandbox_workspace_write.exclude_tmpdir_env_var`
  Excludes `$TMPDIR` from writable roots in workspace-write mode.
- `sandbox_workspace_write.exclude_slash_tmp`
  Excludes `/tmp` from writable roots in workspace-write mode.
- `skills.config`
  Per-skill enablement overrides stored in `config.toml`.
- `skills.config.<index>.path`
  Path to a skill folder containing `SKILL.md`.
- `skills.config.<index>.enabled`
  Enables or disables that skill entry.
- `projects."<path>".trust_level`
  Marks a project as `trusted` or `untrusted`. Untrusted projects skip project-scoped `.codex/` layers.
- `profiles.<name>.*`
  Profile-scoped overrides for supported configuration keys.
- `project_doc_max_bytes`
  Maximum bytes read from `AGENTS.md` when building project instructions.
- `model_instructions_file`
  Replaces the built-in instruction file.
- `developer_instructions`
  Adds extra developer instructions into the session.

## Useful snippets

```toml
[sandbox_workspace_write]
writable_roots = [
  "/Users/tomdale/.cache/workforest/",
]
```

```toml
[[skills.config]]
path = "/Users/tomdale/.codex/skills/codex-config"
enabled = true
```

## Editing guidance

- Use user-level `~/.codex/config.toml` for machine defaults.
- Expect `~/.codex/config.toml` to collect machine-specific state such as trusted project paths. Do not assume it belongs in portable dotfiles.
- Use project `.codex/config.toml` only for repo-specific behavior.
- If the file is managed by chezmoi, prefer `{{ .chezmoi.homeDir }}` in templates for path portability.
- When behavior differs from the file contents, look for `requirements.toml` or trust-level constraints before assuming the key is wrong.
