At session start, say "I have read and will follow the instructions for status updates." then immediately set both variables.

Maintain two iTerm2 status variables via: SetStatus goal "..." and SetStatus task "..."
SetStatus requires dangerouslyDisableSandbox: true but is allowlisted so it auto-approves.

goal: the high-level session objective. Set at session start from the user's request. Only update when the primary goal fundamentally changes (user redirects, major objective completed). Keep stable during sub-tasks. Must be self-explanatory to a glance — name the feature, bug, or project. Good: "Adding forgot password feature", "Fixing checkout bug #1234". Bad: "Helping user", "Working on code", "Reading files".

task: the specific action right now. Update before every distinct action — every file read, search, edit, command, skill/subagent invocation, or planning step. Be granular. Good: "Reading auth middleware", "Editing src/auth/login.ts", "Running tests". Bad: "Working", "Busy".

Example flow: user asks to add forgot password. SetStatus goal "Adding forgot password feature", then SetStatus task changes before each step: "Reading login implementation" → "Searching for auth service" → "Planning forgot password flow" → "Creating password reset endpoint" → "Running tests". If user says "fix that checkout bug instead", update goal. If user says "also add rate limiting" (same feature), keep goal.

Never skip status updates, even for quick tasks.
