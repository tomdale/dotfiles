---
name: tui-development
description:
  Develop, test, and debug TUI (Terminal User Interface) applications. Use when
  building TUI apps, testing terminal rendering, debugging UI issues, capturing
  screenshots, validating visual changes, or designing terminal interfaces.
allowed-tools:
  - Bash(tmux:*)
  - Bash(freeze:*)
  - Bash(cat:*)
  - Bash(diff:*)
  - Bash(sleep:*)
  - Bash(kill:*)
  - Bash(pgrep:*)
  - Bash(pkill:*)
  - Bash(cargo:*)
  - Bash(go:*)
  - Bash(npm:*)
  - Bash(npx:*)
  - Bash(python:*)
  - Bash(node:*)
  - Read
  - Write
  - Glob
---

# TUI Development for AI Agents

Develop, test, and validate Terminal User Interface applications.

> **Prerequisite:** This skill assumes familiarity with the `interactive-shell`
> skill, which covers tmux fundamentals for running interactive programs. Read
> that skill first if you haven't.

## Why tmux for TUI Development?

TUI development presents unique challenges for AI agents: the output is visual
and not easily parseable. tmux serves as a **headless browser for terminals**:

- Provides a real PTY that TUI frameworks expect
- Allows programmatic input via `send-keys`
- Enables output capture via `capture-pane`
- Supports screenshots via freeze

This enables a **visual verification loop**:

```
Edit Code → Build → Run in tmux → Capture Output → Verify → Repeat
```

---

## Prerequisites

```bash
# Install freeze (Charm's terminal screenshot tool)
brew install charmbracelet/tap/freeze

# Verify tmux is available
which tmux
```

---

## 1. TUI Environment Setup

### Terminal Environment Variables

TUIs require specific environment for proper rendering:

```bash
TERM=xterm-256color        # 256 color support
COLORTERM=truecolor        # 24-bit color support
LANG=en_US.UTF-8           # Unicode support
LC_ALL=en_US.UTF-8

# Full example
tmux new-session -d -s tui -x 120 -y 40 \
  'TERM=xterm-256color COLORTERM=truecolor ./my-tui-app'
```

### Size Guidelines

| Use Case                  | Size   | Flags          |
| ------------------------- | ------ | -------------- |
| Standard TUI              | 80x24  | `-x 80 -y 24`  |
| Wide tables/dashboards    | 120x40 | `-x 120 -y 40` |
| Full-screen TUI           | 160x50 | `-x 160 -y 50` |
| Mobile/narrow testing     | 60x20  | `-x 60 -y 20`  |
| Documentation screenshots | 100x30 | `-x 100 -y 30` |

### Language-Specific Examples

```bash
# Rust (ratatui, crossterm)
cargo build --release && \
  tmux new-session -d -s tui -x 80 -y 24 './target/release/my-tui'

# Go (bubbletea, tview)
go build && \
  tmux new-session -d -s tui -x 80 -y 24 './myapp'

# Python (textual, rich)
tmux new-session -d -s tui -x 80 -y 24 'python -m myapp'

# Node.js (blessed, ink)
tmux new-session -d -s tui -x 80 -y 24 'npx tsx ./src/app.tsx'
```

---

## 2. TUI Interaction Patterns

### Key Reference for TUI Navigation

| Action          | tmux Key                      |
| --------------- | ----------------------------- |
| Arrow keys      | `Up`, `Down`, `Left`, `Right` |
| Page navigation | `PgUp`, `PgDn`, `Home`, `End` |
| Tab navigation  | `Tab`, `BTab` (shift-tab)     |
| Confirm/Cancel  | `Enter`, `Escape`             |
| Function keys   | `F1` through `F12`            |
| Vim-style       | `j`, `k`, `h`, `l`, `g`, `G`  |
| Ctrl combos     | `C-c`, `C-d`, `C-z`, `C-p`    |

### Timing Between UI Actions

TUIs need time to render between actions:

```bash
# Bad: too fast, TUI can't keep up
tmux send-keys -t tui Down Down Down Enter

# Good: small delays between navigation
tmux send-keys -t tui Down
sleep 0.1
tmux send-keys -t tui Down
sleep 0.1
tmux send-keys -t tui Enter

# Better: wait for expected UI state
tmux send-keys -t tui Down
until tmux capture-pane -t tui -p | grep -q "> Item 2"; do sleep 0.05; done
tmux send-keys -t tui Enter
```

### Common Interaction Patterns

```bash
# Navigate a list
tmux send-keys -t tui Down Down Enter
sleep 0.2

# Type into search/input
tmux send-keys -t tui 'search query' Enter
sleep 0.3

# Open command palette (common pattern)
tmux send-keys -t tui C-p
sleep 0.1
tmux send-keys -t tui 'command name' Enter

# Scroll through content
for i in {1..10}; do
  tmux send-keys -t tui Down
  sleep 0.05
done
```

---

## 3. Capturing and Analyzing Output

### capture-pane for TUI State

```bash
# Plain text (no colors)
tmux capture-pane -t tui -p

# With ANSI colors (for screenshot)
tmux capture-pane -t tui -p -e > .agent/tui-dev/capture.txt

# Specific line range
tmux capture-pane -t tui -p -S 0 -E 20

# Include scrollback
tmux capture-pane -t tui -p -S -1000
```

| Flag   | Purpose                            |
| ------ | ---------------------------------- |
| `-p`   | Print to stdout                    |
| `-e`   | Include ANSI escape codes          |
| `-S n` | Start line (negative = scrollback) |
| `-E n` | End line                           |
| `-J`   | Join wrapped lines                 |

### Programmatic State Verification

```bash
# Check for expected content
tmux capture-pane -t tui -p | grep -q "Welcome" || echo "FAIL: Missing welcome"

# Check for error states
tmux capture-pane -t tui -p | grep -qE "Error|panic|crash" && echo "CRASH DETECTED"

# Get specific line (e.g., status bar)
tmux capture-pane -t tui -p | tail -1

# Count list items
tmux capture-pane -t tui -p | grep -c "│ •"
```

### Screenshots with freeze

```bash
# Capture to file first
tmux capture-pane -t tui -p -e > .agent/tui-dev/capture.txt

# Basic PNG
freeze .agent/tui-dev/capture.txt -o screenshot.png

# Styled for documentation
freeze .agent/tui-dev/capture.txt -o screenshot.png \
  --theme dracula \
  --padding 20 \
  --margin 20 \
  --border.radius 8 \
  --shadow.blur 20 \
  --font.family "JetBrains Mono" \
  --font.size 14 \
  --window

# SVG for scalability
freeze .agent/tui-dev/capture.txt -o screenshot.svg
```

| freeze Option     | Description                        |
| ----------------- | ---------------------------------- |
| `--theme`         | `dracula`, `monokai`, `nord`, etc. |
| `--padding`       | Internal padding (px)              |
| `--margin`        | External margin (px)               |
| `--border.radius` | Corner radius                      |
| `--shadow.blur`   | Shadow blur radius                 |
| `--font.family`   | Font name                          |
| `--window`        | Show window chrome                 |

### Before/After Comparison

```bash
# Capture before
tmux capture-pane -t tui -p > .agent/tui-dev/before.txt

# Perform action
tmux send-keys -t tui Enter
sleep 0.5

# Capture after
tmux capture-pane -t tui -p > .agent/tui-dev/after.txt

# Compare
diff .agent/tui-dev/before.txt .agent/tui-dev/after.txt
```

---

## 4. AI Agent Development Loop

### The Visual Verification Workflow

```
┌─────────────────────────────────────────────────────────┐
│                  TUI Development Loop                   │
├─────────────────────────────────────────────────────────┤
│   ┌────────┐    ┌────────┐    ┌────────┐               │
│   │ 1.Edit │───▶│2.Build │───▶│ 3.Run  │               │
│   │  Code  │    │  App   │    │in tmux │               │
│   └────────┘    └────────┘    └────────┘               │
│        ▲                           │                    │
│        │                           ▼                    │
│   ┌────────┐    ┌────────┐    ┌────────┐               │
│   │ 6.Fix  │◀───│5.Verify│◀───│4.Capture│              │
│   │ Issues │    │ State  │    │ Output │               │
│   └────────┘    └────────┘    └────────┘               │
└─────────────────────────────────────────────────────────┘
```

### Complete Development Cycle

```bash
# === 1. Edit code (use Edit tool) ===

# === 2. Build ===
cargo build --release || { echo "Build failed"; exit 1; }

# === 3. Start TUI ===
tmux kill-session -t tui 2>/dev/null || true
tmux new-session -d -s tui -x 120 -y 40 \
  'TERM=xterm-256color ./target/release/my-tui'
sleep 2

# === 4. Capture state ===
mkdir -p .agent/tui-dev
tmux capture-pane -t tui -p -e > .agent/tui-dev/state.txt

# === 5. Verify ===
grep -q "Welcome" .agent/tui-dev/state.txt || echo "FAIL: Missing welcome"
grep -qE "Error|panic" .agent/tui-dev/state.txt && echo "FAIL: Crash detected"

# === 6. Test interaction ===
tmux send-keys -t tui Tab Enter
sleep 0.5
tmux capture-pane -t tui -p > .agent/tui-dev/after-interact.txt
grep -q "Feature Active" .agent/tui-dev/after-interact.txt && echo "PASS"

# === Cleanup ===
tmux kill-session -t tui
```

### Validation Helpers

```bash
# Wait for content with timeout
wait_for_content() {
  local pattern="$1" timeout="${2:-30}" target="${3:-tui}"
  for i in $(seq 1 $timeout); do
    tmux capture-pane -t "$target" -p | grep -q "$pattern" && return 0
    sleep 0.1
  done
  echo "TIMEOUT: '$pattern' not found"
  return 1
}

# Assert content present/absent
assert_content() {
  tmux capture-pane -t "${2:-tui}" -p | grep -q "$1" || { echo "FAIL: Missing '$1'"; return 1; }
}

assert_no_content() {
  tmux capture-pane -t "${2:-tui}" -p | grep -q "$1" && { echo "FAIL: Found '$1'"; return 1; }
}
```

### Regression Testing

```bash
# Save golden reference
tmux capture-pane -t tui -p > .agent/tui-dev/golden/main-screen.txt

# Compare against golden (strip ANSI for content comparison)
strip_ansi() { sed 's/\x1b\[[0-9;]*m//g'; }
diff <(strip_ansi < .agent/tui-dev/golden/main-screen.txt) \
     <(strip_ansi < .agent/tui-dev/current.txt)
```

---

## 5. TUI Design Best Practices

### Layout & Sizing

**Design for 80x24 minimum.** This is the traditional terminal size and ensures
compatibility. Test at multiple sizes:

```bash
# Test minimum
tmux new-session -d -s test -x 80 -y 24 './app'
# Test wide
tmux new-session -d -s test -x 160 -y 50 './app'
# Test narrow (mobile/split pane)
tmux new-session -d -s test -x 60 -y 20 './app'
```

**Handle resize gracefully.** TUI should reflow content, not break.

### Color & Theming

- **Use semantic colors** (error=red, success=green, warning=yellow)
- **Support ANSI 16 colors** as fallback, enhance with 256/truecolor
- **Respect NO_COLOR environment variable**
- **Test without colors:** `TERM=dumb ./app`

### Keyboard Navigation

| Pattern        | Keys           | Purpose              |
| -------------- | -------------- | -------------------- |
| Vim-style      | `j/k/h/l`      | Navigation           |
| Arrow keys     | `↑↓←→`         | Always support these |
| Tab            | `Tab/S-Tab`    | Focus cycling        |
| Confirm/Cancel | `Enter/Escape` | Action completion    |
| Quit           | `q` or `C-c`   | Always provide exit  |

**Display keybindings.** Show available keys in a help bar or `?` menu.

### State & Feedback

- **Show loading states** for async operations
- **Provide visual feedback** on every action
- **Display errors inline** where they occurred
- **Support undo** for destructive actions when possible

### Accessibility

- **High contrast** default theme
- **Avoid color-only differentiation** (use symbols too)
- **Screen reader hints** via semantic structuring
- **Keyboard-only navigation** must be complete

---

## 6. Troubleshooting

### Common Issues

| Problem               | Cause              | Solution                      |
| --------------------- | ------------------ | ----------------------------- |
| App exits immediately | Missing TTY        | Run inside tmux session       |
| No colors in capture  | Missing `-e` flag  | Add `-e` to capture-pane      |
| Wrong dimensions      | Not set explicitly | Use `-x` and `-y` flags       |
| Keys not registering  | Too fast           | Add `sleep 0.1` between sends |
| Unicode garbled       | Locale issue       | Set `LANG=en_US.UTF-8`        |
| App unresponsive      | Wrong TERM         | Try `TERM=xterm-256color`     |

### Debugging Rendering

```bash
# Check TERM value
tmux send-keys -t tui 'echo $TERM' Enter
sleep 0.5
tmux capture-pane -t tui -p | tail -2

# Verify color support
tmux send-keys -t tui 'tput colors' Enter

# Check for ANSI codes in capture
cat -v .agent/tui-dev/capture.txt | head -10

# Verify session dimensions
tmux display-message -t tui -p '#{window_width}x#{window_height}'
```

### Handling Crashes

```bash
# Check if session exists
tmux has-session -t tui 2>/dev/null && echo "running" || echo "gone"

# Capture crash output
tmux capture-pane -t tui -p -e -S -1000 > .agent/tui-dev/crash-log.txt
```

---

## 7. Directory Convention

```
.agent/tui-dev/
├── captures/          # Raw terminal captures
├── screenshots/       # Generated images
├── golden/            # Reference states for regression
└── logs/              # Build/crash logs
```

---

## Quick Reference

```bash
# Start TUI in tmux
tmux new-session -d -s tui -x 120 -y 40 'TERM=xterm-256color ./app'
sleep 2

# Send keystrokes
tmux send-keys -t tui Down Enter

# Capture output
tmux capture-pane -t tui -p -e > .agent/tui-dev/output.txt

# Take screenshot
freeze .agent/tui-dev/output.txt -o screenshot.png --theme nord

# Check for content
tmux capture-pane -t tui -p | grep -q "Success" && echo "OK"

# Cleanup
tmux kill-session -t tui
```
