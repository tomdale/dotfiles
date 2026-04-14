---
name: tui-development
description: Build, test, and debug terminal user interfaces. Use when verifying TUI rendering, keyboard flows, layout issues, or terminal-specific behavior.
---

# TUI Development

Use this skill for terminal applications where the output is primarily visual.

This skill assumes the `interactive-shell` skill model: use a real PTY, not a
plain non-interactive command, whenever rendering fidelity matters.

## Core Loop

1. Build or prepare the app.
2. Run it in a PTY with a fixed terminal size.
3. Capture the rendered output.
4. Verify layout, focus, colors, and key flows.
5. Iterate.

## Environment

TUIs behave better when the terminal environment is explicit:

```bash
TERM=xterm-256color
COLORTERM=truecolor
LANG=en_US.UTF-8
LC_ALL=en_US.UTF-8
```

For a detached test session:

```bash
tmux new-session -d -s tui -x 120 -y 40 \
  'TERM=xterm-256color COLORTERM=truecolor ./my-app'
```

## Capture Techniques

### Fastest

Use `tmux capture-pane -p` to inspect the current screen as text.

### More Visual

Use `freeze` when installed to create screenshots of terminal output.

### For Iteration

Keep a named tmux session alive and re-run commands in it rather than starting
from scratch each time.

## What To Check

- Layout at realistic terminal sizes
- Overflow and wrapping
- Focus movement and selection state
- Keyboard shortcuts and exit behavior
- ANSI color use and contrast
- Loading states, spinners, and partial redraw glitches

## Good Defaults

- Width: `120`
- Height: `40`
- Use a consistent terminal size for before/after comparisons

## Common Failure Modes

- App assumes a TTY and fails silently without one
- Rendering depends on terminal width
- Unicode or color output breaks under the wrong locale or `TERM`
- Snapshotting text alone misses cursor or focus bugs

## Working Rules

- Treat tmux as a headless browser for terminal apps.
- Verify the real rendered UI, not just logs.
- When a bug is visual, capture the pane before editing again.
