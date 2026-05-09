#!/usr/bin/env bash
# Clear iTerm status variables on session end
[ -z "$ITERM_SESSION_ID" ] && exit 0

uuid="${ITERM_SESSION_ID#*:}"
uuid="${uuid%%:*}"
[ -z "$uuid" ] && exit 0

osascript - <<APPLESCRIPT 2>/dev/null || true
tell application "iTerm2"
  repeat with w in windows
    repeat with t in tabs of w
      repeat with s in sessions of t
        if unique ID of s is "$uuid" then
          tell s to set variable named "user.currentGoal" to ""
          tell s to set variable named "user.currentActivity" to ""
          return
        end if
      end repeat
    end repeat
  end repeat
end tell
APPLESCRIPT
