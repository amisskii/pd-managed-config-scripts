# Cleanup: Remove all Podman Desktop configuration and app data
# Run this between test scenarios to reset to a clean state.
#
# Usage:
#   .\cleanup.ps1 [community|redhat]
#   $env:PD_BUILD = 'redhat'; .\cleanup.ps1
# Defaults to "community" (Podman Desktop). Use "redhat" for the
# Red Hat build of Podman Desktop.

param(
    [ValidateSet('community', 'redhat')]
    [string]$Build = $(if ($env:PD_BUILD) { $env:PD_BUILD } else { 'community' })
)

switch ($Build) {
    'community' {
        $ManagedDirName    = 'Podman Desktop'
        $UserConfigSubPath = 'containers\podman-desktop'
        $AppDataName       = 'Podman Desktop'
    }
    'redhat' {
        $ManagedDirName    = 'Red Hat\Podman Desktop'
        $UserConfigSubPath = 'redhat\podman-desktop'
        $AppDataName       = 'Red Hat build of Podman Desktop'
    }
    default {
        throw "Unknown build '$Build'. Use 'community' or 'redhat'."
    }
}

$DefaultSettingsDir = "$env:PROGRAMDATA\$ManagedDirName"
$DefaultSettingsFile = "$DefaultSettingsDir\default-settings.json"
$LockedFile = "$DefaultSettingsDir\locked.json"
$UserSettingsDir = "$env:USERPROFILE\.local\share\$UserConfigSubPath\configuration"
$UserSettingsFile = "$UserSettingsDir\settings.json"

# Electron app data (Roaming)
$AppDataDir = "$env:APPDATA\$AppDataName"

# XDG-style data directory (the whole tree)
$XdgDataDir = "$env:USERPROFILE\.local\share\$UserConfigSubPath"

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
