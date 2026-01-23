# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║ claude.zsh - Claude Code & Agent Functions                                ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

# ───────────────────────────────────────────────────────────────────────────────
# claude - Run Claude Code with project-local temp directory
# ───────────────────────────────────────────────────────────────────────────────
# Wrapper that sets TMPDIR to .agent/tmp so temp files stay in the project
# This keeps generated files organized and avoids polluting system temp
claude() {
  TMPDIR=.agent/tmp command claude "$@"
}

# ───────────────────────────────────────────────────────────────────────────────
# tasks - Display tasks from the closest .agent directory
# ───────────────────────────────────────────────────────────────────────────────
# Usage: tasks
# Finds the nearest .agent directory (walking up from current dir)
# and displays tasks.md with syntax highlighting via bat
tasks() {
  local agent_dir="$(find-closest-dir .agent)"
  if [[ $? -ne 0 ]]; then
    echo "No .agent directory found" >&2
    return 1
  fi

  local tasks_file="$agent_dir/.agent/tasks.md"
  if [[ ! -f "$tasks_file" ]]; then
    echo "No tasks.md found" >&2
    return 1
  fi

  bat "$tasks_file"
}
