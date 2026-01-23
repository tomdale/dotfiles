# iTerm2 custom user variables
# Must be sourced before iTerm2 shell integration

function iterm2_print_user_vars() {
  iterm2_set_user_var gitBranch $((git branch 2> /dev/null) | grep \* | cut -c3-)
  iterm2_set_user_var repoDir $(basename $(git rev-parse --show-toplevel 2> /dev/null) 2> /dev/null)

  # Restore sessionGoal from .agent/.last-goal if it exists
  if [[ -f ".agent/.last-goal" ]]; then
    iterm2_set_user_var sessionGoal "$(cat .agent/.last-goal)"
  else
    iterm2_set_user_var sessionGoal ""
  fi

  # Determine session title
  local session_title=""
  local current_dir="$(pwd)"

  # Check for *.code-workspace file in current dir or ancestors
  while [[ "$current_dir" != "/" ]]; do
    for workspace_file in "$current_dir"/*.code-workspace(N); do
      if [[ -f "$workspace_file" ]]; then
        session_title="$(basename "$workspace_file")"
        break 2
      fi
    done
    current_dir="$(dirname "$current_dir")"
  done

  # If no workspace file found, check if in git repo
  if [[ -z "$session_title" ]]; then
    local git_root=$(git rev-parse --show-toplevel 2>/dev/null)
    if [[ -n "$git_root" ]]; then
      session_title="$(basename "$git_root")"
    else
      # Use path relative to home
      local home_dir="$HOME"
      if [[ "$(pwd)" == "$home_dir"* ]]; then
        session_title="${PWD#$home_dir/}"
        if [[ "$session_title" == "$PWD" ]]; then
          session_title="~"
        else
          session_title="~/$session_title"
        fi
      else
        session_title="$(pwd)"
      fi
    fi
  fi

  iterm2_set_user_var sessionTitle "$session_title"
}
