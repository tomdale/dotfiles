## General Preferences

- For stacked PRs and advanced git workflows, use the `graphite` skill

## Code Comments

Write comments that remain valuable to future readers who have no context about
how the code evolved.

**Focus on why, not what.** The code shows what it does; comments should explain
non-obvious reasoning, constraints, or trade-offs.

```javascript
// Good: explains why
// Rate limit to 100 req/s to stay under the API's undocumented threshold
const RATE_LIMIT = 100;

// Bad: restates what the code already says
// Set rate limit to 100
const RATE_LIMIT = 100;
```

**Avoid change-relative comments.** Never write comments describing how code
changed from a previous implementation. These become meaningless or confusing
once the old implementation is forgotten.

```javascript
// Bad: anchored to forgotten past
/* Note: AddTask, CompleteTask have been removed. The system now uses
   Claude Code's native TaskCreate and TaskUpdate tools. */

// Bad: implies temporary state that will become permanent
// Temporarily disabled until the new auth system is ready

// Good: describes current behavior without referencing the past
// Delegates to Claude Code's native task management tools
```

**Keep comments evergreen.** Before writing a comment, ask: "Will this make
sense to someone reading this code in a year who never saw the previous
version?" If not, the information belongs in a commit message, PR description,
or changelog—not in code.

## Sandbox

_You are running in a sandbox._ You can read most files, but generally cannot
write (or use tools that write) outside the project root. Any scratch files,
temporary files, generated artifacts, temporary code, or other files that are
not part of the project should be written to `.agent/` inside the project root.
This directory is ignored by version control.

### Why This Matters for Productivity

Sandboxed commands are auto-approved and execute immediately. Unsandboxed
commands require manual approval for **each and every invocation**. A task that
would take seconds with proper permissions becomes a tedious approval marathon
without them. Always prefer expanding sandbox permissions over disabling the
sandbox.

### When a Command Fails Due to Sandbox Restrictions

**STOP immediately.** Do not retry with `dangerouslyDisableSandbox`. Instead:

1. **Identify the blocked resource** from the error message (file path, network
   host, etc.)
2. **Suggest a specific permission** to add to `.claude/settings.json`
3. **Wait for the user** to add the permission before retrying

### Permission Syntax for `.claude/settings.json`

```json
{
  "permissions": {
    "allow": [
      "Edit(~/Library/Caches/Homebrew/**)",
      "Edit(/opt/homebrew/**)",
      "Bash(brew install:*)",
      "WebFetch(domain:api.example.com)"
    ]
  }
}
```

| Blocked Resource                 | Permission to Suggest            |
| -------------------------------- | -------------------------------- |
| File write to `/path/to/dir/...` | `"Edit(/path/to/dir/**)"`        |
| Network access to `api.foo.com`  | `"WebFetch(domain:api.foo.com)"` |
| Specific command pattern         | `"Bash(command-prefix:*)"`       |

### When Unsandboxed Execution Is Appropriate

Only suggest `dangerouslyDisableSandbox` when the failure **cannot** be resolved
by adding permissions—for example:

- Commands that write to unpredictable/dynamic paths
- System-level operations that touch many directories
- One-off commands where adding permissions isn't worth the overhead

## Browser Automation (agent-browser)

Use the `agent-browser` skill for any task requiring web interaction (navigating
sites, filling forms, taking screenshots, extracting data, testing web apps).

**Always use a persistent profile.** Set `AGENT_BROWSER_PROFILE` or pass
`--profile` on every invocation. Without this, every browser restart loses all
login sessions and you waste enormous time on repeated authentication. See the
`agent-browser` skill for full details.

## Git Commits

**ALWAYS** delegate to the `code-committer` agent for all commit operations.
Never run `git commit` directly.

## Interactive vs Non-Interactive Shell (CRITICAL)

**The Bash tool runs in a non-interactive shell.** Many programs behave
_completely differently_ in interactive vs non-interactive mode. This causes
subtle, maddening bugs that waste hours to diagnose.

### Programs That Lie to You in Non-Interactive Mode

| Program Type                       | Interactive Behavior      | Non-Interactive Behavior                     |
| ---------------------------------- | ------------------------- | -------------------------------------------- |
| REPLs (node, python, irb)          | Prompt, readline, history | Often exit immediately or behave differently |
| Pagers (less, more)                | Interactive scrolling     | Dump all output or hang                      |
| Editors (vim, nano)                | Full TUI                  | Crash, hang, or corrupt terminal             |
| CLI prompts (npm init, git commit) | Wait for input            | Hang, use defaults, or fail                  |
| Progress bars/spinners             | Animated display          | May omit output entirely                     |
| Color output                       | ANSI colors               | Often suppressed (no tty)                    |
| Tab completion                     | Works                     | Disabled                                     |

### Warning Signs You're Being Bitten

- Command "works" but produces no output (program detected no tty, suppressed
  output)
- Command hangs indefinitely (waiting for input that never comes)
- Command exits immediately with no error (detected non-interactive, bailed out)
- Behavior differs from what the user sees when they run the same command
- Program claims success but user reports it didn't work

### The Fix: Use tmux for Interactive Programs

**When interacting with stateful or interactive programs, use tmux.** The
`interactive-shell` skill provides the patterns. tmux gives you a real PTY
(pseudo-terminal) that programs recognize as interactive.

```bash
# WRONG: Running an interactive program directly
node  # Hangs or exits immediately

# RIGHT: Run in tmux for proper interactive behavior
tmux new-session -d -s repl -x 80 -y 24 'node'
sleep 0.5
tmux send-keys -t repl 'console.log("hello")' Enter
sleep 0.2
tmux capture-pane -t repl -p  # See the actual output
tmux kill-session -t repl
```

### Default to Suspicion

If a command involves:

- Any REPL or interactive interpreter
- Any program that prompts for input
- Any TUI application
- Any program that shows progress or animations
- Testing how a CLI tool appears to users

**Stop. Use tmux.** Don't waste time debugging phantom issues caused by
non-interactive shell differences. The `interactive-shell` skill documents the
patterns.
