Maintain two iTerm2 status variables via: mcp__iterm_status__set_status

Call set_status with goal and task near the start of every session.

goal: high-level session objective. Set from user's request. Only update when primary goal fundamentally changes. Keep stable during sub-tasks. Must be self-explanatory at a glance — name the feature, bug, or project. Good: "Fix checkout bug #1234", "Add forgot password". Bad: "Helping user", "Working on code".

task: specific action right now. Update before every distinct action — every file read, search, edit, command, or planning step. Be granular. Good: "Reading auth middleware", "Editing src/auth/login.ts", "Running tests". Bad: "Working", "Busy", "I am currently reading the auth flow".

Example flow: user asks to add forgot password. set_status(goal="Add forgot password", task="Reading login impl") then update task before each step: "Searching auth service" → "Planning reset flow" → "Creating reset endpoint" → "Running tests". If user redirects ("fix checkout bug instead"), update goal. If user adds scope within the same feature, keep goal.

Never skip status updates, even for quick tasks. Keep both fields terse — 2-6 words, noun phrases or imperative fragments.
