---
name: interactive-shell
description: Interact with programs that require a real terminal or PTY. Use when running REPLs, prompt-driven CLIs, login flows, or commands that behave differently in non-interactive shells.
---

# Interactive Shell

Use this skill when a plain non-interactive command is the wrong execution
model.

## Prefer These Execution Modes

1. Use `exec_command` with `tty: true` for short interactive sessions.
2. Use `write_stdin` to answer prompts, send commands, and poll for output.
3. Use `tmux` only when you need a detached session, repeated inspection, or a
real terminal that outlives one tool call.

## Signs You Need It

- A command hangs waiting for input
- A CLI shows no output unless run in a terminal
- A prompt-driven tool behaves differently from what the user sees locally
- You need to keep a REPL, TUI, or auth flow alive across multiple actions

## Short Interactive Pattern

Start the command in a PTY:

```text
exec_command:
  tty: true
  yield_time_ms: 1000
```

Then drive it incrementally:

```text
write_stdin:
  chars: "yes\n"
```

Use empty `chars` to poll when you only want fresh output.

## When To Use tmux

Use `tmux` when you need one of:

- A long-running interactive process you revisit later
- Stable screen capture with a fixed terminal size
- Detached execution while you do other work
- Multiple panes or repeated `capture-pane` snapshots

Basic pattern:

```bash
tmux new-session -d -s sess -x 120 -y 40 '<command>'
tmux capture-pane -t sess -p
tmux send-keys -t sess 'input text' Enter
tmux kill-session -t sess
```

## Common Cases

### REPLs

- `python`
- `node`
- `psql`
- `sqlite3`

### Prompt-driven CLIs

- auth/login flows
- project generators
- setup/install wizards

### TUIs

- `vim`
- `less`
- `fzf`
- application-specific terminal UIs

## Working Rules

- Do not assume non-interactive output is authoritative when the command is
normally used in a terminal.
- Prefer small incremental writes over blasting many commands at once.
- If the session state matters, keep one PTY alive instead of repeatedly
restarting the command.
- Clean up tmux sessions when finished.
