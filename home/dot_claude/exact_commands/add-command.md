---
allowed-tools: Write, Bash(mkdir:*)
description: Interactively create a new slash command
argument-hint: [command-name] [description...]
context: fork
---

# Create New Slash Command

You are helping the user create a new Claude Code slash command.

## Arguments
- Command name: `$1` (required)
- Description: `$ARGUMENTS` (what the command should do)

Add `--project` anywhere in arguments to create in `.claude/commands/` instead of personal.

## Your Task

### Step 1: Validate Arguments

If `$1` is empty, ask the user for a command name. Command names must:
- Use lowercase letters, numbers, and hyphens only
- Be max 64 characters
- Not conflict with built-in commands (`clear`, `compact`, `help`, `model`, etc.)

For namespaced commands (e.g., `db:migrate`), the part before `:` becomes a subdirectory.

### Step 2: Understand Requirements

The user provided this description: **$ARGUMENTS** (minus the command name)

Based on their description, determine:
1. What tools are needed (`allowed-tools`)
2. What arguments the command accepts (`argument-hint`)
3. Whether it needs isolation (`context: fork`)
4. Whether Claude should auto-invoke it (`disable-model-invocation`)

If the description is missing or unclear, ask clarifying questions.

### Step 3: Write the Command File

Determine the file path:
- Personal (default): `~/.config/claude/commands/<name>.md`
- Project (if `--project` flag): `.claude/commands/<name>.md`
- Namespaced: Split on `:` → `<dir>/<name>.md` (e.g., `db:migrate` → `db/migrate.md`)

Create the directory if needed, then write the `.md` file with proper frontmatter.

### Step 4: Output Documentation

After creating the file, output:

```
Created /<command-name> command

Location: <full-path>

Usage:
  /<command-name> [args]

Description: <description>

Example:
  /<command-name> <example-args>
```

---

## Reference: Frontmatter Options

| Field | Example | Purpose |
|-------|---------|---------|
| `allowed-tools` | `Bash(git:*), Read, WebFetch` | Tools the command can use |
| `argument-hint` | `[file] [options?]` | Shows in autocomplete (`?` = optional) |
| `description` | `Review code for issues` | Shown in `/help`, enables Skill tool invocation |
| `model` | `claude-3-5-haiku-20241022` | Override model for this command |
| `context` | `fork` | Run in isolated sub-agent context |
| `agent` | `general-purpose` | Agent type when forked |
| `disable-model-invocation` | `true` | Prevent Skill tool from auto-calling |

## Reference: Common Tools

- `Read` - Read file contents
- `Write` - Create/overwrite files
- `Edit` - Edit existing files
- `Glob` - Find files by pattern
- `Grep` - Search file contents
- `Bash(cmd:*)` - Run bash commands (e.g., `Bash(git:*)`, `Bash(npm:*)`)
- `WebFetch` - Fetch URLs (required for network access in sandbox)
- `WebSearch` - Search the web
- `Task` - Launch sub-agents

## Reference: Variables & Dynamic Content

**Placeholders:**
- `$ARGUMENTS` - All arguments as single string
- `$1`, `$2`, `$3`... - Individual positional arguments

**Bash injection** (requires matching `allowed-tools`):
```
Current branch: !`git branch --show-current`
```

**File references:**
```
Review the code in @src/utils/auth.js
```

## Reference: Best Practices

1. **Single purpose** - Each command does one thing well
2. **Document arguments** - Use `argument-hint` with `?` for optional args
3. **Minimal tools** - Only include tools actually needed
4. **Clear instructions** - Write prompts Claude can follow unambiguously
5. **Use `context: fork`** - For multi-step workflows that clutter context
6. **Add `description`** - Makes command discoverable in `/help`

## Reference: Example Commands

### Simple (no frontmatter)
```markdown
Review the code in $ARGUMENTS for bugs, security issues, and style problems.
Focus on correctness over style nitpicks.
```

### With Arguments
```yaml
---
description: Fix a GitHub issue
argument-hint: [issue-number]
---

Fix GitHub issue #$1. Read the issue, understand the problem, implement a fix,
and create a commit with a message referencing the issue.
```

### With Bash Context
```yaml
---
allowed-tools: Bash(git:*), Bash(gh:*)
description: Create a well-crafted git commit
---

Current status: !`git status --short`
Staged changes: !`git diff --cached`
Recent commits: !`git log --oneline -5`

Create a commit for the staged changes. Follow conventional commits format.
```

### Complex Workflow
```yaml
---
description: Deploy to staging with validation
context: fork
allowed-tools: Bash(npm:*), Bash(git:*), WebFetch
disable-model-invocation: true
---

Deploy the current branch to staging:
1. Run tests
2. Build the project
3. Deploy to staging
4. Verify deployment health
```
