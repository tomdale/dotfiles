# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║ codex.zsh - Codex helper functions                                        ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

# ───────────────────────────────────────────────────────────────────────────────
# codex - Run Codex with defensive terminal-mode cleanup
# ───────────────────────────────────────────────────────────────────────────────
__codex_reset_terminal_modes() {
  # Codex enables enhanced keyboard protocols while the TUI owns the terminal.
  # If it is interrupted before its Rust-side cleanup runs, reset the modes
  # before zsh starts reading the next prompt.
  local reset=$'\033[<u\033[>4;0m\033[?2004l\033[?1004l\033[?1007l\033[?25h'
  if [[ -t 1 ]]; then
    printf '%s' "$reset"
  elif [[ -t 2 ]]; then
    printf '%s' "$reset" >&2
  fi
}

__codex_drain_terminal_input() {
  [[ -t 0 ]] || return 0

  local discarded
  while IFS= read -r -s -k 1 -t 0.01 discarded; do
    :
  done
}

__codex_precmd_reset_terminal_modes() {
  if [[ -n "${__codex_terminal_reset_pending-}" ]]; then
    __codex_reset_terminal_modes
    sleep 0.05
    __codex_drain_terminal_input
    unset __codex_terminal_reset_pending
  fi
}

if [[ -z "${precmd_functions[(r)__codex_precmd_reset_terminal_modes]-}" ]]; then
  precmd_functions+=(__codex_precmd_reset_terminal_modes)
fi

codex() {
  if ! whence -p codex >/dev/null 2>&1; then
    echo "codex is not installed" >&2
    return 1
  fi

  __codex_terminal_reset_pending=1
  {
    command codex "$@"
  } always {
    local codex_status=$?
    __codex_reset_terminal_modes
    __codex_drain_terminal_input
    return "$codex_status"
  }
}

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
