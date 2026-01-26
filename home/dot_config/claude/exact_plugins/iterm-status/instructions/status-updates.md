## Status Updates (CRITICAL)

**MANDATORY**: When starting a new session, you **MUST** first acknowledge you
have read this instruction and intend to follow it by first saying: "I have read
and will follow the instructions for status updates."

You are required to maintain **two status variables** in iTerm2 that help the
user understand what you're working on at a glance.

### The Two Status Variables

| Variable | Purpose | Update Frequency |
|----------|---------|------------------|
| `sessionGoal` | The high-level objective for this session | When the primary goal changes |
| `currentTask` | The specific action you're performing right now | Before every distinct action |

#### `sessionGoal` — What We're Trying to Accomplish

This is the **big-picture objective** of the session. It answers: "What is Claude
helping me with right now?"

- Set this at the **start of every session** based on the user's initial request
- Update it when the **primary goal fundamentally changes** (not for minor pivots)
- Keep it stable during routine work — don't change it for every sub-task
- Should be understandable without context (someone glancing at the status bar
  should understand what project/feature/bug you're working on)

**Good sessionGoal examples:**
- `"Implementing user authentication"`
- `"Fixing checkout page bug #1234"`
- `"Refactoring database layer"`
- `"Adding dark mode support"`
- `"Investigating memory leak"`

**Bad sessionGoal examples:**
- `"Helping user"` (too vague)
- `"Reading files"` (that's a task, not a goal)
- `"Working on code"` (not specific enough)
- `"Done"` (not descriptive)

#### `currentTask` — What I'm Doing Right Now

This is the **specific action** you're currently performing. It answers: "What is
Claude doing at this exact moment?"

- Update this **BEFORE every distinct action** — file reads, searches, edits, etc.
- Should reflect your immediate activity
- Can be granular — this is where micro-level detail belongs
- Changes frequently as you work through steps

**Good currentTask examples:**
- `"Reading authentication middleware"`
- `"Searching for login handlers"`
- `"Editing src/auth/login.ts"`
- `"Running test suite"`
- `"Analyzing error logs"`
- `"Planning implementation approach"`
- `"Writing migration script"`

**Bad currentTask examples:**
- `"Implementing user authentication"` (that's a goal, not a task)
- `"Working"` (not specific)
- `"Busy"` (not descriptive)

### How to Set Status Variables

```bash
# Set the session goal (do this at session start and when goals change)
set-iterm-var sessionGoal "Implementing user authentication"

# Set current task (do this before every action)
set-iterm-var currentTask "Reading existing auth middleware"
```

**IMPORTANT**: The `set-iterm-var` command uses AppleScript to communicate with
iTerm2, which requires running **outside the sandbox**. You must use
`dangerouslyDisableSandbox: true` when calling these commands via Bash.

These commands are **allowlisted** in settings.json, so they will execute without
prompting the user for permission:
- `Bash(set-iterm-var sessionGoal:*)`
- `Bash(set-iterm-var currentTask:*)`

### When to Update Each Variable

#### Update `sessionGoal` when:
- Starting a new session (based on user's request)
- The user explicitly changes direction ("Actually, let's work on X instead")
- You complete a major objective and move to a new one
- The scope significantly expands or contracts

#### Update `currentTask` when:
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
set-iterm-var sessionGoal "Adding forgot password feature"
set-iterm-var currentTask "Reading existing login implementation"
# → Read login.tsx

set-iterm-var currentTask "Searching for auth service"
# → Grep for authentication handlers

set-iterm-var currentTask "Reading auth service"
# → Read auth.service.ts

set-iterm-var currentTask "Planning forgot password flow"
# → Think through implementation

set-iterm-var currentTask "Creating password reset endpoint"
# → Edit auth.service.ts

set-iterm-var currentTask "Adding forgot password UI"
# → Edit login.tsx

set-iterm-var currentTask "Writing password reset email template"
# → Create email template

set-iterm-var currentTask "Running tests"
# → Execute test suite
```

If the user then says "Actually, can you also add rate limiting?", that's still
part of the same goal (forgot password feature includes rate limiting). But if
they say "Let's switch to fixing that checkout bug", then update sessionGoal:

```bash
set-iterm-var sessionGoal "Fixing checkout page bug"
set-iterm-var currentTask "Reading bug report"
```

### Rules Summary

1. **Always set both variables at session start** — no exceptions
2. **Update `currentTask` before EVERY action** — reading, searching, editing, running
3. **Update `sessionGoal` only for substantive goal changes** — not routine work
4. **Be specific** — vague statuses help no one
5. **Never skip status updates** — even for "quick" tasks
