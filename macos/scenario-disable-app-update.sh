#!/usr/bin/env bash
# Scenario: Disable App Update (PR #17682, closes #16483)
# Sets preferences.update.appUpdate to false so Podman Desktop does not
# check for application updates on startup or present update prompts.
#
# Usage:
#   ./scenario-disable-app-update.sh [community|redhat]
#   PD_BUILD=redhat ./scenario-disable-app-update.sh
# Defaults to "community" (Podman Desktop). Use "redhat" for the
# Red Hat build of Podman Desktop.

set -euo pipefail

BUILD="${1:-${PD_BUILD:-community}}"

case "$BUILD" in
  community)
    MANAGED_DIR="/Library/Application Support/io.podman_desktop.PodmanDesktop"
    USER_CONFIG_SUBPATH="containers/podman-desktop"
    ;;
  redhat)
    MANAGED_DIR="/Library/Application Support/com.redhat.PodmanDesktop"
    USER_CONFIG_SUBPATH="redhat/podman-desktop"
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

# Clean up existing files
rm -f "$USER_SETTINGS_FILE" 2>/dev/null || true
rm -f "$LOCKED_FILE" 2>/dev/null || true
rm -f "$DEFAULT_SETTINGS_FILE" 2>/dev/null || true

# Create directories
mkdir -p "$DEFAULT_SETTINGS_DIR"
mkdir -p "$USER_SETTINGS_DIR"

# Write default-settings.json
cat > "$DEFAULT_SETTINGS_FILE" <<'EOF'
{
  "preferences.update.appUpdate": false
}
EOF

# Write locked.json
cat > "$LOCKED_FILE" <<'EOF'
{
  "locked": ["preferences.update.appUpdate"]
}
EOF

# Restore ownership of user-scoped files when run via sudo
if [ -n "${SUDO_USER:-}" ]; then
    chown -R "$SUDO_USER" "$REAL_HOME/.local/share/$USER_CONFIG_SUBPATH" 2>/dev/null || true
fi

echo "App update disabled via managed config. (build: $BUILD)"
echo "  default-settings.json : $DEFAULT_SETTINGS_FILE"
echo "  locked.json           : $LOCKED_FILE"
echo ""
echo "Start Podman Desktop - it should not check for updates or show"
echo "update prompts. The App Update preference should show a lock icon."
