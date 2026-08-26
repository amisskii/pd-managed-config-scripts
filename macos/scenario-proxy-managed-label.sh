#!/usr/bin/env bash
# Scenario: Proxy Managed Label (Issue #15206)
# Sets up proxy settings via managed configuration with locked fields,
# so the UI shows a "managed-by" label on the Proxy page.
#
# Usage:
#   ./scenario-proxy-managed-label.sh [community|redhat]
#   PD_BUILD=redhat ./scenario-proxy-managed-label.sh
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

# Write default-settings.json with proxy values
cat > "$DEFAULT_SETTINGS_FILE" <<'EOF'
{
  "proxy.http": "http://example.com:8080",
  "proxy.https": "http://example.com:8080",
  "proxy.no": "localhost"
}
EOF

# Write locked.json to lock proxy settings
cat > "$LOCKED_FILE" <<'EOF'
{
  "locked": ["proxy.http", "proxy.https", "proxy.no"]
}
EOF

# Restore ownership of user-scoped files when run via sudo
if [ -n "${SUDO_USER:-}" ]; then
    chown -R "$SUDO_USER" "$REAL_HOME/.local/share/$USER_CONFIG_SUBPATH" 2>/dev/null || true
fi

echo "Proxy managed label config applied. (build: $BUILD)"
echo "  default-settings.json : $DEFAULT_SETTINGS_FILE"
echo "  locked.json           : $LOCKED_FILE"
echo ""
echo "Start Podman Desktop and check the Proxy page for managed-by labels."
