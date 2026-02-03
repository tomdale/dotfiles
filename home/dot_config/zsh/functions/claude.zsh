# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║ claude.zsh - Claude Code & Agent Functions                                ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

# ───────────────────────────────────────────────────────────────────────────────
# commit - Quick wrapper for Claude's /commit skill
# ───────────────────────────────────────────────────────────────────────────────
# Usage: commit [args...]
# Passes all arguments to the /commit skill
# Example: commit -m "Add new feature"
commit() {
  claude "/commit $*"
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
