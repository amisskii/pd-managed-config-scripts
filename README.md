# Podman Desktop Managed Configuration — Scripts

Scripts that set up managed configuration files for testing Podman Desktop's [managed configuration](https://podman-desktop.io/docs/configuration) feature. Windows scripts are in PowerShell at the repo root; macOS scripts are Bash, in `macos/`.

Each script writes the necessary `settings.json`, `default-settings.json`, and/or `locked.json` files to their platform's paths, then prints what to verify in the UI.

## Scripts

| Script | Source | What it configures |
|--------|--------|--------------------|
| `scenario-proxy-managed-label` | [Issue #15206](https://github.com/podman-desktop/podman-desktop/issues/15206) | Proxy settings with locked fields — UI should show "managed-by" labels |
| `scenario-disable-local-extensions` | [PR #16457](https://github.com/podman-desktop/podman-desktop/pull/16457) | Hides the "Local Extensions" tab |
| `scenario-disable-extension-catalog` | [PR #16425](https://github.com/podman-desktop/podman-desktop/pull/16425) | Hides the extension catalog everywhere |
| `scenario-combined` | [scenario-x-combined](https://github.com/odockal/podman-desktop-qe/blob/main/docs/scenarios/managed-configuration/scenario-x-combined.md) | Multiple properties with different user/default/locked combinations |
| `cleanup` | — | Removes all config files between test runs |

`scenario-wsl-error-mock.ps1` is Windows-only (it mocks a WSL service error) and has no macOS equivalent.

## Windows

### File Locations

| File | Path |
|------|------|
| User settings | `%USERPROFILE%\.local\share\containers\podman-desktop\configuration\settings.json` |
| Managed defaults | `%PROGRAMDATA%\Podman Desktop\default-settings.json` |
| Locked settings | `%PROGRAMDATA%\Podman Desktop\locked.json` |

### Usage

1. Close Podman Desktop
2. Run a scenario script in PowerShell (may need admin for `%PROGRAMDATA%`):
   ```powershell
   .\scenario-combined.ps1
   ```
3. Start Podman Desktop and verify the UI behavior
4. Run `.\cleanup.ps1` before switching to another scenario

## macOS

Scripts are in [`macos/`](macos/). Each script takes an optional `community` (default) or `redhat` argument — or `PD_BUILD=redhat` — to target either the community build (Podman Desktop) or the Red Hat build of Podman Desktop, which use different bundle IDs and managed-config paths.

### File Locations

| File | Community build | Red Hat build |
|------|------------------|----------------|
| User settings | `~/.local/share/containers/podman-desktop/configuration/settings.json` | `~/.local/share/redhat/podman-desktop/configuration/settings.json` |
| Managed defaults | `/Library/Application Support/io.podman_desktop.PodmanDesktop/default-settings.json` | `/Library/Application Support/com.redhat.PodmanDesktop/default-settings.json` |
| Locked settings | `/Library/Application Support/io.podman_desktop.PodmanDesktop/locked.json` | `/Library/Application Support/com.redhat.PodmanDesktop/locked.json` |
| Electron app data (removed by `cleanup.sh`) | `~/Library/Application Support/Podman Desktop` | `~/Library/Application Support/Red Hat build of Podman Desktop` |

### Usage

1. Close Podman Desktop
2. Run a scenario script (needs `sudo` to write under `/Library/Application Support`; user-scoped files are chowned back to you automatically):
   ```bash
   cd macos
   sudo ./scenario-combined.sh            # community build (default)
   sudo ./scenario-combined.sh redhat     # Red Hat build
   ```
3. Start Podman Desktop and verify the UI behavior
4. Run `sudo ./cleanup.sh [community|redhat]` before switching to another scenario
