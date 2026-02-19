#!/bin/bash
# Install Proto toolchain manager with XDG-compliant paths
# https://moonrepo.dev/docs/proto/install

set -euo pipefail

echo "Setting up Proto toolchain manager..."

# ─────────────────────────────────────────────────────────────────────────────
# Source shared environment variables (deployed by chezmoi before scripts run)
# ─────────────────────────────────────────────────────────────────────────────
# shellcheck source=/dev/null
source "$HOME/.config/zsh/env.sh"

echo "PROTO_HOME=$PROTO_HOME"

# ─────────────────────────────────────────────────────────────────────────────
# Install Proto if not present
# ─────────────────────────────────────────────────────────────────────────────
if [[ -x "$PROTO_HOME/bin/proto" ]]; then
    echo "Proto is already installed at $PROTO_HOME"
else
    echo "Installing Proto..."

    # Ensure the directory exists (installer expects it)
    mkdir -p "$PROTO_HOME"

    # Download and run the installer
    # --yes: skip interactive prompts
    # --no-profile: don't modify shell profile (chezmoi manages that)
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL https://moonrepo.dev/install/proto.sh | bash -s -- --yes --no-profile
    elif command -v wget >/dev/null 2>&1; then
        wget -qO- https://moonrepo.dev/install/proto.sh | bash -s -- --yes --no-profile
    else
        echo "Error: Neither curl nor wget is available. Cannot download Proto."
        exit 1
    fi

    # Verify installation
    if [[ -x "$PROTO_HOME/bin/proto" ]]; then
        echo "Proto successfully installed"
    else
        echo "Proto installation may have failed"
        exit 1
    fi
fi

# ─────────────────────────────────────────────────────────────────────────────
# Add proto to PATH for subsequent commands in this script
# ─────────────────────────────────────────────────────────────────────────────
export PATH="$PROTO_HOME/shims:$PROTO_HOME/bin:$PATH"

# ─────────────────────────────────────────────────────────────────────────────
# Configure proto settings (before pinning, which also writes to this file)
# ─────────────────────────────────────────────────────────────────────────────
PROTOTOOLS_FILE="$PROTO_HOME/.prototools"
if [[ ! -f "$PROTOTOOLS_FILE" ]] || ! grep -q "telemetry" "$PROTOTOOLS_FILE"; then
    echo "Configuring proto settings..."
    cat > "$PROTOTOOLS_FILE" << 'SETTINGS'
# Proto global configuration
# https://moonrepo.dev/docs/proto/config

[settings]
# Disable telemetry
telemetry = false

# Automatically install tools when switching to a directory with .prototools
# or package.json containing engines/devEngines (Volta-like behavior)
auto-install = true
SETTINGS
fi

# ─────────────────────────────────────────────────────────────────────────────
# Install Node and npm
# ─────────────────────────────────────────────────────────────────────────────
echo "Installing Node LTS and npm..."

# Install node if not already installed (proto install is idempotent)
proto install node lts

# Install npm (bundled with node, but proto manages it separately for version control)
proto install npm

# Pin global defaults so there's always a fallback version
# --to global: pins to ~/.proto/.prototools (actually $PROTO_HOME/.prototools)
# --resolve: converts aliases like "lts" to actual version numbers
proto pin node lts --to global --resolve
proto pin npm latest --to global --resolve

# ─────────────────────────────────────────────────────────────────────────────
# Install Python
# ─────────────────────────────────────────────────────────────────────────────
echo "Installing Python 3.12..."

# Install Python 3.12 (latest pre-built stable version)
# Note: "latest" may not have pre-built binaries, so we pin to 3.12
proto install python 3.12

proto pin python 3.12 --to global --resolve

# ─────────────────────────────────────────────────────────────────────────────
# Summary
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "Proto setup complete!"
echo "  PROTO_HOME: $PROTO_HOME"
proto --version
echo "  Node: $(node --version 2>/dev/null || echo 'not available')"
echo "  npm: $(npm --version 2>/dev/null || echo 'not available')"
echo "  Python: $(python --version 2>/dev/null || echo 'not available')"
