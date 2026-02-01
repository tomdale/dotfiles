## Status Updates (CRITICAL)

**MANDATORY**: When starting a new session, you **MUST** first acknowledge you
have read this instruction and intend to follow it by first saying: "I have read
and will follow the instructions for status updates."

You are required to maintain **two status variables** in iTerm2 that help the
user understand what you're working on at a glance.

### The Two Status Variables

| Variable | Purpose | Update Frequency |
|----------|---------|------------------|
| `goal` | The high-level objective for this session | When the primary goal changes |
| `task` | The specific action you're performing right now | Before every distinct action |

#### `goal` — What We're Trying to Accomplish

This is the **big-picture objective** of the session. It answers: "What is Claude
helping me with right now?"

- Set this at the **start of every session** based on the user's initial request
- Update it when the **primary goal fundamentally changes** (not for minor pivots)
- Keep it stable during routine work — don't change it for every sub-task
- Should be understandable without context (someone glancing at the status bar
  should understand what project/feature/bug you're working on)

**Good goal examples:**
- `"Implementing user authentication"`
- `"Fixing checkout page bug #1234"`
- `"Refactoring database layer"`
- `"Adding dark mode support"`
- `"Investigating memory leak"`

**Bad goal examples:**
- `"Helping user"` (too vague)
- `"Reading files"` (that's a task, not a goal)
- `"Working on code"` (not specific enough)
- `"Done"` (not descriptive)

#### `task` — What I'm Doing Right Now

This is the **specific action** you're currently performing. It answers: "What is
Claude doing at this exact moment?"

- Update this **BEFORE every distinct action** — file reads, searches, edits, etc.
- Should reflect your immediate activity
- Can be granular — this is where micro-level detail belongs
- Changes frequently as you work through steps

**Good task examples:**
- `"Reading authentication middleware"`
- `"Searching for login handlers"`
- `"Editing src/auth/login.ts"`
- `"Running test suite"`
- `"Analyzing error logs"`
- `"Planning implementation approach"`
- `"Writing migration script"`

**Bad task examples:**
- `"Implementing user authentication"` (that's a goal, not a task)
- `"Working"` (not specific)
- `"Busy"` (not descriptive)

### How to Set Status Variables

```bash
# Set the session goal (do this at session start and when goals change)
SetStatus goal "Implementing user authentication"

# Set current task (do this before every action)
SetStatus task "Reading existing auth middleware"
```

**IMPORTANT**: The `SetStatus` command uses AppleScript to communicate with
iTerm2, which requires running **outside the sandbox**. You must use
`dangerouslyDisableSandbox: true` when calling these commands via Bash.

These commands are **allowlisted** in settings.json, so they will execute without
prompting the user for permission:
- `Bash(SetStatus goal:*)`
- `Bash(SetStatus task:*)`

### When to Update Each Variable

#### Update `goal` when:
- Starting a new session (based on user's request)
- The user explicitly changes direction ("Actually, let's work on X instead")
- You complete a major objective and move to a new one
- The scope significantly expands or contracts

#### Update `task` when:
- Before reading any file(s)
- Before running any search or grep
- Before making any edit
- Before running any command
- Before invoking any skill, command, or subagent
- Before any distinct step in your work

### Complete Example Session

User asks: "Help me add a forgot password feature to the login page"

```bash
# 1. Session starts — set both
SetStatus goal "Adding forgot password feature"
SetStatus task "Reading existing login implementation"
# → Read login.tsx

SetStatus task "Searching for auth service"
# → Grep for authentication handlers

SetStatus task "Reading auth service"
# → Read auth.service.ts

SetStatus task "Planning forgot password flow"
# → Think through implementation

SetStatus task "Creating password reset endpoint"
# → Edit auth.service.ts

SetStatus task "Adding forgot password UI"
# → Edit login.tsx

SetStatus task "Writing password reset email template"
# → Create email template

SetStatus task "Running tests"
# → Execute test suite
```

If the user then says "Actually, can you also add rate limiting?", that's still
part of the same goal (forgot password feature includes rate limiting). But if
they say "Let's switch to fixing that checkout bug", then update goal:

```bash
SetStatus goal "Fixing checkout page bug"
SetStatus task "Reading bug report"
```

### Rules Summary

1. **Always set both variables at session start** — no exceptions
2. **Update `task` before EVERY action** — reading, searching, editing, running
3. **Update `goal` only for substantive goal changes** — not routine work
4. **Be specific** — vague statuses help no one
5. **Never skip status updates** — even for "quick" tasks
