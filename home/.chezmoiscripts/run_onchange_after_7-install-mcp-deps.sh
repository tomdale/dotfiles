#!/bin/bash

set -e

# MCP package.json hash: {{ include "dot_local/share/mcp/package.json" | sha256sum }}

if ! command -v npm >/dev/null 2>&1; then
    echo "npm not found, skipping MCP dependency install"
    exit 0
fi

echo "Installing MCP server dependencies..."
cd "$HOME/.local/share/mcp"
npm install --no-fund --no-audit
