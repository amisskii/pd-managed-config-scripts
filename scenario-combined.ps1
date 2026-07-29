# Scenario: Combined Managed Configuration (scenario-x-combined)
# Sets up user settings, managed defaults, and locked settings to test
# multiple properties with different override/lock combinations.
#
# Properties tested:
#   preferences.appearance       — user only
#   feedback.dialog              — user + default
#   tasks.Toast                  — user + locked
#   terminal.integrated.lineHeight — locked only
#   preferences.zoomLevel        — default only
#   preferences.ExitOnClose      — default + locked

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

# Write user settings
@'
{
  "preferences.appearance": "system",
  "feedback.dialog": false,
  "tasks.Toast": true
}
'@ | Set-Content $UserSettingsFile -Encoding UTF8

# Write managed default settings
@'
{
  "feedback.dialog": true,
  "preferences.zoomLevel": 0.5,
  "preferences.ExitOnClose": false
}
'@ | Set-Content $DefaultSettingsFile -Encoding UTF8

# Write locked settings
@'
{
  "locked": [
    "terminal.integrated.lineHeight",
    "tasks.Toast",
    "preferences.ExitOnClose"
  ]
}
'@ | Set-Content $LockedFile -Encoding UTF8

Write-Host "Combined managed configuration applied."
Write-Host ""
Write-Host "Files written:"
Write-Host "  settings.json         -> $UserSettingsFile"
Write-Host "  default-settings.json -> $DefaultSettingsFile"
Write-Host "  locked.json           -> $LockedFile"
Write-Host ""
Write-Host "Properties to verify:"
Write-Host "  preferences.appearance            — user only (system)"
Write-Host "  feedback.dialog                   — user (false) overrides default (true)"
Write-Host "  tasks.Toast                       — user (true) + locked"
Write-Host "  terminal.integrated.lineHeight    — locked only (no value set)"
Write-Host "  preferences.zoomLevel             — default only (0.5)"
Write-Host "  preferences.ExitOnClose           — default (false) + locked"
