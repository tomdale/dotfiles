# Claude Code instructions

@AGENTS.md

## Claude-specific rules

Claude Code sandbox behavior:

- For in-scope operations targeting the current workspace or its normal
  resources, stop on sandbox denial. Never retry with
  `dangerouslyDisableSandbox`. Identify the blocked resource, suggest a
  permission for `.claude/settings.json`, and wait for the user. Permission
  patterns include `Edit(/path/*_)`, `WebFetch(domain:host.com)`, and
  `Bash(cmd-prefix:_)`.
- For explicitly requested out-of-scope operations targeting another project
  or location, do not suggest edits to the current project's
  `.claude/settings.json`. Retry with `dangerouslyDisableSandbox` so the user
  can approve elevated access for that invocation.
- Only suggest `dangerouslyDisableSandbox` for in-scope work when permissions
  truly cannot solve the problem, such as dynamic paths or system-wide
  operations.
