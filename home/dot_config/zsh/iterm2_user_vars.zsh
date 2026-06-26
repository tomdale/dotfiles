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
  local git_root=""
  local git_branch=""
  if (( $+functions[__tomdale_git_prompt_info] )) && __tomdale_git_prompt_info; then
    git_root="$__TOMDALE_GIT_PROMPT_ROOT"
    git_branch="$__TOMDALE_GIT_PROMPT_BRANCH"
    [[ $git_branch == "(detached)" ]] && git_branch="${__TOMDALE_GIT_PROMPT_COMMIT[1,7]}"
  fi

  # gitBranch: Current branch name (empty if not in repo)
  iterm2_set_user_var gitBranch "$git_branch"

  # repoDir: Repository root directory name (for quick identification)
  iterm2_set_user_var repoDir "${git_root:t}"

  # ─────────────────────────────────────────────────────────────────────────────
  # Claude Code Integration
  # ─────────────────────────────────────────────────────────────────────────────
  # sessionGoal/sessionTask: Persisted goal + task from agent sessions
  # Stored in .agent/.last-goal and .agent/.last-task by SetStatus
  if [[ -f ".agent/.last-goal" ]]; then
    iterm2_set_user_var sessionGoal "$(<.agent/.last-goal)"
  else
    iterm2_set_user_var sessionGoal ""
  fi

  if [[ -f ".agent/.last-task" ]]; then
    iterm2_set_user_var sessionTask "$(<.agent/.last-task)"
  else
    iterm2_set_user_var sessionTask ""
  fi

  # ─────────────────────────────────────────────────────────────────────────────
  # Session Title (smart directory/project name)
  # Priority: 1. VS Code workspace name, 2. Git repo name, 3. Path from home
  # ─────────────────────────────────────────────────────────────────────────────
  local session_title=""
  local current_dir="$PWD"

  # Check for *.code-workspace file in current dir or ancestors
  while [[ "$current_dir" != "/" ]]; do
    for workspace_file in "$current_dir"/*.code-workspace(N); do
      if [[ -f "$workspace_file" ]]; then
        session_title="${workspace_file:t}"
        break 2
      fi
    done
    current_dir="${current_dir:h}"
  done

  # Fallback to git repo name or relative path
  if [[ -z "$session_title" ]]; then
    if [[ -n "$git_root" ]]; then
      session_title="${git_root:t}"
    else
      # Use path relative to home
      local home_dir="$HOME"
      if [[ "$PWD" == "$home_dir"* ]]; then
        session_title="${PWD#$home_dir/}"
        if [[ "$session_title" == "$PWD" ]]; then
          session_title="~"
        else
          session_title="~/$session_title"
        fi
      else
        session_title="$PWD"
      fi
    fi
  fi

  iterm2_set_user_var sessionTitle "$session_title"
}
