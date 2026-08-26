#!/usr/bin/env bash
# Scenario: Combined Managed Configuration (scenario-x-combined)
# Sets up user settings, managed defaults, and locked settings to test
# multiple properties with different override/lock combinations.
#
# Properties tested:
#   preferences.appearance       - user only
#   feedback.dialog              - user + default
#   tasks.Toast                  - user + locked
#   terminal.integrated.lineHeight - locked only
#   preferences.zoomLevel        - default only
#   preferences.ExitOnClose      - default + locked
#
# Usage:
#   ./scenario-combined.sh [community|redhat]
#   PD_BUILD=redhat ./scenario-combined.sh
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

# Write user settings
cat > "$USER_SETTINGS_FILE" <<'EOF'
{
  "preferences.appearance": "system",
  "feedback.dialog": false,
  "tasks.Toast": true
}
EOF

# Write managed default settings
cat > "$DEFAULT_SETTINGS_FILE" <<'EOF'
{
  "feedback.dialog": true,
  "preferences.zoomLevel": 0.5,
  "preferences.ExitOnClose": false
}
EOF

# Write locked settings
cat > "$LOCKED_FILE" <<'EOF'
{
  "locked": [
    "terminal.integrated.lineHeight",
    "tasks.Toast",
    "preferences.ExitOnClose"
  ]
}
EOF

# Restore ownership of user-scoped files when run via sudo
if [ -n "${SUDO_USER:-}" ]; then
    chown -R "$SUDO_USER" "$REAL_HOME/.local/share/$USER_CONFIG_SUBPATH" 2>/dev/null || true
fi

echo "Combined managed configuration applied. (build: $BUILD)"
echo ""
echo "Files written:"
echo "  settings.json         : $USER_SETTINGS_FILE"
echo "  default-settings.json : $DEFAULT_SETTINGS_FILE"
echo "  locked.json           : $LOCKED_FILE"
echo ""
echo "Properties to verify:"
echo "  preferences.appearance            - user only (system)"
echo "  feedback.dialog                   - user (false) overrides default (true)"
echo "  tasks.Toast                       - user (true) + locked"
echo "  terminal.integrated.lineHeight    - locked only (no value set)"
echo "  preferences.zoomLevel             - default only (0.5)"
echo "  preferences.ExitOnClose           - default (false) + locked"
