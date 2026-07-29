# Cleanup: Remove all Podman Desktop configuration and app data
# Run this between test scenarios to reset to a clean state.

$DefaultSettingsDir = "$env:PROGRAMDATA\Podman Desktop"
$DefaultSettingsFile = "$DefaultSettingsDir\default-settings.json"
$LockedFile = "$DefaultSettingsDir\locked.json"
$UserSettingsDir = "$env:USERPROFILE\.local\share\containers\podman-desktop\configuration"
$UserSettingsFile = "$UserSettingsDir\settings.json"

# Electron app data (Roaming)
$AppDataDir = "$env:APPDATA\Podman Desktop"

# XDG-style data directory (the whole tree)
$XdgDataDir = "$env:USERPROFILE\.local\share\containers\podman-desktop"

# Remove managed config files
Remove-Item $DefaultSettingsFile -Force -ErrorAction SilentlyContinue
Remove-Item $LockedFile -Force -ErrorAction SilentlyContinue

# Remove user settings
Remove-Item $UserSettingsFile -Force -ErrorAction SilentlyContinue

# Remove Electron app data (logs, caches, state, etc.)
if (Test-Path $AppDataDir) {
    Remove-Item $AppDataDir -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "Removed Electron app data: $AppDataDir"
}

# Remove XDG data directory (plugins, extensions-storage, contributions, etc.)
if (Test-Path $XdgDataDir) {
    Remove-Item $XdgDataDir -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "Removed XDG data dir:      $XdgDataDir"
}

Write-Host ""
Write-Host "Cleanup complete. Removed:"
Write-Host "  $DefaultSettingsFile"
Write-Host "  $LockedFile"
Write-Host "  $AppDataDir"
Write-Host "  $XdgDataDir"
