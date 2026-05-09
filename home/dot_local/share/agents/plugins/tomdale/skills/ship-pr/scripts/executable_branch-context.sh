#!/usr/bin/env bash

set -euo pipefail

repo_arg="${1:-.}"

if ! cd "$repo_arg" 2>/dev/null; then
  printf 'error: could not access repo path: %s\n' "$repo_arg" >&2
  exit 1
fi

if ! repo_root="$(git rev-parse --show-toplevel 2>/dev/null)"; then
  printf 'error: not a git repository: %s\n' "$repo_arg" >&2
  exit 1
fi

cd "$repo_root"

resolve_base_branch() {
  local origin_head=""

  if origin_head="$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null)"; then
    printf '%s\n' "${origin_head#origin/}"
    return
  fi

  if git show-ref --verify --quiet refs/heads/main; then
    printf 'main\n'
    return
  fi

  if git show-ref --verify --quiet refs/heads/master; then
    printf 'master\n'
    return
  fi

  printf 'main\n'
}

print_section() {
  printf '\n== %s ==\n' "$1"
}

run() {
  printf '$'
  printf ' %q' "$@"
  printf '\n'
  "$@"
}

base_branch="$(resolve_base_branch)"
current_branch="$(git branch --show-current)"
origin_head="$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null || true)"

print_section "repo"
printf 'repo_root: %s\n' "$repo_root"
printf 'current_branch: %s\n' "${current_branch:-DETACHED}"
printf 'base_branch: %s\n' "$base_branch"
printf 'origin_head: %s\n' "${origin_head:-missing}"

print_section "status"
run git status --porcelain=v1

print_section "recent history"
run git log --oneline -10

print_section "branch commits"
run git log --oneline --decorate "${base_branch}..HEAD"

print_section "branch diff summary"
run git diff --name-status "${base_branch}...HEAD"
run git diff --stat "${base_branch}...HEAD"

print_section "branch diff"
run git diff --find-renames "${base_branch}...HEAD"

print_section "staged diff"
run git diff --cached --stat
run git diff --cached

print_section "unstaged diff"
run git diff --stat
run git diff
