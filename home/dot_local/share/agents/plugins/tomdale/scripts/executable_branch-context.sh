#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: branch-context.sh [repo-path]

Print the current repository's branch context for ship-pr workflows:
- repo root
- current branch
- upstream
- resolved base branch
- ahead/behind counts
- working tree summary
- commits and diff stats relative to base
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

repo_path="${1:-$PWD}"

if [[ ! -d "$repo_path" ]]; then
  echo "error: repo path does not exist: $repo_path" >&2
  exit 1
fi

cd "$repo_path"

if ! git rev-parse --show-toplevel >/dev/null 2>&1; then
  echo "error: not a git repository: $repo_path" >&2
  exit 1
fi

repo_root="$(git rev-parse --show-toplevel)"
current_branch="$(git symbolic-ref --quiet --short HEAD 2>/dev/null || true)"
if [[ -z "$current_branch" ]]; then
  current_branch="DETACHED"
fi

remote_name=""
if git remote get-url origin >/dev/null 2>&1; then
  remote_name="origin"
else
  remote_name="$(git remote | head -n1 || true)"
fi

upstream_ref="$(git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null || true)"

resolve_base_branch() {
  local remote="${1:-}"
  local branch=""

  if [[ -n "$remote" ]]; then
    branch="$(git symbolic-ref --quiet --short "refs/remotes/$remote/HEAD" 2>/dev/null || true)"
    branch="${branch#"$remote/"}"
  fi

  if [[ -z "$branch" ]] && git show-ref --verify --quiet refs/heads/main; then
    branch="main"
  fi
  if [[ -z "$branch" ]] && git show-ref --verify --quiet refs/heads/master; then
    branch="master"
  fi
  if [[ -z "$branch" ]] && [[ -n "$remote" ]] && git show-ref --verify --quiet "refs/remotes/$remote/main"; then
    branch="main"
  fi
  if [[ -z "$branch" ]] && [[ -n "$remote" ]] && git show-ref --verify --quiet "refs/remotes/$remote/master"; then
    branch="master"
  fi
  if [[ -z "$branch" ]] && [[ "$current_branch" != "DETACHED" ]]; then
    branch="$current_branch"
  fi

  printf '%s\n' "$branch"
}

base_branch="$(resolve_base_branch "$remote_name")"
base_ref=""

if [[ -n "$base_branch" && -n "$remote_name" ]] && git show-ref --verify --quiet "refs/remotes/$remote_name/$base_branch"; then
  base_ref="$remote_name/$base_branch"
elif [[ -n "$base_branch" ]] && git show-ref --verify --quiet "refs/heads/$base_branch"; then
  base_ref="$base_branch"
fi

behind_count="?"
ahead_count="?"
if [[ -n "$base_ref" ]]; then
  counts="$(git rev-list --left-right --count "$base_ref...HEAD" 2>/dev/null || true)"
  if [[ -n "$counts" ]]; then
    read -r behind_count ahead_count <<<"$counts"
  fi
fi

echo "repo_root=$repo_root"
echo "current_branch=$current_branch"
echo "remote=${remote_name:-none}"
echo "upstream=${upstream_ref:-none}"
echo "base_branch=${base_branch:-unknown}"
echo "base_ref=${base_ref:-unknown}"
echo "ahead_of_base=$ahead_count"
echo "behind_base=$behind_count"
echo

echo "== git status --short --branch =="
git status --short --branch
echo

if [[ -n "$base_ref" ]]; then
  echo "== commits ahead of $base_ref =="
  git log --oneline --decorate --no-merges "$base_ref..HEAD" || true
  echo

  echo "== changed files vs $base_ref =="
  git diff --stat "$base_ref...HEAD" || true
  echo
fi

echo "== staged changes =="
git diff --cached --stat || true
echo

echo "== unstaged changes =="
git diff --stat || true
echo

echo "== recent commits =="
git log --oneline --decorate -10 || true
