# Git-related functions

# Clone a GitHub repo into ~/Code and cd into it
# Usage: clone <repo> [directory]
clone() {
  if [[ $# -eq 0 ]]; then
    echo "Usage: clone <repo> [directory]" >&2
    return 2
  fi

  local repo="$1"
  local target_dir="${2:-$(basename "$repo" .git)}"

  cd ~/Code && gh repo clone "$@" && cd "$target_dir"
}

# Add a pattern to gitignore
# Usage: gitignore <pattern>        - Add to global gitignore (chezmoi-managed)
#        gitignore --local <pattern> - Add to .gitignore in current directory
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
    echo "$pattern" >> .gitignore
    echo "Added '$pattern' to .gitignore"
  else
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
