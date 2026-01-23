# Core utility functions

# Kill processes running on specified ports
# Usage: killport <port> [port...]
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

# Create a symbolic link with named arguments
# Usage: slink --from <source> --to <target>
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

# Find the closest ancestor directory containing the specified file
# Usage: find-closest <file>
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

# Find the closest ancestor directory containing the specified directory
# Usage: find-closest-dir <directory>
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

# Edit a dotfile with chezmoi and watch for changes
# Usage: dotfiles <file>
dotfiles() {
  if [[ $# -eq 0 ]]; then
    echo "Usage: dotfiles <file>" >&2
    return 2
  fi

  chezmoi edit --watch "$@" &
  disown
}
