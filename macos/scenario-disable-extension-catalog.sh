#!/usr/bin/env bash
# Scenario: Disable Extension Catalog (PR #16425)
# Sets extensions.catalog.enabled to false so the extension catalog
# is hidden from Extensions, Settings, Authentication, and Kubernetes pages.
#
# Usage:
#   ./scenario-disable-extension-catalog.sh [community|redhat]
#   PD_BUILD=redhat ./scenario-disable-extension-catalog.sh
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
  "extensions.catalog.enabled": false
}
EOF

# Write locked.json
cat > "$LOCKED_FILE" <<'EOF'
{
  "locked": ["extensions.catalog.enabled"]
}
EOF

# Restore ownership of user-scoped files when run via sudo
if [ -n "${SUDO_USER:-}" ]; then
    chown -R "$SUDO_USER" "$REAL_HOME/.local/share/$USER_CONFIG_SUBPATH" 2>/dev/null || true
fi

echo "Extension catalog disabled via managed config. (build: $BUILD)"
echo "  default-settings.json : $DEFAULT_SETTINGS_FILE"
echo "  locked.json           : $LOCKED_FILE"
echo ""
echo "Start Podman Desktop - catalog should be hidden from Extensions,"
echo "Settings, Authentication, and Kubernetes pages."
