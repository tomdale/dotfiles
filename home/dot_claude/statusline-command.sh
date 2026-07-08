#!/bin/bash
# Claude Code status line: <dir basename> (<git branch>) · <model> · <context used%>
input=$(cat)
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
model=$(echo "$input" | jq -r '.model.display_name')
dir_name=$(basename "$cwd")
# used_percentage is pre-calculated by Claude Code (0-100); null until the first API response
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

branch=""
if git -C "$cwd" --no-optional-locks rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git -C "$cwd" --no-optional-locks branch --show-current 2>/dev/null)
fi

out=$(printf "\033[36m%s\033[0m" "$dir_name")

if [ -n "$branch" ]; then
  out="$out $(printf "\033[33m(%s)\033[0m" "$branch")"
fi

out="$out $(printf "\033[2m· %s\033[0m" "$model")"

if [ -n "$used_pct" ]; then
  out="$out $(printf "\033[2m· %.0f%% ctx\033[0m" "$used_pct")"
fi

printf "%s" "$out"
