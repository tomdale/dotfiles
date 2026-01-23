# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║ core.zsh - Core Utility Functions                                         ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

# ───────────────────────────────────────────────────────────────────────────────
# killport - Kill processes on specified ports
# ───────────────────────────────────────────────────────────────────────────────
# Usage: killport <port> [port...]
# Example: killport 3000 8080
killport() {
  if [[ $# -eq 0 ]]; then
    echo "Usage: killport <port> [port...]" >&2
    return 2
  fi

  for port in "$@"; do
    local pids=$(lsof -ti:"$port" 2>/dev/null)
    if [[ -z "$pids" ]]; then
      echo "Port $port: no process listening"
    else
      for pid in $pids; do
        kill -9 "$pid" 2>/dev/null
        if [[ $? -eq 0 ]]; then
          echo "Port $port: killed pid $pid"
        else
          echo "Port $port: failed to kill pid $pid" >&2
        fi
      done
    fi
  done
}

# ───────────────────────────────────────────────────────────────────────────────
# slink - Create symbolic links with named arguments
# ───────────────────────────────────────────────────────────────────────────────
# Usage: slink --from <source> --to <target>
# Example: slink --from ~/.config/nvim --to ~/dotfiles/nvim
# Creates parent directories if needed, fails if target exists
slink() {
  local from=""
  local to=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --from)
        shift
        from="$1"
        ;;
      --to)
        shift
        to="$1"
        ;;
      -h|--help)
        echo "Usage: slink --from <source> --to <target>"
        return 0
        ;;
      *)
        echo "slink: unknown argument: $1" >&2
        echo "Usage: slink --from <source> --to <target>" >&2
        return 2
        ;;
    esac
    shift
  done

  if [[ -z "$from" || -z "$to" ]]; then
    echo "slink: both --from and --to are required" >&2
    echo "Usage: slink --from <source> --to <target>" >&2
    return 2
  fi

  if [[ ! -e "$from" && ! -L "$from" ]]; then
    echo "slink: source does not exist: $from" >&2
    return 1
  fi

  if [[ -e "$to" || -L "$to" ]]; then
    echo "slink: target already exists: $to" >&2
    return 1
  fi

  mkdir -p "$(dirname "$to")"
  ln -s "$from" "$to"
}

# ───────────────────────────────────────────────────────────────────────────────
# find-closest - Find ancestor directory containing a file
# ───────────────────────────────────────────────────────────────────────────────
# Usage: find-closest <file>
# Example: find-closest package.json  # Find project root
# Returns: Path to directory containing file, or exit 1 if not found
find-closest() {
  if [[ $# -eq 0 ]]; then
    echo "Usage: find-closest <file>" >&2
    return 2
  fi

  local target_file="$1"
  local current_dir="$(pwd)"

  while [[ "$current_dir" != "/" ]]; do
    if [[ -f "$current_dir/$target_file" ]]; then
      echo "$current_dir"
      return 0
    fi
    current_dir="$(dirname "$current_dir")"
  done

  if [[ -f "/$target_file" ]]; then
    echo "/"
    return 0
  fi

  return 1
}

# ───────────────────────────────────────────────────────────────────────────────
# find-closest-dir - Find ancestor directory containing a subdirectory
# ───────────────────────────────────────────────────────────────────────────────
# Usage: find-closest-dir <directory>
# Example: find-closest-dir .git  # Find repo root
# Returns: Path to directory containing subdirectory, or exit 1 if not found
find-closest-dir() {
  if [[ $# -eq 0 ]]; then
    echo "Usage: find-closest-dir <directory>" >&2
    return 2
  fi

  local target_dir="$1"
  local current_dir="$(pwd)"

  while [[ "$current_dir" != "/" ]]; do
    if [[ -d "$current_dir/$target_dir" ]]; then
      echo "$current_dir"
      return 0
    fi
    current_dir="$(dirname "$current_dir")"
  done

  if [[ -d "/$target_dir" ]]; then
    echo "/"
    return 0
  fi

  return 1
}

# ───────────────────────────────────────────────────────────────────────────────
# dotfiles - Edit dotfiles with chezmoi
# ───────────────────────────────────────────────────────────────────────────────
# Usage: dotfiles [file]
# Without args: Opens chezmoi repo in editor
# With file: Opens file in editor with chezmoi watch (auto-applies on save)
dotfiles() {
  if [[ $# -eq 0 ]]; then
    # Open the chezmoi repo root in the editor
    # (parent of source-path since .chezmoiroot=home/)
    ${=VISUAL:-${=EDITOR:-vi}} "$(dirname "$(chezmoi source-path)")" &
    disown
  else
    chezmoi edit --watch "$@" &
    disown
  fi
}

# ───────────────────────────────────────────────────────────────────────────────
# add-alias - Add a new alias to chezmoi-managed config
# ───────────────────────────────────────────────────────────────────────────────
# Usage: add-alias <name> <command>
# Example: add-alias ll 'ls -la'
# Adds to chezmoi source, applies, and makes available immediately
add-alias() {
  if [[ $# -lt 2 ]]; then
    echo "Usage: add-alias <name> <command>" >&2
    echo "Example: add-alias ll 'ls -la'" >&2
    return 2
  fi

  local name="$1"
  shift
  local cmd="$*"

  local source_dir="$(chezmoi source-path)"
  local aliases_file="$source_dir/dot_config/zsh/functions/aliases.zsh"

  if [[ ! -f "$aliases_file" ]]; then
    echo "add-alias: aliases file not found: $aliases_file" >&2
    return 1
  fi

  # Check if alias already exists
  if grep -q "^alias $name=" "$aliases_file"; then
    echo "add-alias: alias '$name' already exists" >&2
    return 1
  fi

  # Append the alias
  echo "alias $name='$cmd'" >> "$aliases_file"
  echo "Added alias: $name='$cmd'"

  # Apply the change and make available immediately
  chezmoi apply ~/.config/zsh/functions/aliases.zsh
  source ~/.config/zsh/functions/aliases.zsh
  echo "Alias '$name' is now available"
}
