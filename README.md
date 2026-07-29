# Podman Desktop Managed Configuration — Windows PowerShell Scripts

PowerShell scripts that set up managed configuration files for testing Podman Desktop on Windows.

Each script writes the necessary `settings.json`, `default-settings.json`, and/or `locked.json` files to their Windows paths, then prints what to verify in the UI.

## Scripts

| Script | Source | What it configures |
|--------|--------|--------------------|
| `scenario-proxy-managed-label.ps1` | [Issue #15206](https://github.com/podman-desktop/podman-desktop/issues/15206) | Proxy settings with locked fields — UI should show "managed-by" labels |
| `scenario-disable-local-extensions.ps1` | [PR #16457](https://github.com/podman-desktop/podman-desktop/pull/16457) | Hides the "Local Extensions" tab |
| `scenario-disable-extension-catalog.ps1` | [PR #16425](https://github.com/podman-desktop/podman-desktop/pull/16425) | Hides the extension catalog everywhere |
| `scenario-combined.ps1` | [scenario-x-combined](https://github.com/odockal/podman-desktop-qe/blob/main/docs/scenarios/managed-configuration/scenario-x-combined.md) | Multiple properties with different user/default/locked combinations |
| `cleanup.ps1` | — | Removes all config files between test runs |

## File Locations (Windows)

| File | Path |
|------|------|
| User settings | `%USERPROFILE%\.local\share\containers\podman-desktop\configuration\settings.json` |
| Managed defaults | `%PROGRAMDATA%\Podman Desktop\default-settings.json` |
| Locked settings | `%PROGRAMDATA%\Podman Desktop\locked.json` |

## Usage

1. Close Podman Desktop
2. Run a scenario script in PowerShell (may need admin for `%PROGRAMDATA%`):
   ```powershell
   .\scenario-combined.ps1
   ```
3. Start Podman Desktop and verify the UI behavior
4. Run `.\cleanup.ps1` before switching to another scenario
