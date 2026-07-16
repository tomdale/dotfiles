# Claude Code instructions

Follow the repository-wide instructions in `AGENTS.md`.

This file is intentionally short. Claude Code-specific behavior is configured
in the global Claude template at
`home/dot_claude/CLAUDE.md.tmpl`; detailed chezmoi procedures are documented in
the Claude `chezmoi` skill.

## Claude Code-specific rules

Comments should explain why, not what. Never reference how code changed from a
previous version. Ask: "will this make sense in a year to someone who never
saw the old code?" If not, put it in a commit message or PR description, not
code.

Sandbox: write scratch/temp files to `./.agent/` (gitignored). Writes to
`/tmp` outside of `/tmp/claude/` will fail. On sandbox failure, first decide
whether the blocked operation is relevant to the current project. Goal: all
normal development operations for a project succeed within the sandbox by
fixing the config, not by repeatedly breaking out of it.

For in-scope operations targeting the current workspace or its normal
resources, stop on sandbox denial. Never retry with
`dangerouslyDisableSandbox`. Identify the blocked resource, suggest a
permission for `.claude/settings.json`, and wait for the user. Permission
patterns include `Edit(/path/*_)`, `WebFetch(domain:host.com)`, and
`Bash(cmd-prefix:_)`.

For explicitly requested out-of-scope operations targeting another project or
location, do not suggest edits to the current project's `.claude/settings.json`.
Retry with `dangerouslyDisableSandbox` so the user can approve elevated access
for that invocation.

Only suggest `dangerouslyDisableSandbox` for in-scope work when permissions
truly cannot solve the problem, such as dynamic paths or system-wide operations.

The Bash tool is non-interactive. For REPLs, interactive prompts, TUIs, and
progress-displaying programs, use the `interactive-shell` skill and tmux.
