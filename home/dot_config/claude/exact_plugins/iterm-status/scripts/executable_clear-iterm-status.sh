#!/usr/bin/env bash
# Clear the iTerm status bar when session ends (only if in iTerm)
[ -z "$ITERM_SESSION_ID" ] && exit 0
set-iterm-var currentTask "" 2>/dev/null || true
