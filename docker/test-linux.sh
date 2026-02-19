#!/bin/bash
# Test dotfiles in an isolated Linux environment
#
# Usage:
#   docker/test-linux.sh              # Start or attach to container
#   docker/test-linux.sh --rebuild    # Rebuild image and start fresh
#   docker/test-linux.sh --local      # Copy local repo for testing uncommitted changes
#   docker/test-linux.sh --reset      # Reset to pristine state (removes container)

set -e

SCRIPT_DIR="$(dirname "$0")"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

IMAGE_NAME="dotfiles-test"
CONTAINER_NAME="dotfiles-test-container"

rebuild=false
mount_local=false
reset=false

for arg in "$@"; do
    case $arg in
        --rebuild)
            rebuild=true
            ;;
        --local)
            mount_local=true
            ;;
        --reset)
            reset=true
            ;;
        --help|-h)
            echo "Usage: $0 [--rebuild] [--local] [--reset]"
            echo ""
            echo "Options:"
            echo "  --rebuild    Force rebuild the Docker image (implies --reset)"
            echo "  --local      Copy local repo into container for testing uncommitted changes"
            echo "  --reset      Remove container and start fresh"
            echo ""
            echo "Session management:"
            echo "  - Detach from tmux: Ctrl-B, then D"
            echo "  - Run script again to reattach"
            echo "  - Use --reset to start over with a pristine container"
            echo ""
            echo "Inside the container, run one of:"
            echo "  # Test from GitHub (production path):"
            echo "  sh -c \"\$(curl -fsLS get.chezmoi.io)\" -- init --apply tomdale"
            echo ""
            echo "  # Test from local copy (if using --local):"
            echo "  sh -c \"\$(curl -fsLS get.chezmoi.io)\" -- init --source ~/dotfiles --apply"
            exit 0
            ;;
    esac
done

# Build the image if needed
if $rebuild || ! docker image inspect "$IMAGE_NAME" &>/dev/null; then
    echo "Building Docker image..."
    docker build -t "$IMAGE_NAME" "$SCRIPT_DIR"
    reset=true  # rebuild implies reset
fi

# Handle reset
if $reset; then
    echo "Removing container..."
    docker rm -f "$CONTAINER_NAME" 2>/dev/null || true
fi

# Check if container exists and is running
if docker ps -q -f name="$CONTAINER_NAME" | grep -q .; then
    echo "Attaching to existing container..."
    docker exec -it "$CONTAINER_NAME" tmux attach -t main 2>/dev/null \
        || docker exec -it "$CONTAINER_NAME" tmux new -s main
    exit 0
fi

# Check if container exists but is stopped
if docker ps -aq -f name="$CONTAINER_NAME" | grep -q .; then
    echo "Starting stopped container..."
    docker start "$CONTAINER_NAME"
    docker exec -it "$CONTAINER_NAME" tmux attach -t main 2>/dev/null \
        || docker exec -it "$CONTAINER_NAME" tmux new -s main
    exit 0
fi

# Create and start new container
echo "Starting fresh Linux environment..."
echo ""

docker run -d --name "$CONTAINER_NAME" "$IMAGE_NAME" sleep infinity

if $mount_local; then
    echo "Copying local repo into container..."
    docker exec "$CONTAINER_NAME" mkdir -p /home/ubuntu/dotfiles
    tar -C "$REPO_ROOT" --exclude='.git' --exclude='.agent' --exclude='.DS_Store' --exclude='*.swp' -cf - . \
        | docker exec -i "$CONTAINER_NAME" tar -C /home/ubuntu/dotfiles -xf -
    chezmoi_cmd='sh -c "$(curl -fsLS get.chezmoi.io)" -- init --source ~/dotfiles --apply'
else
    chezmoi_cmd='sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply tomdale'
fi

# Start tmux with a shell that prints welcome message first
docker exec -it "$CONTAINER_NAME" tmux new -s main \
    "echo; echo 'Run: $chezmoi_cmd'; echo; echo 'Detach: Ctrl-B, D  |  Reattach: docker/test-linux.sh'; echo; exec zsh"
