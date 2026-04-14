# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║ codex.zsh - Codex helper functions                                        ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

# ───────────────────────────────────────────────────────────────────────────────
# multi-commit - Start Codex with the local multi-commit skill
# ───────────────────────────────────────────────────────────────────────────────
# Usage: multi-commit [extra guidance...]
# Example: multi-commit keep tests with implementation where possible
multi-commit() {
  if ! command -v codex >/dev/null 2>&1; then
    echo "codex is not installed" >&2
    return 1
  fi

  local prompt='$multi-commit Analyze the current uncommitted changes, propose logical commit groups, ask for confirmation before creating commits, then carry out the confirmed grouping.'

  if [[ $# -gt 0 ]]; then
    prompt="$prompt Additional user guidance: $*"
  fi

  codex "$prompt"
}
