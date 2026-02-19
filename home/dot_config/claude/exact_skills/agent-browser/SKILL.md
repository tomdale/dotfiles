---
name: agent-browser
description:
  Automates browser interactions for web testing, form filling, screenshots, and
  data extraction. Use when the user needs to navigate websites, interact with
  web pages, fill forms, take screenshots, test web applications, or extract
  information from web pages.
allowed-tools:
  - Bash(agent-browser:*)
  - Bash(sleep:*)
  - Bash(kill:*)
  - Bash(pgrep:*)
  - Bash(base64:*)
  - Read
  - Write
  - Glob
---

# Browser Automation with agent-browser

Headless browser automation CLI for AI agents. Each command is a single
stateless CLI call—no SDK, no server process to manage.

---

## CRITICAL: Use Persistent Profiles

**Every `agent-browser` invocation in a project MUST use `--profile`.**

Without `--profile`, browser state is ephemeral. Every `open` starts a fresh
browser with no cookies, no localStorage, no sessions. This means **every
navigation to an authenticated page triggers a full login flow**. Across a
multi-step task, this wastes enormous amounts of time on repeated logins.

```bash
# WRONG — ephemeral, loses all auth state between browser restarts
agent-browser open https://app.example.com
# ...browser closes...
agent-browser open https://app.example.com  # Must log in again

# RIGHT — persistent profile preserves cookies, storage, sessions
agent-browser --profile ~/.agent-browser-profile open https://app.example.com
# ...browser closes...
agent-browser --profile ~/.agent-browser-profile open https://app.example.com  # Still logged in
```

### Profile Setup

Use a **single shared profile directory per machine** for general browsing:

```bash
export AGENT_BROWSER_PROFILE="$HOME/.agent-browser-profile"
```

Or use **project-specific profiles** when isolation matters:

```bash
export AGENT_BROWSER_PROFILE=".agent/browser-profile"
```

The environment variable applies to all commands, eliminating the need to pass
`--profile` every time.

### What the Profile Stores

- Cookies and localStorage/sessionStorage
- IndexedDB data
- Service workers and browser cache
- Login sessions and auth tokens
- Browser history

### Login Once, Reuse Forever

After logging in once with a persistent profile, all subsequent sessions on that
profile skip authentication. This is the **single most important optimization**
for browser automation productivity.

---

## Connecting to an Existing Chrome (CDP)

For sites where the user already has active sessions in Chrome, connect via CDP
instead of launching a new browser:

```bash
# User launches Chrome with remote debugging
/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome \
  --user-data-dir=$HOME/.agent-browser-profile \
  --remote-debugging-port=9222 &

# Connect to the running Chrome — inherits all cookies, sessions, extensions
agent-browser --cdp 9222 open https://app.example.com
agent-browser --cdp 9222 snapshot -i
```

CDP accepts a port number or a full WebSocket URL for remote browsers:

```bash
agent-browser --cdp 9222 snapshot                      # Local port
agent-browser --cdp "wss://remote.example.com/cdp" snapshot  # Remote WebSocket
```

---

## Core Workflow: snapshot → act → snapshot

The fundamental loop for browser automation:

```bash
# 1. Take a snapshot to see interactive elements (with @ref identifiers)
agent-browser snapshot -i

# 2. Act on elements using their @ref
agent-browser click @e3
agent-browser fill @e7 "search query"
agent-browser press Enter

# 3. Wait for page to settle, then snapshot again
agent-browser wait --load networkidle
agent-browser snapshot -i
```

### Refs Are Ephemeral

Element refs (`@e1`, `@e2`, ...) are assigned per-snapshot and **invalidated**
when the page changes. Always re-snapshot after:

- Clicking links or buttons
- Form submissions
- Dynamic content loading (SPAs, AJAX)
- Navigation events

### Snapshot Flags

| Flag                    | Purpose                                      |
| ----------------------- | -------------------------------------------- |
| `-i` / `--interactive`  | Show only interactive elements (recommended) |
| `-C` / `--cursor`       | Include cursor-interactive elements too      |
| `-c` / `--compact`      | Remove empty structural elements             |
| `-d N` / `--depth N`    | Limit tree depth                             |
| `-s SEL` / `--selector` | Scope to a CSS selector                      |
| `--json`                | JSON output for programmatic processing      |

Always prefer `snapshot -i` over bare `snapshot` to reduce output size.

---

## Sessions: Parallel Browser Instances

Use `--session` to run multiple isolated browser instances simultaneously:

```bash
# Launch two browsers in parallel
agent-browser --session site-a open https://site-a.com
agent-browser --session site-b open https://site-b.com

# Interact with each independently
agent-browser --session site-a snapshot -i
agent-browser --session site-b snapshot -i

# Each session has its own cookies, tabs, navigation history
```

### Combining Sessions with Profiles

Sessions and profiles serve different purposes:

- **`--profile`** = persistent storage on disk (survives browser restarts)
- **`--session`** = isolated browser instance in memory (for parallelism)

When using both, **all sessions share the same profile's stored state** (cookies,
etc.) but maintain independent runtime state (open tabs, navigation):

```bash
# Both sessions start with the same saved cookies from the profile
agent-browser --profile ~/.agent-browser-profile --session tab1 open https://app.example.com/page1
agent-browser --profile ~/.agent-browser-profile --session tab2 open https://app.example.com/page2
```

### Environment Variable for Sessions

```bash
export AGENT_BROWSER_SESSION=my-session
agent-browser open https://example.com    # Uses "my-session"
```

### Session Management

```bash
agent-browser session           # Show current session info
agent-browser session list      # List all active sessions
agent-browser --session X close # Close a specific session
```

---

## Command Reference

### Navigation

```bash
agent-browser open <url>        # Navigate to URL (auto-prepends https://)
agent-browser back              # Go back
agent-browser forward           # Go forward
agent-browser reload            # Reload page
```

### Interactions

```bash
agent-browser click <sel>              # Click element
agent-browser dblclick <sel>           # Double-click
agent-browser fill <sel> <text>        # Clear field, then type text
agent-browser type <sel> <text>        # Type without clearing
agent-browser press <key>             # Press key (Enter, Tab, Escape, Control+a)
agent-browser hover <sel>             # Hover over element
agent-browser check <sel>             # Check checkbox
agent-browser uncheck <sel>           # Uncheck checkbox
agent-browser select <sel> <value>    # Select dropdown option
agent-browser scroll down [px]        # Scroll (up/down/left/right, default 300px)
agent-browser scrollintoview <sel>    # Scroll element into view
agent-browser drag <src> <tgt>        # Drag and drop
agent-browser upload <sel> <files>    # Upload files
agent-browser focus <sel>             # Focus element
```

### Get Information

```bash
agent-browser get text <sel>           # Text content
agent-browser get html <sel>           # innerHTML
agent-browser get value <sel>          # Input value
agent-browser get attr <sel> <attr>    # Element attribute
agent-browser get title                # Page title
agent-browser get url                  # Current URL
agent-browser get count <sel>          # Count matching elements
agent-browser get box <sel>            # Bounding box
agent-browser get styles <sel>         # Computed styles
```

### Check State

```bash
agent-browser is visible <sel>
agent-browser is enabled <sel>
agent-browser is checked <sel>
```

### Waiting

```bash
agent-browser wait <selector>                    # Wait for element visible
agent-browser wait <ms>                          # Wait milliseconds
agent-browser wait --text "Welcome"              # Wait for text to appear
agent-browser wait --url "**/dashboard"          # Wait for URL pattern
agent-browser wait --load networkidle            # Wait for network idle
agent-browser wait --fn "window.ready === true"  # Wait for JS condition
```

### Semantic Locators (find)

When you don't have a ref or CSS selector, use semantic locators:

```bash
agent-browser find role button click --name "Submit"     # Click button by name
agent-browser find label "Email" fill "user@example.com" # Fill by label
agent-browser find placeholder "Search..." fill "query"  # Fill by placeholder
agent-browser find text "Sign In" click                  # Click by text content
agent-browser find testid "login-btn" click              # Click by data-testid
```

### Screenshots & Capture

```bash
agent-browser screenshot                    # Screenshot to temp dir
agent-browser screenshot ./capture.png      # Screenshot to specific path
agent-browser screenshot --full             # Full page screenshot
agent-browser pdf ./page.pdf                # Save as PDF
```

### Video Recording

```bash
agent-browser record start [path]     # Start recording WebM
agent-browser record stop [path]      # Stop recording
```

### Tabs

```bash
agent-browser tab                # List all tabs
agent-browser tab new [url]      # Open new tab
agent-browser tab 2              # Switch to tab by index (0-based)
agent-browser tab close [n]      # Close tab
```

### Cookies & Storage

```bash
agent-browser cookies                          # Get all cookies
agent-browser cookies set <name> <value>       # Set cookie
agent-browser cookies clear                    # Clear all cookies
agent-browser storage local                    # Get all localStorage
agent-browser storage local <key>              # Get specific key
agent-browser storage local set <key> <value>  # Set value
agent-browser storage local clear              # Clear localStorage
```

### Auth State Snapshots

For cases where profiles aren't suitable, save/load auth state as JSON:

```bash
agent-browser state save ./auth-state.json    # Save cookies + storage
agent-browser state load ./auth-state.json    # Restore in future session
```

### JavaScript Evaluation

```bash
agent-browser eval "document.title"                    # Simple expression
agent-browser eval -b "$(echo 'complex code' | base64)" # Base64 for shell safety
agent-browser eval --stdin <<'EOF'                     # Heredoc for multi-line
  const items = document.querySelectorAll('.item');
  return items.length;
EOF
```

### Network Interception

```bash
agent-browser network route "**/*.jpg" --abort          # Block images
agent-browser network route "**/api/v1/**" --body '{}' # Mock API response
agent-browser network unroute                           # Remove all routes
agent-browser network requests                          # View tracked requests
agent-browser network requests --filter "api"          # Filter requests
```

### Browser Settings

```bash
agent-browser set viewport 1920 1080           # Set viewport size
agent-browser set device "iPhone 14"           # Emulate device
agent-browser set media dark                   # Dark mode
agent-browser set offline on                   # Offline mode
agent-browser set credentials user pass        # HTTP basic auth
agent-browser set headers '{"X-Token":"abc"}' # Extra headers
```

### Debug

```bash
agent-browser console            # View console messages
agent-browser errors             # View page errors
agent-browser highlight <sel>    # Highlight element visually
agent-browser trace start        # Start recording trace
agent-browser trace stop ./t.zip # Stop and save trace
```

---

## Global CLI Flags

| Flag                      | Env Variable                     | Purpose                         |
| ------------------------- | -------------------------------- | ------------------------------- |
| `--profile <path>`        | `AGENT_BROWSER_PROFILE`          | Persistent browser profile      |
| `--session <name>`        | `AGENT_BROWSER_SESSION`          | Named session for parallelism   |
| `--cdp <port\|url>`       | —                                | Connect via Chrome DevTools     |
| `--headed`                | —                                | Show browser window (not headless) |
| `--executable-path <path>`| `AGENT_BROWSER_EXECUTABLE_PATH`  | Custom browser binary           |
| `--args <args>`           | `AGENT_BROWSER_ARGS`             | Browser launch args             |
| `--user-agent <ua>`       | `AGENT_BROWSER_USER_AGENT`       | Custom User-Agent               |
| `--proxy <url>`           | `AGENT_BROWSER_PROXY`            | Proxy server                    |
| `--ignore-https-errors`   | —                                | Accept self-signed certs        |
| `--allow-file-access`     | —                                | Allow file:// URLs              |
| `--extension <path>`      | `AGENT_BROWSER_EXTENSIONS`       | Load browser extension          |
| `--json`                  | —                                | JSON output                     |
| `-p <provider>`           | `AGENT_BROWSER_PROVIDER`         | Cloud browser provider          |

---

## Patterns for AI Agents

### Authenticated Multi-Page Scraping

```bash
export AGENT_BROWSER_PROFILE="$HOME/.agent-browser-profile"

# Navigate (already logged in via profile)
agent-browser open https://app.example.com/dashboard
agent-browser wait --load networkidle
agent-browser snapshot -i

# Extract data
agent-browser get text "#total-revenue"
agent-browser get text ".user-count"

# Navigate to another page
agent-browser click @e5  # "Reports" link
agent-browser wait --load networkidle
agent-browser screenshot ./reports.png
```

### Form Filling

```bash
agent-browser open https://example.com/form
agent-browser wait --load networkidle
agent-browser snapshot -i

# Fill form fields using refs from snapshot
agent-browser fill @e2 "John Doe"
agent-browser fill @e4 "john@example.com"
agent-browser select @e6 "California"
agent-browser check @e8
agent-browser click @e10  # Submit button

# Verify submission
agent-browser wait --text "Thank you"
agent-browser snapshot -i
```

### Parallel Data Collection

```bash
export AGENT_BROWSER_PROFILE="$HOME/.agent-browser-profile"

# Open multiple sites in parallel sessions
agent-browser --session s1 open https://site-a.com/data &
agent-browser --session s2 open https://site-b.com/data &
agent-browser --session s3 open https://site-c.com/data &
wait

# Collect data from each
agent-browser --session s1 get text "#result" > .agent/result-a.txt
agent-browser --session s2 get text "#result" > .agent/result-b.txt
agent-browser --session s3 get text "#result" > .agent/result-c.txt

# Clean up
agent-browser --session s1 close
agent-browser --session s2 close
agent-browser --session s3 close
```

### Waiting for Dynamic Content (SPAs)

```bash
agent-browser open https://spa-app.example.com
agent-browser wait --load networkidle

# For React/Vue/Svelte apps, wait for specific content
agent-browser wait --text "Dashboard loaded"
# or wait for a specific element
agent-browser wait "[data-testid='main-content']"
# or wait for a JS condition
agent-browser wait --fn "document.querySelector('.spinner') === null"

agent-browser snapshot -i
```

---

## Cloud Providers

For CI/CD or serverless environments where local Chrome isn't available:

```bash
# Browserbase
export AGENT_BROWSER_PROVIDER=browserbase
export BROWSERBASE_API_KEY="..."
export BROWSERBASE_PROJECT_ID="..."

# Kernel (with stealth mode and persistent profiles)
export AGENT_BROWSER_PROVIDER=kernel
export KERNEL_API_KEY="..."
export KERNEL_STEALTH=true
export KERNEL_PROFILE_NAME="my-profile"  # Cloud-persisted profile
```

---

## Troubleshooting

| Problem                    | Cause                       | Fix                                                 |
| -------------------------- | --------------------------- | --------------------------------------------------- |
| Must re-login every time   | No `--profile` set          | Set `AGENT_BROWSER_PROFILE` (see top of this doc)   |
| Refs don't work            | Page changed since snapshot | Re-run `snapshot -i` to get fresh refs              |
| Element not in snapshot    | Not interactive             | Use `-C` flag to include cursor-interactive elements |
| Page not fully loaded      | No wait after navigation    | Add `wait --load networkidle` after `open`/`click`  |
| SSL certificate error      | Self-signed cert            | Add `--ignore-https-errors`                         |
| Can't open file:// URLs    | Security restriction        | Add `--allow-file-access`                           |
| Snapshot too large          | Full tree returned          | Use `snapshot -i` or `snapshot -i -c`               |
| Session conflict            | Same session name reused    | Use unique `--session` names or close old sessions  |

---

## Installation

```bash
# macOS
brew install anthropics/tap/agent-browser

# Or via npm
npm install -g @anthropic/agent-browser

# Download Chromium (required on first use)
agent-browser install
# On Linux, also install system dependencies:
agent-browser install --with-deps
```
