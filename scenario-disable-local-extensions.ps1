# Scenario: Disable Local Extensions (PR #16457)
# Sets extensions.localExtensions.enabled to false so the
# "Local Extensions" tab is hidden in the Extensions section.

$DefaultSettingsDir = "$env:PROGRAMDATA\Podman Desktop"
$DefaultSettingsFile = "$DefaultSettingsDir\default-settings.json"
$LockedFile = "$DefaultSettingsDir\locked.json"
$UserSettingsDir = "$env:USERPROFILE\.local\share\containers\podman-desktop\configuration"
$UserSettingsFile = "$UserSettingsDir\settings.json"

# Clean up existing files
Remove-Item $UserSettingsFile -Force -ErrorAction SilentlyContinue
Remove-Item $LockedFile -Force -ErrorAction SilentlyContinue
Remove-Item $DefaultSettingsFile -Force -ErrorAction SilentlyContinue

# Create directories
New-Item -ItemType Directory -Force -Path $DefaultSettingsDir | Out-Null
New-Item -ItemType Directory -Force -Path $UserSettingsDir | Out-Null

# Write default-settings.json
@'
{
  "extensions.localExtensions.enabled": false
}
'@ | Set-Content $DefaultSettingsFile -Encoding UTF8

# Lock the setting
@'
{
  "locked": ["extensions.localExtensions.enabled"]
}
'@ | Set-Content $LockedFile -Encoding UTF8

Write-Host "Local extensions disabled via managed config."
Write-Host "  default-settings.json : $DefaultSettingsFile"
Write-Host "  locked.json           : $LockedFile"
Write-Host ""
Write-Host "Start Podman Desktop - the 'Local Extensions' tab should be hidden."
