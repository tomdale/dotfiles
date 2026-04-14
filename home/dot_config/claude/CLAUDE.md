For stacked PRs and advanced git workflows, use the graphite skill.

Comments: explain why, not what. Never reference how code changed from a
previous version. Ask: "will this make sense in a year to someone who never saw
the old code?" If not, put it in a commit message or PR description, not code.

Sandbox: write scratch/temp files to .agent/ (gitignored). Sandboxed commands
auto-approve; unsandboxed require manual approval per invocation. Always prefer
expanding sandbox permissions over disabling the sandbox.

On sandbox failure, STOP. Never retry with dangerouslyDisableSandbox. Identify
the blocked resource, suggest a permission for .claude/settings.json, wait for
the user. Permission patterns: file write Edit(/path/\*_), network
WebFetch(domain:host.com), command Bash(cmd-prefix:_). Only suggest
dangerouslyDisableSandbox when permissions cannot solve it (dynamic paths,
system-wide ops, one-off commands).

Browser automation: use the agent-browser skill. Always set
AGENT_BROWSER_PROFILE or pass --profile to preserve login sessions across
restarts.

Git commits: ALWAYS delegate to the code-committer agent. Never run git commit
directly.

The Bash tool runs non-interactive. REPLs, pagers, editors, CLI prompts,
progress bars, and color output all behave differently or fail without a tty.
Symptoms: no output, hangs, immediate exit, behavior differs from user's
terminal. For any REPL, interactive prompt, TUI, or progress-displaying program,
use tmux via the interactive-shell skill. Example: tmux new-session -d -s repl
-x 80 -y 24 'node', then tmux send-keys/capture-pane to interact.
