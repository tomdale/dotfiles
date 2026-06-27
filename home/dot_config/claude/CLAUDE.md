For stacked PRs and advanced git workflows, use the graphite skill.

Comments: explain why, not what. Never reference how code changed from a
previous version. Ask: "will this make sense in a year to someone who never saw
the old code?" If not, put it in a commit message or PR description, not code.

Sandbox: write scratch/temp files to .agent/ (gitignored). Sandboxed commands
auto-approve; unsandboxed require manual approval per invocation. Always prefer
expanding sandbox permissions over disabling the sandbox.

On sandbox failure, first decide whether the blocked operation is in scope for
the current task. The goal is for all normal development operations to succeed
*within* the sandbox by fixing the config — not by repeatedly breaking out of
it.

- **In scope** (the operation targets the current workspace — the repo you're
  working in and its normal dev resources): STOP. Never retry with
  dangerouslyDisableSandbox. Identify the blocked resource, suggest a permission
  for .claude/settings.json, wait for the user. Permission patterns: file write
  Edit(/path/\*_), network WebFetch(domain:host.com), command Bash(cmd-prefix:_).
- **Out of scope but explicitly requested** (the operation targets something
  outside the current workspace — e.g. while working in one repo, I ask you to
  edit my dotfiles or another project's files): do NOT stall by asking me to
  edit .claude/settings.json. Permanent config for an out-of-scope target is the
  wrong fix. Retry with dangerouslyDisableSandbox so I can approve the elevated
  access per invocation.

Only suggest dangerouslyDisableSandbox for in-scope work when permissions truly
cannot solve it (dynamic paths, system-wide ops, one-off commands).

Browser automation: use the agent-browser skill. Always set
AGENT_BROWSER_PROFILE or pass --profile to preserve login sessions across
restarts.

Git commits: ALWAYS delegate to the code-committer agent. Never run git commit
directly. Exception: if the local workspace defines its own commit rules (e.g. a
project CLAUDE.md, a repo-specific committer agent, or a skill that owns
committing), follow those instead — local workspace rules take precedence.

The Bash tool runs non-interactive. REPLs, pagers, editors, CLI prompts,
progress bars, and color output all behave differently or fail without a tty.
Symptoms: no output, hangs, immediate exit, behavior differs from user's
terminal. For any REPL, interactive prompt, TUI, or progress-displaying program,
use tmux via the interactive-shell skill. Example: tmux new-session -d -s repl
-x 80 -y 24 'node', then tmux send-keys/capture-pane to interact.
