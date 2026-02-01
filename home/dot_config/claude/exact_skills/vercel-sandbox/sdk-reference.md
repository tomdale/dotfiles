# SDK Reference

The `@vercel/sandbox` SDK provides programmatic control over Vercel Sandbox microVMs.

## Installation

```bash
npm install @vercel/sandbox
# or
pnpm add @vercel/sandbox
```

## Sandbox Class

### Static Methods

#### `Sandbox.create(options?)`

Create a new sandbox microVM.

```typescript
const sandbox = await Sandbox.create({
  runtime: 'node24',           // 'node24' | 'node22' | 'python3.13'
  timeout: 300000,             // milliseconds (default: 5 min)
  ports: [3000, 8080],         // up to 4 ports
  resources: { vcpus: 4 },     // 1-8 vCPUs
  source: {                    // optional
    type: 'git',
    url: 'https://github.com/user/repo.git',
    depth: 1,                  // shallow clone
    revision: 'main',          // branch/tag/commit
    username: 'user',          // for private repos
    password: 'token',
  },
  // Auth (if VERCEL_OIDC_TOKEN unavailable)
  teamId: process.env.VERCEL_TEAM_ID,
  projectId: process.env.VERCEL_PROJECT_ID,
  token: process.env.VERCEL_TOKEN,
  signal: abortController.signal,  // optional AbortSignal
});
```

**Source Types:**
- `git`: Clone a repository
- `tarball`: Extract from URL (`{ type: 'tarball', url: '...' }`)
- `snapshot`: Create from snapshot (`{ type: 'snapshot', snapshotId: '...' }`)

#### `Sandbox.get(options)`

Reconnect to an existing sandbox.

```typescript
const sandbox = await Sandbox.get({ sandboxId: 'sb_abc123' });
```

#### `Sandbox.list(options?)`

List sandboxes for a project.

```typescript
const { json } = await Sandbox.list({
  projectId: 'prj_abc123',
  limit: 50,
  since: new Date('2024-01-01'),
  until: new Date(),
});
for (const sb of json.sandboxes) {
  console.log(sb.sandboxId, sb.status);
}
```

### Instance Properties

| Property | Type | Description |
|----------|------|-------------|
| `sandboxId` | `string` | Unique sandbox identifier |
| `status` | `string` | `"pending" \| "running" \| "stopping" \| "stopped" \| "failed"` |
| `timeout` | `number` | Milliseconds remaining before auto-stop |
| `createdAt` | `Date` | Creation timestamp |

### Instance Methods

#### `sandbox.runCommand(cmd, args?, opts?)`

Execute a command. Blocks until completion by default.

```typescript
// Simple usage
const result = await sandbox.runCommand('node', ['--version']);
console.log(result.exitCode);       // 0
console.log(await result.stdout()); // v24.x.x

// Object syntax with options
const result = await sandbox.runCommand({
  cmd: 'npm',
  args: ['install'],
  cwd: '/vercel/sandbox/app',
  env: { NODE_ENV: 'production' },
  sudo: true,
  stdout: process.stdout,  // stream output
  stderr: process.stderr,
});
```

**Detached Mode** - Returns immediately for long-running processes:

```typescript
const cmd = await sandbox.runCommand({
  cmd: 'npm',
  args: ['run', 'dev'],
  detached: true,
});

// Stream logs
for await (const log of cmd.logs()) {
  process.stdout.write(log.data);
}

// Wait for completion
const result = await cmd.wait();

// Or kill it
await cmd.kill('SIGTERM');
```

#### `sandbox.writeFiles(files)`

Upload files to the sandbox.

```typescript
await sandbox.writeFiles([
  { path: 'index.js', content: Buffer.from('console.log("hi")') },
  { path: 'data/config.json', content: Buffer.from('{"key": "value"}') },
]);
```

#### `sandbox.readFile(file)` / `sandbox.readFileToBuffer(file)`

Read file contents from sandbox.

```typescript
// As ReadableStream
const stream = await sandbox.readFile({ path: 'output.txt' });

// As Buffer
const buffer = await sandbox.readFileToBuffer({ path: 'output.txt' });
const content = buffer?.toString() ?? '';
```

#### `sandbox.downloadFile(src, dst)`

Download file from sandbox to local filesystem.

```typescript
const localPath = await sandbox.downloadFile(
  { path: 'build/output.tar.gz' },
  { path: '/tmp/output.tar.gz', mkdirRecursive: true }
);
```

#### `sandbox.mkDir(path)`

Create directories.

```typescript
await sandbox.mkDir('tmp/artifacts');
```

#### `sandbox.domain(port)`

Get public URL for an exposed port.

```typescript
const sandbox = await Sandbox.create({ ports: [3000] });
// ... start server on port 3000
const url = sandbox.domain(3000);
// https://sb_abc123-3000.vercel.app
```

#### `sandbox.extendTimeout(ms)`

Extend sandbox lifetime.

```typescript
await sandbox.extendTimeout(60000); // +60 seconds
```

#### `sandbox.snapshot()`

Save sandbox state (stops the sandbox).

```typescript
const snapshot = await sandbox.snapshot();
console.log(snapshot.snapshotId);

// Create new sandbox from snapshot
const newSandbox = await Sandbox.create({
  source: { type: 'snapshot', snapshotId: snapshot.snapshotId },
});
```

Note: Snapshots expire after 7 days.

#### `sandbox.stop()`

Terminate the sandbox.

```typescript
await sandbox.stop();
```

#### `sandbox.getCommand(cmdId)`

Retrieve a command by ID (useful for detached commands).

```typescript
const cmd = await sandbox.getCommand('cmd_abc123');
```

## Command Class

Represents a running or completed command.

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `cmdId` | `string` | Command identifier |
| `cwd` | `string` | Working directory |
| `startedAt` | `number` | Unix timestamp (ms) |
| `exitCode` | `number \| null` | Exit code (null if running) |

### Methods

#### `command.logs()`

Stream structured log output.

```typescript
for await (const log of command.logs()) {
  if (log.stream === 'stdout') {
    process.stdout.write(log.data);
  } else {
    process.stderr.write(log.data);
  }
}
```

#### `command.wait()`

Block until command completes (for detached commands).

```typescript
const result = await command.wait();
console.log(result.exitCode);
```

#### `command.stdout()` / `command.stderr()` / `command.output(stream)`

Get output as string.

```typescript
const stdout = await command.stdout();
const stderr = await command.stderr();
const both = await command.output('both');
```

#### `command.kill(signal?)`

Terminate the command.

```typescript
await command.kill('SIGTERM');  // graceful
await command.kill('SIGKILL');  // immediate
```

## Snapshot Class

### Static Methods

#### `Snapshot.list(options?)`

List snapshots.

```typescript
const { json } = await Snapshot.list({ projectId: 'prj_abc123' });
```

#### `Snapshot.get(options)`

Retrieve a snapshot.

```typescript
const snapshot = await Snapshot.get({ snapshotId: 'snap_abc123' });
```

### Instance Properties

| Property | Type | Description |
|----------|------|-------------|
| `snapshotId` | `string` | Snapshot identifier |
| `sourceSandboxId` | `string` | Source sandbox ID |
| `status` | `string` | `"created" \| "deleted" \| "failed"` |

### Instance Methods

#### `snapshot.delete()`

Delete a snapshot.

```typescript
await snapshot.delete();
```

## Error Handling

```typescript
try {
  const sandbox = await Sandbox.create({ runtime: 'node24' });
  const result = await sandbox.runCommand('exit', ['1']);

  if (result.exitCode !== 0) {
    console.error('Command failed:', await result.stderr());
  }
} catch (error) {
  console.error('Sandbox error:', error);
} finally {
  await sandbox?.stop();
}
```

## Environment Defaults

- **Working directory**: `/vercel/sandbox`
- **User**: `vercel-sandbox`
- **Sudo**: Available, runs as root with preserved PATH
- **Base system**: Amazon Linux 2023

## Common Patterns

### Run Python Script

```typescript
const sandbox = await Sandbox.create({ runtime: 'python3.13' });
await sandbox.writeFiles([
  { path: 'script.py', content: Buffer.from('print("Hello from Python!")') }
]);
const result = await sandbox.runCommand('python3', ['script.py']);
```

### Install and Run Go

```typescript
const sandbox = await Sandbox.create({ runtime: 'node24' });
await sandbox.runCommand({ cmd: 'dnf', args: ['install', '-y', 'golang'], sudo: true });
await sandbox.writeFiles([
  { path: 'main.go', content: Buffer.from('package main\n\nimport "fmt"\n\nfunc main() {\n\tfmt.Println("Hello Go!")\n}') }
]);
await sandbox.runCommand('go', ['run', 'main.go']);
```

### Clone and Build Private Repo

```typescript
const sandbox = await Sandbox.create({
  runtime: 'node24',
  source: {
    type: 'git',
    url: 'https://github.com/org/private-repo.git',
    username: 'x-access-token',
    password: process.env.GITHUB_TOKEN,
  },
});
await sandbox.runCommand('npm', ['install']);
await sandbox.runCommand('npm', ['run', 'build']);
```
