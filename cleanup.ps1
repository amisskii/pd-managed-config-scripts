# Cleanup: Remove all managed configuration files
# Run this between test scenarios to reset to a clean state.

$DefaultSettingsDir = "$env:PROGRAMDATA\Podman Desktop"
$DefaultSettingsFile = "$DefaultSettingsDir\default-settings.json"
$LockedFile = "$DefaultSettingsDir\locked.json"
$UserSettingsDir = "$env:USERPROFILE\.local\share\containers\podman-desktop\configuration"
$UserSettingsFile = "$UserSettingsDir\settings.json"

Remove-Item $UserSettingsFile -Force -ErrorAction SilentlyContinue
Remove-Item $DefaultSettingsFile -Force -ErrorAction SilentlyContinue
Remove-Item $LockedFile -Force -ErrorAction SilentlyContinue

Write-Host "Cleanup complete. Removed:"
Write-Host "  $UserSettingsFile"
Write-Host "  $DefaultSettingsFile"
Write-Host "  $LockedFile"
