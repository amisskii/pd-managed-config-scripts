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
#   .\scenario-combined.ps1 [community|redhat]
#   $env:PD_BUILD = 'redhat'; .\scenario-combined.ps1
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

$Utf8NoBom = New-Object System.Text.UTF8Encoding $false

# Clean up existing files
Remove-Item $UserSettingsFile -Force -ErrorAction SilentlyContinue
Remove-Item $LockedFile -Force -ErrorAction SilentlyContinue
Remove-Item $DefaultSettingsFile -Force -ErrorAction SilentlyContinue

# Create directories
New-Item -ItemType Directory -Force -Path $DefaultSettingsDir | Out-Null
New-Item -ItemType Directory -Force -Path $UserSettingsDir | Out-Null

# Write user settings
[System.IO.File]::WriteAllText($UserSettingsFile, @'
{
  "preferences.appearance": "system",
  "feedback.dialog": false,
  "tasks.Toast": true
}
'@, $Utf8NoBom)

# Write managed default settings
[System.IO.File]::WriteAllText($DefaultSettingsFile, @'
{
  "feedback.dialog": true,
  "preferences.zoomLevel": 0.5,
  "preferences.ExitOnClose": false
}
'@, $Utf8NoBom)

# Write locked settings
[System.IO.File]::WriteAllText($LockedFile, @'
{
  "locked": [
    "terminal.integrated.lineHeight",
    "tasks.Toast",
    "preferences.ExitOnClose"
  ]
}
'@, $Utf8NoBom)

Write-Host "Combined managed configuration applied."
Write-Host ""
Write-Host "Files written:"
Write-Host "  settings.json         : $UserSettingsFile"
Write-Host "  default-settings.json : $DefaultSettingsFile"
Write-Host "  locked.json           : $LockedFile"
Write-Host ""
Write-Host "Properties to verify:"
Write-Host "  preferences.appearance            - user only (system)"
Write-Host "  feedback.dialog                   - user (false) overrides default (true)"
Write-Host "  tasks.Toast                       - user (true) + locked"
Write-Host "  terminal.integrated.lineHeight    - locked only (no value set)"
Write-Host "  preferences.zoomLevel             - default only (0.5)"
Write-Host "  preferences.ExitOnClose           - default (false) + locked"
