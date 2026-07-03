---
name: codex-config
description: Use when a user asks to inspect, explain, create, or edit Codex CLI configuration such as ~/.codex/config.toml, .codex/config.toml, requirements.toml, approval_policy, sandbox_mode, sandbox_workspace_write.writable_roots, skills.config, profiles, project trust, or local Codex skills.
---

# Codex Config

Use this skill when working on Codex CLI configuration or local Codex skills.

Read [references/config-reference.md](references/config-reference.md) when you need exact key names, file locations, or example snippets.

## Scope

- User config: `~/.codex/config.toml`
- Project overrides: `.codex/config.toml`
- Admin-enforced constraints: `requirements.toml`
- Local skills: `~/.codex/skills/<skill-name>/`

## Workflow

1. Inspect the active config layers before editing. Prefer minimal changes over rewrites.
2. Treat `~/.codex/config.toml` as machine-local by default. It commonly accumulates trusted-project entries and other stateful paths.
3. If a repo really does manage Codex config with chezmoi, template machine-local paths with `{{ "{{ .chezmoi.homeDir }}" }}` instead of hardcoding the username.
4. For sandbox changes, check `sandbox_mode` and the `sandbox_workspace_write.*` keys together.
5. For trust or project-specific behavior, check `projects."<path>".trust_level` and whether the project has a local `.codex/config.toml`.
6. When adding a local skill, create a folder with `SKILL.md` under `~/.codex/skills/`. Use `[[skills.config]]` only when explicit enable/disable state or a non-default path is useful.
7. If settings appear to have no effect, check whether `requirements.toml` is constraining them.

## Checks

- Preserve unrelated config entries and trusted project entries.
- Keep TOML arrays and tables in their current style.
- Prefer config keys documented in the official Codex config reference over guessed names.
