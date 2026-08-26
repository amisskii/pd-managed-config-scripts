#!/usr/bin/env bash
# Cleanup: Remove all Podman Desktop configuration and app data
# Run this between test scenarios to reset to a clean state.
#
# Usage:
#   ./cleanup.sh [community|redhat]
#   PD_BUILD=redhat ./cleanup.sh
# Defaults to "community" (Podman Desktop). Use "redhat" for the
# Red Hat build of Podman Desktop.

BUILD="${1:-${PD_BUILD:-community}}"

case "$BUILD" in
  community)
    MANAGED_DIR="/Library/Application Support/io.podman_desktop.PodmanDesktop"
    USER_CONFIG_SUBPATH="containers/podman-desktop"
    APP_DATA_NAME="Podman Desktop"
    ;;
  redhat)
    MANAGED_DIR="/Library/Application Support/com.redhat.PodmanDesktop"
    USER_CONFIG_SUBPATH="redhat/podman-desktop"
    APP_DATA_NAME="Red Hat build of Podman Desktop"
    ;;
  *)
    echo "Unknown build '$BUILD'. Use 'community' or 'redhat'." >&2
    exit 1
    ;;
esac

# sudo resets $HOME to root's home; resolve the invoking user's home instead
REAL_HOME="$HOME"
if [ -n "${SUDO_USER:-}" ]; then
    REAL_HOME=$(eval echo "~$SUDO_USER")
fi

DEFAULT_SETTINGS_DIR="$MANAGED_DIR"
DEFAULT_SETTINGS_FILE="$DEFAULT_SETTINGS_DIR/default-settings.json"
LOCKED_FILE="$DEFAULT_SETTINGS_DIR/locked.json"
USER_SETTINGS_DIR="$REAL_HOME/.local/share/$USER_CONFIG_SUBPATH/configuration"
USER_SETTINGS_FILE="$USER_SETTINGS_DIR/settings.json"

# Electron app data
APP_DATA_DIR="$REAL_HOME/Library/Application Support/$APP_DATA_NAME"

# XDG-style data directory (the whole tree)
XDG_DATA_DIR="$REAL_HOME/.local/share/$USER_CONFIG_SUBPATH"

# Remove managed config files
rm -f "$DEFAULT_SETTINGS_FILE" 2>/dev/null || true
rm -f "$LOCKED_FILE" 2>/dev/null || true

# Remove user settings
rm -f "$USER_SETTINGS_FILE" 2>/dev/null || true

# Remove Electron app data (logs, caches, state, etc.)
if [ -d "$APP_DATA_DIR" ]; then
    rm -rf "$APP_DATA_DIR"
    echo "Removed Electron app data: $APP_DATA_DIR"
fi

# Remove XDG data directory (plugins, extensions-storage, contributions, etc.)
if [ -d "$XDG_DATA_DIR" ]; then
    rm -rf "$XDG_DATA_DIR"
    echo "Removed XDG data dir:      $XDG_DATA_DIR"
fi

echo ""
echo "Cleanup complete. (build: $BUILD) Removed:"
echo "  $DEFAULT_SETTINGS_FILE"
echo "  $LOCKED_FILE"
echo "  $APP_DATA_DIR"
echo "  $XDG_DATA_DIR"
