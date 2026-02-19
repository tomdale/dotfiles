#!/bin/bash
# Install Tmux Plugin Manager if not present
# hash: {{ include "dot_config/tmux/tmux.conf" | sha256sum }}

set -euo pipefail

TPM_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/tmux/plugins/tpm"

if [[ ! -d "$TPM_DIR" ]]; then
    echo "Installing Tmux Plugin Manager..."
    mkdir -p "$(dirname "$TPM_DIR")"
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
    echo "TPM installed. Run 'prefix + I' inside tmux to install plugins."
else
    echo "TPM already installed."
fi
