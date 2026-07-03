---
name: iterm-status
description: Use when the user wants Codex to keep the current goal or current task visible inline in iTerm2, or when working in a terminal session where the iTerm2 status bar should reflect progress.
---

# iTerm Status

Use this skill when the user wants live iTerm2 status updates for the current goal and current task while Codex is working.

Prefer the MCP tool `mcp__iterm_status__set_status` for all status updates.

## Workflow

1. Call `mcp__iterm_status__set_status` with `goal` and `task` near the start of the task.
   - Keep the goal stable unless the user redirects the work.
   - Keep both fields terse and glanceable — 2-6 words, noun phrases or imperative fragments.
2. Update the current task before each meaningful step.
   - Good goal examples: `Fix checkout bug`, `Refactor status prompts`, `Add forgot password`.
   - Good task examples: `Read auth flow`, `Patch tool schema`, `Run tests`.
   - Bad examples: `I am currently reading the auth flow`, `Working on the user's request`.
3. Clear or refresh status when the work wraps up.
   - Clear the task with `task = ""`.
   - Update the goal only if the overall objective has changed.
4. If `ITERM_SESSION_ID` is empty, the tool will return a non-error indicating it could not apply the update. Continue the user task normally.
