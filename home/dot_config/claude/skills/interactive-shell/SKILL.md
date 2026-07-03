---
name: interactive-shell
description:
  Interact with programs that require an interactive terminal/PTY. Use when
  running REPLs, interactive CLIs, programs with prompts, or any command that
  behaves differently in non-interactive mode. Essential for avoiding phantom
  bugs from shell mode differences.
allowed-tools:
  - Bash(tmux:*)
  - Bash(sleep:*)
  - Bash(kill:*)
  - Bash(pgrep:*)
  - Bash(pkill:*)
  - Read
  - Write
  - Glob
---

# Interactive Shell Patterns for AI Agents

Run programs that require an interactive terminal using tmux as a PTY wrapper.

## The Problem

**Claude Code's Bash tool runs in a non-interactive shell.** Programs detect
this and change behavior—often silently. This causes:

- Commands that "work" but produce no output
- Commands that hang waiting for input
- Commands that exit immediately without error
- Behavior that differs from what users experience

**tmux solves this** by providing a real pseudo-terminal (PTY) that programs
recognize as interactive.

---

## Quick Reference

```bash
# Run interactive program
tmux new-session -d -s sess -x 80 -y 24 '<command>'
sleep 0.5

# Send input
tmux send-keys -t sess 'input text' Enter

# Read output
tmux capture-pane -t sess -p

# Cleanup
tmux kill-session -t sess
```

---

## 1. When to Use tmux

### Always Use tmux For:

| Category               | Examples                                              |
| ---------------------- | ----------------------------------------------------- |
| REPLs                  | `node`, `python`, `irb`, `psql`, `sqlite3`, `mongosh` |
| Interactive CLIs       | `npm init`, `yarn create`, `gh auth login`            |
| Prompting programs     | Any program that asks questions                       |
| TUI applications       | `htop`, `vim`, `less`, `fzf`, `tig`                   |
| Programs with progress | Long downloads, builds with spinners                  |
| Testing CLI appearance | Verifying what users actually see                     |

### Don't Need tmux For:

- Simple commands with no interaction: `ls`, `cat`, `grep`
- Build tools that just output logs: `cargo build`, `npm install`
- One-shot commands: `git status`, `curl https://...`

### Signs You Should Switch to tmux:

- No output when you expected some
- Command hangs indefinitely
- Command exits immediately without doing anything
- User reports different behavior than you observed

---

## 2. Session Management

### Create Session

```bash
# Basic: run command in 80x24 terminal
tmux new-session -d -s <name> -x 80 -y 24 '<command>'

# With environment variables
tmux new-session -d -s repl -x 80 -y 24 \
  'TERM=xterm-256color python3'

# In specific directory
tmux new-session -d -s dev -x 100 -y 30 -c /path/to/project 'npm start'
```

### Session Naming

Use descriptive names:

```bash
tmux new-session -d -s node-repl ...
tmux new-session -d -s psql-test ...
tmux new-session -d -s npm-init ...
```

### Cleanup

```bash
# Kill specific session
tmux kill-session -t <name>

# Kill if exists (idempotent)
tmux kill-session -t repl 2>/dev/null || true

# List sessions
tmux list-sessions

# Kill everything (nuclear option)
tmux kill-server
```

---

## 3. Sending Input

### Basic Input

```bash
# Send text and Enter
tmux send-keys -t sess 'command here' Enter

# Send just Enter (confirm default)
tmux send-keys -t sess Enter

# Send escape (cancel)
tmux send-keys -t sess Escape

# Send Ctrl+C (interrupt)
tmux send-keys -t sess C-c

# Send Ctrl+D (EOF)
tmux send-keys -t sess C-d
```

### Special Keys

| Key        | tmux Syntax                    |
| ---------- | ------------------------------ |
| Enter      | `Enter`                        |
| Escape     | `Escape`                       |
| Tab        | `Tab`                          |
| Backspace  | `BSpace`                       |
| Arrow keys | `Up`, `Down`, `Left`, `Right`  |
| Ctrl+key   | `C-<key>` (e.g., `C-c`, `C-a`) |
| Alt+key    | `M-<key>` (e.g., `M-x`)        |

### Timing Between Inputs

**Always add delays between inputs.** Programs need time to process.

```bash
# Bad: too fast
tmux send-keys -t sess 'y' Enter 'n' Enter

# Good: explicit delays
tmux send-keys -t sess 'y' Enter
sleep 0.2
tmux send-keys -t sess 'n' Enter
```

---

## 4. Reading Output

### Capture Current Screen

```bash
# Plain text
tmux capture-pane -t sess -p

# With ANSI colors preserved
tmux capture-pane -t sess -p -e

# Save to file
tmux capture-pane -t sess -p > output.txt
```

### Include Scrollback History

```bash
# Last 100 lines of history
tmux capture-pane -t sess -p -S -100

# All history
tmux capture-pane -t sess -p -S -
```

### Check for Specific Content

```bash
# Check if content exists
tmux capture-pane -t sess -p | grep -q "pattern" && echo "found"

# Wait for content to appear
for i in {1..30}; do
  tmux capture-pane -t sess -p | grep -q "ready" && break
  sleep 0.1
done
```

---

## 5. Common Patterns

### REPL Interaction

```bash
# Start REPL
tmux new-session -d -s repl -x 80 -y 24 'python3'
sleep 0.5

# Execute code
tmux send-keys -t repl 'x = 42' Enter
sleep 0.1
tmux send-keys -t repl 'print(x * 2)' Enter
sleep 0.2

# Read output
tmux capture-pane -t repl -p

# Exit
tmux send-keys -t repl 'exit()' Enter
sleep 0.2
tmux kill-session -t repl
```

### Answering Prompts

```bash
# Start interactive installer
tmux new-session -d -s init -x 80 -y 24 'npm init'
sleep 0.5

# Answer questions
tmux send-keys -t init 'my-package' Enter  # name
sleep 0.2
tmux send-keys -t init '1.0.0' Enter       # version
sleep 0.2
tmux send-keys -t init Enter               # accept default
sleep 0.2

# Verify completion
tmux capture-pane -t init -p | grep -q "package.json" && echo "done"
tmux kill-session -t init
```

### Database REPL

```bash
tmux new-session -d -s db -x 120 -y 40 'psql mydatabase'
sleep 1

# Run query
tmux send-keys -t db 'SELECT * FROM users LIMIT 5;' Enter
sleep 0.5

# Get results
tmux capture-pane -t db -p

# Exit
tmux send-keys -t db '\q' Enter
tmux kill-session -t db
```

### Long-Running Process with Progress

```bash
# Start download
tmux new-session -d -s dl -x 80 -y 24 'curl -O https://example.com/large-file.zip'

# Poll for completion
while tmux has-session -t dl 2>/dev/null; do
  tmux capture-pane -t dl -p | tail -1  # Show progress
  sleep 2
done

echo "Download complete"
```

---

## 6. Waiting Strategies

### Fixed Delay (Simple)

```bash
sleep 0.5  # Wait 500ms
```

### Poll for Content (Reliable)

```bash
# Wait up to 3 seconds for "ready"
for i in {1..30}; do
  tmux capture-pane -t sess -p | grep -q "ready" && break
  sleep 0.1
done
```

### Wait for Session to Exit

```bash
# Run command and wait for completion
tmux new-session -d -s job -x 80 -y 24 'make build'

while tmux has-session -t job 2>/dev/null; do
  sleep 0.5
done

echo "Build complete"
```

### Wait for Prompt

```bash
# Wait for shell prompt to reappear
wait_for_prompt() {
  local sess="$1"
  for i in {1..50}; do
    if tmux capture-pane -t "$sess" -p | tail -1 | grep -qE '[$#>] ?$'; then
      return 0
    fi
    sleep 0.1
  done
  return 1
}
```

---

## 7. Troubleshooting

### Session Disappeared

The command exited. Check what happened:

```bash
# Before killing, capture scrollback
tmux capture-pane -t sess -p -S - 2>/dev/null || echo "Session gone"
```

### No Output

- Add `-e` flag to preserve escape sequences
- Program may need longer to start—increase sleep
- Program may require specific TERM: `TERM=xterm-256color`

### Command Hangs

- Probably waiting for input—send Enter or the expected response
- Might need Ctrl+C: `tmux send-keys -t sess C-c`
- Check if it's actually running: `tmux list-panes -t sess -F '#{pane_pid}'`

### Garbled Unicode

Set locale in the command:

```bash
tmux new-session -d -s sess -x 80 -y 24 \
  'LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 <command>'
```

---

## 8. Directory Convention

Store session captures in `.agent/`:

```bash
mkdir -p .agent/interactive

# Save captures
tmux capture-pane -t sess -p > .agent/interactive/repl-output.txt
```
