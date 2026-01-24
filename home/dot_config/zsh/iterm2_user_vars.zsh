# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║ iterm2_user_vars.zsh - iTerm2 Status Bar Variables                        ║
# ╠═══════════════════════════════════════════════════════════════════════════╣
# ║ Defines custom variables for the iTerm2 status bar. The function below    ║
# ║ is called by iTerm2's shell integration before each prompt, updating      ║
# ║ variables that appear in status bar "Interpolated String" components.     ║
# ║                                                                           ║
# ║ To use these in iTerm2: Preferences → Profiles → Session → Status bar     ║
# ║ Add an "Interpolated String" component with \(user.variableName) syntax.  ║
# ║                                                                           ║
# ║ Must be sourced BEFORE the iTerm2 shell integration script.               ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

function iterm2_print_user_vars() {
  # ─────────────────────────────────────────────────────────────────────────────
  # Git Information
  # ─────────────────────────────────────────────────────────────────────────────
  # gitBranch: Current branch name (empty if not in repo)
  iterm2_set_user_var gitBranch $((git branch 2> /dev/null) | grep \* | cut -c3-)

  # repoDir: Repository root directory name (for quick identification)
  iterm2_set_user_var repoDir $(basename $(git rev-parse --show-toplevel 2> /dev/null) 2> /dev/null)

  # ─────────────────────────────────────────────────────────────────────────────
  # Claude Code Integration
  # ─────────────────────────────────────────────────────────────────────────────
  # sessionGoal: Persisted goal from Claude Code sessions
  # Stored in .agent/.last-goal by the iterm-status plugin
  if [[ -f ".agent/.last-goal" ]]; then
    iterm2_set_user_var sessionGoal "$(cat .agent/.last-goal)"
  else
    iterm2_set_user_var sessionGoal ""
  fi

  # ─────────────────────────────────────────────────────────────────────────────
  # Session Title (smart directory/project name)
  # Priority: 1. VS Code workspace name, 2. Git repo name, 3. Path from home
  # ─────────────────────────────────────────────────────────────────────────────
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

  # Fallback to git repo name or relative path
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
