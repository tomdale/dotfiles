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
# which-original - Find the path of the original command (bypassing aliases)
# ───────────────────────────────────────────────────────────────────────────────
# Usage: which-original <command>
# Example: which-original tmux  # Returns /usr/local/bin/tmux even if tmux is aliased
# Shows all definitions: alias, function, builtin, and executable path
which-original() {
  if [[ $# -eq 0 ]]; then
    echo "Usage: which-original <command>" >&2
    return 2
  fi

  local cmd="$1"
  
  # Show all definitions (alias, function, builtin, file)
  echo "All definitions of '$cmd':"
  type -a "$cmd" 2>/dev/null || {
    echo "  Command '$cmd' not found" >&2
    return 1
  }
  
  echo ""
  echo "Original executable path:"
  # Use \command to bypass alias expansion, or whence -p for zsh-specific path lookup
  \command -v "$cmd" 2>/dev/null || whence -p "$cmd" 2>/dev/null || {
    echo "  No executable found for '$cmd'" >&2
    return 1
  }
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
# with-cursor - Run a command with EDITOR set to "cursor --wait"
# ───────────────────────────────────────────────────────────────────────────────
# Usage: with-cursor <command> [args...]
# Example: with-cursor git commit  # Opens commit message in Cursor
with-cursor() {
  if [[ $# -eq 0 ]]; then
    echo "Usage: with-cursor <command> [args...]" >&2
    return 2
  fi
  EDITOR="cursor --wait" "$@"
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
# shortcut - Manage shell aliases in chezmoi-managed config
# ───────────────────────────────────────────────────────────────────────────────
# Usage: shortcut <command> [args...]
#   shortcut add <name> <command>  - Add a new alias
#   shortcut remove <name>         - Remove an alias (alias: rm)
#   shortcut list                  - List all aliases
shortcut() {
  local source_dir="$(chezmoi source-path)"
  local aliases_file="$source_dir/dot_config/zsh/functions/aliases.zsh"

  if [[ ! -f "$aliases_file" ]]; then
    echo "shortcut: aliases file not found: $aliases_file" >&2
    return 1
  fi

  local subcmd="${1:-}"
  shift 2>/dev/null

  case "$subcmd" in
    add)
      _shortcut_add "$aliases_file" "$@"
      ;;
    remove|rm)
      _shortcut_remove "$aliases_file" "$@"
      ;;
    list)
      _shortcut_list "$aliases_file"
      ;;
    -h|--help|"")
      _shortcut_help
      ;;
    *)
      echo "shortcut: unknown command '$subcmd'" >&2
      _shortcut_help >&2
      return 2
      ;;
  esac
}

_shortcut_help() {
  cat <<EOF
Usage: shortcut <command> [args...]

Commands:
  add <name> <command>  Add a new alias
  remove <name>         Remove an alias (alias: rm)
  list                  List all aliases

Examples:
  shortcut add ll 'ls -la'
  shortcut remove ll
  shortcut list
EOF
}

_shortcut_add() {
  local aliases_file="$1"
  shift

  if [[ $# -lt 2 ]]; then
    echo "Usage: shortcut add <name> <command>" >&2
    return 2
  fi

  local name="$1"
  shift
  local cmd="$*"

  if grep -q "^alias $name=" "$aliases_file"; then
    echo "shortcut: alias '$name' already exists" >&2
    return 1
  fi

  echo "alias $name='$cmd'" >> "$aliases_file"
  echo "Added alias: $name='$cmd'"

  chezmoi apply ~/.config/zsh/functions/aliases.zsh
  source ~/.config/zsh/functions/aliases.zsh
  echo "Alias '$name' is now available"
}

_shortcut_remove() {
  local aliases_file="$1"
  local name="$2"

  if [[ -z "$name" ]]; then
    echo "Usage: shortcut remove <name>" >&2
    return 2
  fi

  if ! grep -q "^alias $name=" "$aliases_file"; then
    echo "shortcut: alias '$name' not found" >&2
    return 1
  fi

  sed -i '' "/^alias $name=/d" "$aliases_file"
  echo "Removed alias: $name"

  chezmoi apply ~/.config/zsh/functions/aliases.zsh
  source ~/.config/zsh/functions/aliases.zsh
  echo "Alias '$name' has been removed"
}

_shortcut_list() {
  local aliases_file="$1"

  echo "Shortcuts in aliases.zsh:"
  echo ""
  grep "^alias " "$aliases_file" | sed 's/^alias /  /' | while read -r line; do
    echo "$line"
  done
}
