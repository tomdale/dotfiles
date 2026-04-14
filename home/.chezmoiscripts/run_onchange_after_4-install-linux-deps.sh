#!/bin/bash

set -e

# Only run on Linux
if [[ "$OSTYPE" != "linux"* ]]; then
    exit 0
fi

echo "Installing Linux dependencies..."

# Prevent interactive prompts
export DEBIAN_FRONTEND=noninteractive

# Source shared environment variables (deployed by chezmoi before scripts run)
# shellcheck source=/dev/null
source "$HOME/.config/zsh/env.sh"

# ─────────────────────────────────────────────────────────────────────────────
# System packages (apt)
# ─────────────────────────────────────────────────────────────────────────────
if command -v apt-get &>/dev/null; then
    echo "Installing apt packages..."
    sudo apt-get update -qq
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
        build-essential \
        curl \
        direnv \
        git \
        unzip \
        vim \
        wget

fi

# ─────────────────────────────────────────────────────────────────────────────
# Rust toolchain
# ─────────────────────────────────────────────────────────────────────────────
if ! command -v cargo &>/dev/null; then
    echo "Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
    # shellcheck source=/dev/null
    source "$CARGO_HOME/env"
fi

# ─────────────────────────────────────────────────────────────────────────────
# Cargo tools
# ─────────────────────────────────────────────────────────────────────────────
if command -v cargo &>/dev/null; then
    echo "Installing cargo tools..."

    # Only install if not already present
    command -v termtint &>/dev/null || cargo install termtint
    command -v termtitle &>/dev/null || cargo install termtitle
fi

echo "✓ Linux dependencies installed"
