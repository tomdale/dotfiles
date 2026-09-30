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

# ───────────────────────────────────────────────────────────────────────────────
# review - Check out a PR review worktree, run Codex code review, then open Pi
# ───────────────────────────────────────────────────────────────────────────────
# Usage: review <pr>
# Examples:
#   review 123
#   review vercel/omniagent#456
#   review vercel/omniagent 456
#   review https://github.com/vercel/omniagent/pull/456
#
# Runs `wf review` (which cds into the review worktree via shell integration),
# then runs a non-interactive Codex code review against the PR base branch with
# gpt-5.6-sol at xhigh reasoning effort, and starts Pi with the review output
# included as initial context.
review() {
  if [[ $# -lt 1 ]]; then
    echo "Usage: review <pr>" >&2
    echo "Examples:" >&2
    echo "  review 123" >&2
    echo "  review vercel/omniagent#456" >&2
    echo "  review vercel/omniagent 456" >&2
    echo "  review https://github.com/vercel/omniagent/pull/456" >&2
    return 1
  fi

  if ! command -v wf >/dev/null 2>&1; then
    echo "wf is not installed" >&2
    return 1
  fi

  if ! command -v codex >/dev/null 2>&1; then
    echo "codex is not installed" >&2
    return 1
  fi

  if ! command -v pi >/dev/null 2>&1; then
    echo "pi is not installed" >&2
    return 1
  fi

  # Skip Workforest's completion modal so the review can continue unattended;
  # shell integration still cds into the review worktree on success.
  WORKFOREST_NO_TUI=1 wf review "$@" || return $?

  local base_branch=""
  local pr_number=""
  local cwd_base

  cwd_base="${PWD:t}"
  if [[ "$cwd_base" == pr-* ]]; then
    pr_number="${cwd_base#pr-}"
  fi

  # Prefer the PR's actual base branch when we can resolve it.
  if [[ -n "$pr_number" ]] && command -v gh >/dev/null 2>&1; then
    base_branch="$(gh pr view "$pr_number" --json baseRefName --jq .baseRefName 2>/dev/null || true)"
  fi

  if [[ -z "$base_branch" ]]; then
    base_branch="$(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed 's|^origin/||' || true)"
  fi

  if [[ -z "$base_branch" ]]; then
    base_branch="main"
  fi

  local review_file
  review_file="$(mktemp "${TMPDIR:-/tmp}/codex-review.XXXXXX")" || {
    echo "Unable to create a temporary file for the Codex review" >&2
    return 1
  }

  # Keep the review in a file so Pi can receive the complete output without
  # putting it in the shell's argument list.
  echo "Running Codex review against base branch '${base_branch}' (gpt-5.6-sol, xhigh)..." >&2
  codex \
    -m gpt-5.6-sol \
    -c 'model_reasoning_effort="xhigh"' \
    review \
    --base "$base_branch" >| "$review_file"
  local codex_status=$?
  if (( codex_status != 0 )); then
    rm -f "$review_file"
    return "$codex_status"
  fi

  pi --skill "$HOME/.agents/skills/tdx-pr-feedback/SKILL.md" "@${review_file}" "Load the tdx-pr-feedback skill and use Codex's review above to begin drafting PR review feedback. Start with the first proposed inline comment and ask me to approve, edit, or skip it. Do not post anything to GitHub."
  local pi_status=$?
  rm -f "$review_file"
  return "$pi_status"
}
