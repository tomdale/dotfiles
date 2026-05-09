#!/usr/bin/env bash
# Only emit status update instructions if running in iTerm2
[ -z "$ITERM_SESSION_ID" ] && exit 0
cat "$HOME/.local/share/mcp/status-instructions.md"
