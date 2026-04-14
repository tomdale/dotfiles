---
name: iterm-status
description: Use when the user wants Codex to keep the current goal or current task visible inline in iTerm2, or when working in a terminal session where `SetStatus` should update the iTerm2 status bar during the task.
---

# iTerm Status

Use this skill when the user wants live iTerm2 status updates for the current goal and current task while Codex is working.

## Workflow

1. Check whether the session is running inside iTerm2.
   - If `ITERM_SESSION_ID` is empty, do not call `SetStatus`.
   - Continue the user task normally when not in iTerm2.
2. Set the high-level goal once near the start of the task.
   - Run `SetStatus goal "<short self-explanatory objective>"`.
   - Keep the goal stable unless the user redirects the work.
3. Update the current task before each meaningful step.
   - Run `SetStatus task "<specific action right now>"`.
   - Good examples: `Searching for failing test`, `Editing ~/.config/zsh/iterm2_user_vars.zsh`, `Running pnpm test`.
   - Bad examples: `Working`, `Thinking`, `Helping user`.
4. Clear or refresh status when the work wraps up.
   - Clear the task with `SetStatus task ""`.
   - Update the goal only if the overall objective has changed.

## Notes

- `SetStatus` updates live iTerm2 session variables and also persists `.agent/.last-goal`, `.agent/.last-task`, and `.agent/.state` in the current working directory.
- The iTerm2 status bar can read the live variables directly as `\(user.currentGoal)` and `\(user.currentActivity)`.
- In this dotfiles setup, shell integration also mirrors the persisted values into `\(user.sessionGoal)` and `\(user.sessionTask)`.
