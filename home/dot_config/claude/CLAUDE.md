## General Preferences

- For stacked PRs and advanced git workflows, use the `graphite` skill

## Code Comments

Write comments that remain valuable to future readers who have no context about
how the code evolved.

**Focus on why, not what.** The code shows what it does; comments should explain
non-obvious reasoning, constraints, or trade-offs.

```javascript
// Good: explains why
// Rate limit to 100 req/s to stay under the API's undocumented threshold
const RATE_LIMIT = 100;

// Bad: restates what the code already says
// Set rate limit to 100
const RATE_LIMIT = 100;
```

**Avoid change-relative comments.** Never write comments describing how code
changed from a previous implementation. These become meaningless or confusing
once the old implementation is forgotten.

```javascript
// Bad: anchored to forgotten past
/* Note: AddTask, CompleteTask have been removed. The system now uses
   Claude Code's native TaskCreate and TaskUpdate tools. */

// Bad: implies temporary state that will become permanent
// Temporarily disabled until the new auth system is ready

// Good: describes current behavior without referencing the past
// Delegates to Claude Code's native task management tools
```

**Keep comments evergreen.** Before writing a comment, ask: "Will this make
sense to someone reading this code in a year who never saw the previous
version?" If not, the information belongs in a commit message, PR description,
or changelog—not in code.

## Sandbox

_You are running in a sandbox._ You can read most files, but generally cannot
write (or use tools that write) outside the project root. Any scratch files,
temporary files, generated artifacts, temporary code, or other files that are
not part of the project should be written to `.agent/` inside the project root.
This directory is ignored by version control.

**ALWAYS** run commands sandboxed, or else each command will need to be approved
one by one and your work will slow to a crawl. If there are additional sandbox
permissions you need, stop and ask. If it is not possible, I will allowlist
specific bash commands for you.

## Git Commits

**ALWAYS** delegate to the `code-committer` agent for all commit operations.
Never run `git commit` directly.
