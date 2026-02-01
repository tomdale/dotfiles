---
name: vercel-sandbox
description: Run code in isolated Vercel Sandbox microVMs. Use when the user wants to run untrusted code, execute AI-generated code safely, test in isolated environments, run development servers, or mentions Vercel Sandbox, microVM, ephemeral compute, or sandboxed execution.
allowed-tools:
  - Bash(sandbox:*)
  - Bash(npx @vercel/sandbox:*)
---

# Vercel Sandbox

Vercel Sandbox provides ephemeral Linux microVMs for safely running untrusted or AI-generated code. Each sandbox is an isolated Firecracker microVM with sudo access, network connectivity, and support for Node.js and Python runtimes.

## Core Concepts

### What is a Sandbox?

- **Isolated microVM**: Each sandbox is a separate Linux environment (Amazon Linux 2023)
- **Ephemeral**: Sandboxes are temporary and automatically cleaned up
- **Secure**: Run untrusted code without affecting your system
- **Full Linux**: Install packages with `dnf`, use `sudo`, expose network ports

### Resource Limits

| Resource | Limit |
|----------|-------|
| vCPUs | Up to 8 |
| Memory | 2 GB per vCPU |
| Timeout (Hobby) | 45 minutes max |
| Timeout (Pro/Enterprise) | 5 hours max |
| Exposed ports | Up to 4 |

### Available Runtimes

| Runtime | Package Managers | Default |
|---------|-----------------|---------|
| `node24` | npm, pnpm | Yes |
| `node22` | npm, pnpm | No |
| `python3.13` | pip, uv | No |

## Quick Start

### CLI (Interactive)

```bash
# Install CLI
npm install -g sandbox

# Login
sandbox login

# Create and shell into a sandbox
sandbox sh

# Run a command and cleanup
sandbox run --rm -- node --version

# Create sandbox with port forwarding
sandbox create --publish-port 3000
```

### SDK (Programmatic)

```typescript
import { Sandbox } from '@vercel/sandbox';

// Create sandbox
const sandbox = await Sandbox.create({
  runtime: 'node24',
  timeout: 300000,  // 5 minutes
  ports: [3000],
});

// Run commands
const result = await sandbox.runCommand('node', ['--version']);
console.log(await result.stdout());  // v24.x.x

// Write files
await sandbox.writeFiles([
  { path: 'hello.js', content: Buffer.from('console.log("Hello!")') }
]);

// Get preview URL
const url = sandbox.domain(3000);

// Cleanup
await sandbox.stop();
```

## Authentication

### Using OIDC (Recommended)

```bash
# Pull local dev token
vercel env pull
```

The SDK automatically uses `VERCEL_OIDC_TOKEN` when available.

### Using Access Token

```typescript
const sandbox = await Sandbox.create({
  teamId: process.env.VERCEL_TEAM_ID,
  projectId: process.env.VERCEL_PROJECT_ID,
  token: process.env.VERCEL_TOKEN,
});
```

## Common Workflows

### Run AI-Generated Code Safely

```typescript
const sandbox = await Sandbox.create({ runtime: 'node24' });
await sandbox.writeFiles([
  { path: 'script.js', content: Buffer.from(aiGeneratedCode) }
]);
const result = await sandbox.runCommand('node', ['script.js']);
const output = await result.stdout();
await sandbox.stop();
```

### Start a Dev Server

```typescript
const sandbox = await Sandbox.create({
  runtime: 'node24',
  ports: [3000],
  source: {
    type: 'git',
    url: 'https://github.com/user/repo.git',
  },
});

// Start server (detached)
const cmd = await sandbox.runCommand({
  cmd: 'npm',
  args: ['run', 'dev'],
  detached: true,
});

// Get preview URL
console.log(sandbox.domain(3000));
```

### Install System Packages

```typescript
await sandbox.runCommand({
  cmd: 'dnf',
  args: ['install', '-y', 'golang'],
  sudo: true,
});
```

### Create Snapshots for Fast Starts

```typescript
// Setup sandbox with dependencies
const sandbox = await Sandbox.create({ runtime: 'node24' });
await sandbox.runCommand('npm', ['install', 'typescript', 'esbuild']);

// Snapshot (stops the sandbox)
const snapshot = await sandbox.snapshot();
console.log(snapshot.snapshotId);

// Later: create from snapshot
const newSandbox = await Sandbox.create({
  source: { type: 'snapshot', snapshotId: snapshot.snapshotId },
});
```

## Detailed Documentation

- **[SDK Reference](sdk-reference.md)** - Full SDK API including Sandbox, Command, and Snapshot classes
- **[CLI Reference](cli-reference.md)** - All CLI commands, options, and examples
