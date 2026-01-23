# Claude/agent-related functions

# Run claude with custom TMPDIR
claude() {
  TMPDIR=.agent/tmp command claude "$@"
}

# Display tasks.md from the closest .agent directory
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
