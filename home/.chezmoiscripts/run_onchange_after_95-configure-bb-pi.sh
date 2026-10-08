#!/bin/sh
set -eu

# BB's managed environment reaches GUI-launched provider workers too.
if command -v bb-app >/dev/null 2>&1; then
    bb_app() { command bb-app "$@"; }
else
    launcher=""
    for app in "/Applications/bb Personal.app" "/Applications/bb.app"; do
        candidate="$app/Contents/Resources/app.asar.unpacked/node_modules/bb-app/dist/bb-app.js"
        if [ -f "$candidate" ]; then
            launcher="$candidate"
            break
        fi
    done
    if [ -z "$launcher" ]; then
        echo "BB is not installed; skipping Pi launcher configuration"
        exit 0
    fi
    proto_home="${PROTO_HOME:-${XDG_DATA_HOME:-$HOME/.local/share}/proto}"
    node="$(unset PROTO_VERSION PROTO_NODE_VERSION; "$proto_home/bin/proto" --reporter text bin node --config-mode global)"
    bb_app() { "$node" "$launcher" "$@"; }
fi

bb_app env set BB_PI_BRIDGE_COMMAND "$HOME/.local/bin/bb-pi"
bb_app env set BB_PI_BRIDGE_ARGS '[]'
