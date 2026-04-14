---
name: iterm-status
description: Use when the user wants Codex to keep the current goal or current task visible inline in iTerm2, or when working in a terminal session where `SetStatus` should update the iTerm2 status bar during the task.
---

# iTerm Status

Use this skill when the user wants live iTerm2 status updates for the current goal and current task while Codex is working.

In this setup, Codex should prefer the `mcp__tomdale_status__set_status` tool
when it is available. The shell `SetStatus` command remains a manual fallback.

## Workflow

1. Prefer the MCP tool for automatic updates.
   - Call `mcp__tomdale_status__set_status` with `goal` and `task` near the start of the task.
   - Keep the goal stable unless the user redirects the work.
2. Update the current task before each meaningful step.
   - Call `mcp__tomdale_status__set_status` with `task`.
   - Good examples: `Searching for failing test`, `Editing ~/.config/zsh/iterm2_user_vars.zsh`, `Running pnpm test`.
   - Bad examples: `Working`, `Thinking`, `Helping user`.
3. Clear or refresh status when the work wraps up.
   - Clear the task with `task = ""`.
   - Update the goal only if the overall objective has changed.
4. Fall back to `SetStatus` only when using the tool is impossible.
   - If `ITERM_SESSION_ID` is empty, do not call `SetStatus`.
   - Continue the user task normally when not in iTerm2.

## Notes

- The MCP tool updates the live iTerm2 variables `\(user.currentGoal)` and `\(user.currentActivity)` directly.
- The shell `SetStatus` script also persists `.agent/.last-goal`, `.agent/.last-task`, and `.agent/.state`, but the automatic Codex path does not depend on those files.
