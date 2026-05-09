# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║ git.zsh - Git Helper Functions                                            ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

# ───────────────────────────────────────────────────────────────────────────────
# clone - Clone a GitHub repo and cd into it
# ───────────────────────────────────────────────────────────────────────────────
# Usage: clone <repo> [directory]
# Example: clone anthropics/claude-code
# Clones to ~/Code/<repo-name> and changes into the directory
_clone_normalize_github_url() {
  local url="$1"

  url="${url%.git}"
  url="${url%/}"
  url="${url#ssh://git@github.com/}"
  url="${url#git@github.com:}"
  url="${url#https://github.com/}"
  url="${url#http://github.com/}"
  url="${url#https://www.github.com/}"
  url="${url#http://www.github.com/}"

  if [[ "$url" == github.com/* ]]; then
    url="${url#github.com/}"
  fi

  printf 'https://github.com/%s\n' "$url"
}

clone() {
  if [[ $# -eq 0 ]]; then
    echo "Usage: clone <repo> [directory]" >&2
    return 2
  fi

  local repo="$1"
  local resolved_url
  local target_dir="${2:-$(basename "$repo" .git)}"
  local target_path="$HOME/Code/$target_dir"
  local existing_origin
  local normalized_existing_origin

  resolved_url="$(gh repo view "$repo" --json url --jq .url 2>/dev/null)" || {
    echo "clone: failed to resolve GitHub repo: $repo" >&2
    return 1
  }

  if [[ -e "$target_path" ]]; then
    if [[ -d "$target_path" ]] && git -C "$target_path" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
      existing_origin="$(git -C "$target_path" remote get-url origin 2>/dev/null)" || existing_origin=""
      normalized_existing_origin="$(_clone_normalize_github_url "$existing_origin")"

      if [[ "$normalized_existing_origin" == "$resolved_url" ]]; then
        cd "$target_path" && git fetch origin main:main
        return $?
      fi
    fi

    echo "clone: name conflict at $target_path" >&2
    echo "clone: existing directory does not match $resolved_url" >&2
    return 1
  fi

  cd ~/Code && gh repo clone "$@" && cd "$target_dir"
}

# ───────────────────────────────────────────────────────────────────────────────
# gitignore - Add patterns to gitignore
# ───────────────────────────────────────────────────────────────────────────────
# Usage: gitignore <pattern>         Add to global gitignore (chezmoi-managed)
#        gitignore --local <pattern> Add to .gitignore in current directory
# Example: gitignore "*.log"
#          gitignore --local node_modules
gitignore() {
  local pattern=""
  local local_mode=false

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --local|-l)
        local_mode=true
        ;;
      -h|--help)
        echo "Usage: gitignore [--local] <pattern>"
        echo "  --local, -l  Add to .gitignore in current directory"
        echo "  (default)    Add to global gitignore via chezmoi"
        return 0
        ;;
      -*)
        echo "gitignore: unknown option: $1" >&2
        return 2
        ;;
      *)
        if [[ -z "$pattern" ]]; then
          pattern="$1"
        else
          echo "gitignore: too many arguments" >&2
          return 2
        fi
        ;;
    esac
    shift
  done

  if [[ -z "$pattern" ]]; then
    echo "gitignore: pattern required" >&2
    echo "Usage: gitignore [--local] <pattern>" >&2
    return 2
  fi

  if $local_mode; then
    # Add to local .gitignore
    echo "$pattern" >> .gitignore
    echo "Added '$pattern' to .gitignore"
  else
    # Add to global gitignore (managed by chezmoi)
    local chezmoi_source="${XDG_DATA_HOME:-$HOME/.local/share}/chezmoi"
    local ignore_file="$chezmoi_source/home/dot_config/git/ignore"

    if [[ ! -f "$ignore_file" ]]; then
      echo "gitignore: chezmoi global gitignore not found: $ignore_file" >&2
      return 1
    fi

    echo "$pattern" >> "$ignore_file"
    echo "Added '$pattern' to global gitignore"
    chezmoi apply ~/.config/git/ignore
  fi
}

# ───────────────────────────────────────────────────────────────────────────────
# init - Initialize a new git repo in ~/Code
# ───────────────────────────────────────────────────────────────────────────────
# Usage: init <name>
# Example: init my-project
# Creates ~/Code/<name>, initializes git, and changes into the directory
init() {
  if [[ $# -eq 0 ]]; then
    echo "Usage: init <name>" >&2
    return 2
  fi

  local name="$1"
  local target_dir="$HOME/Code/$name"

  if [[ -e "$target_dir" ]]; then
    echo "init: $target_dir already exists" >&2
    return 1
  fi

  mkdir -p "$target_dir" && cd "$target_dir" && git init
}
