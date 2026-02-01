# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║ git.zsh - Git Helper Functions                                            ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

# ───────────────────────────────────────────────────────────────────────────────
# clone - Clone a GitHub repo and cd into it
# ───────────────────────────────────────────────────────────────────────────────
# Usage: clone <repo> [directory]
# Example: clone anthropics/claude-code
# Clones to ~/Code/<repo-name> and changes into the directory
clone() {
  if [[ $# -eq 0 ]]; then
    echo "Usage: clone <repo> [directory]" >&2
    return 2
  fi

  local repo="$1"
  local target_dir="${2:-$(basename "$repo" .git)}"

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
