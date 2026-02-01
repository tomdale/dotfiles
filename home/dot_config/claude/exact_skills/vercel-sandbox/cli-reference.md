# CLI Reference

The `sandbox` CLI provides Docker-like commands for managing Vercel Sandbox microVMs.

## Installation

```bash
npm install -g sandbox
# or
pnpm add -g sandbox
```

## Authentication

```bash
sandbox login   # Authenticate with Vercel
sandbox logout  # Clear credentials
```

## Command Reference

### `sandbox create`

Create a new sandbox.

```bash
sandbox create [OPTIONS]
```

| Option | Description | Default |
|--------|-------------|---------|
| `--runtime <runtime>` | `node24`, `node22`, or `python3.13` | `node24` |
| `--timeout <duration>` | Auto-stop duration (e.g., `5m`, `1h`) | `5m` |
| `--publish-port <port>`, `-p` | Expose a port via public URL | - |
| `--project <project>` | Vercel project name or ID | - |
| `--scope <team>`, `--team` | Vercel team | - |
| `--silent` | Suppress sandbox ID output | - |

```bash
# Basic sandbox
sandbox create

# Python sandbox with 30-minute timeout
sandbox create --runtime python3.13 --timeout 30m

# Node.js with port exposure
sandbox create --runtime node24 --publish-port 3000 --publish-port 8080
```

### `sandbox run`

Create sandbox, run command, optionally cleanup.

```bash
sandbox run [OPTIONS] <command> [...args]
```

| Option | Description |
|--------|-------------|
| `--runtime <runtime>` | Runtime image |
| `--timeout <duration>` | Auto-stop duration |
| `--publish-port <port>`, `-p` | Expose port |
| `--workdir <dir>`, `-w` | Working directory |
| `--env <key=value>`, `-e` | Environment variable |
| `--sudo` | Run as root |
| `--interactive`, `-i` | Interactive mode |
| `--tty`, `-t` | Allocate TTY |
| `--rm` | Remove sandbox after completion |

```bash
# Run Node.js script and cleanup
sandbox run --rm -- node --version

# Run with environment variables
sandbox run --env NODE_ENV=production -- npm test

# Interactive Python session
sandbox run --runtime python3.13 --interactive --tty -- python3

# Start dev server with port
sandbox run -p 3000 -i -t -- npm run dev
```

### `sandbox sh`

Create sandbox with interactive shell.

```bash
sandbox sh [OPTIONS]
```

Same options as `sandbox run`, plus:

| Option | Description |
|--------|-------------|
| `--no-extend-timeout` | Don't extend timeout during interaction |

```bash
# Basic shell
sandbox sh

# Python shell
sandbox sh --runtime python3.13

# With specific working directory
sandbox sh --workdir /app
```

### `sandbox exec`

Execute command in existing sandbox.

```bash
sandbox exec [OPTIONS] <sandbox_id> <command> [...args]
```

| Option | Description |
|--------|-------------|
| `--workdir <dir>`, `-w` | Working directory |
| `--env <key=value>`, `-e` | Environment variable |
| `--sudo` | Run as root |
| `--interactive`, `-i` | Interactive mode |
| `--tty`, `-t` | Allocate TTY |

```bash
# Check Node version in running sandbox
sandbox exec sb_abc123 node --version

# Install packages with sudo
sandbox exec --sudo sb_abc123 dnf install -y golang

# Interactive shell in sandbox
sandbox exec -i -t sb_abc123 bash
```

### `sandbox ssh`

Interactive shell in existing sandbox.

```bash
sandbox ssh [OPTIONS] <sandbox_id>
```

| Option | Description |
|--------|-------------|
| `--workdir <dir>`, `-w` | Working directory |
| `--env <key=value>`, `-e` | Environment variable |
| `--sudo` | Run as root |
| `--no-extend-timeout` | Don't extend timeout |

```bash
sandbox ssh sb_abc123
sandbox ssh --sudo sb_abc123
```

### `sandbox list`

List sandboxes.

```bash
sandbox list [OPTIONS]
# Alias: sandbox ls
```

| Option | Description |
|--------|-------------|
| `--all`, `-a` | Include stopped sandboxes |
| `--project <project>` | Filter by project |

```bash
sandbox list
sandbox list --all
sandbox list --project my-app
```

### `sandbox stop`

Stop one or more sandboxes.

```bash
sandbox stop <sandbox_id> [...sandbox_id]
# Aliases: sandbox rm, sandbox remove
```

```bash
sandbox stop sb_abc123
sandbox stop sb_abc123 sb_def456 sb_ghi789
```

### `sandbox copy`

Copy files between local and sandbox.

```bash
sandbox copy <src> <dst>
# Alias: sandbox cp
```

Use `sandbox_id:path` syntax for sandbox paths:

```bash
# Local to sandbox
sandbox copy ./script.js sb_abc123:/vercel/sandbox/script.js

# Sandbox to local
sandbox copy sb_abc123:/vercel/sandbox/output.log ./output.log

# Copy directory
sandbox copy sb_abc123:/vercel/sandbox/dist/ ./build/
```

### `sandbox snapshot`

Capture sandbox state (stops the sandbox).

```bash
sandbox snapshot [OPTIONS] <sandbox_id>
```

| Option | Description |
|--------|-------------|
| `--stop` | Confirm sandbox will stop (required) |
| `--silent` | Suppress snapshot ID output |

```bash
sandbox snapshot --stop sb_abc123
```

### `sandbox snapshots list`

List snapshots.

```bash
sandbox snapshots list [OPTIONS]
# Alias: sandbox snapshots ls
```

```bash
sandbox snapshots list
sandbox snapshots list --project my-app
```

### `sandbox snapshots delete`

Delete snapshots.

```bash
sandbox snapshots delete <snapshot_id> [...snapshot_id]
# Aliases: sandbox snapshots rm, sandbox snapshots remove
```

```bash
sandbox snapshots delete snap_abc123
sandbox snapshots delete snap_abc123 snap_def456
```

## Common Workflows

### Quick Test Environment

```bash
# Create, test, cleanup
sandbox run --rm --runtime node24 -- node -e "console.log('Hello!')"
```

### Development Server

```bash
# Create with port
sandbox create --runtime node24 -p 3000

# Clone code (use exec or ssh)
sandbox ssh sb_abc123
# Inside: git clone <repo>; cd repo; npm install; npm run dev

# Get URL from dashboard or use domain pattern
```

### Setup Environment and Snapshot

```bash
# Create and setup
sandbox sh --runtime node24
# Inside: npm install -g typescript tsx prettier eslint
# Inside: exit

# Snapshot
sandbox snapshot --stop sb_abc123

# Later, create from snapshot (via SDK)
```

### Debug Production Issue

```bash
# Create sandbox with same runtime
sandbox create --runtime node22

# Copy production code
sandbox copy ./prod-bundle sb_abc123:/vercel/sandbox/

# SSH and debug
sandbox ssh sb_abc123
```

## Global Options

All commands support:

| Option | Description |
|--------|-------------|
| `--token <token>` | Vercel auth token (or use `sandbox login`) |
| `--project <project>` | Vercel project name or ID |
| `--scope <team>`, `--team` | Vercel team |
| `--help`, `-h` | Show help |

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| Non-zero | Command inside sandbox failed (matches command exit code) |

## Tips

1. **Use `--rm` for one-off commands** - Automatically cleans up the sandbox
2. **Use `--silent` in scripts** - Suppress output, use exit codes for control flow
3. **Combine `-i -t`** - For interactive sessions that need TTY (vim, top, etc.)
4. **Use snapshots for setup** - Pre-install dependencies, snapshot, then create fast sandboxes
