# Scenario: Disable Local Extensions (PR #16457)
# Sets extensions.localExtensions.enabled to false so the
# "Local Extensions" tab is hidden in the Extensions section.
#
# Usage:
#   .\scenario-disable-local-extensions.ps1 [community|redhat]
#   $env:PD_BUILD = 'redhat'; .\scenario-disable-local-extensions.ps1
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

# Write default-settings.json
[System.IO.File]::WriteAllText($DefaultSettingsFile, @'
{
  "extensions.localExtensions.enabled": false
}
'@, $Utf8NoBom)

# Write locked.json
[System.IO.File]::WriteAllText($LockedFile, @'
{
  "locked": ["extensions.localExtensions.enabled"]
}
'@, $Utf8NoBom)

Write-Host "Local extensions disabled via managed config."
Write-Host "  default-settings.json : $DefaultSettingsFile"
Write-Host "  locked.json           : $LockedFile"
Write-Host ""
Write-Host "Start Podman Desktop - the 'Local Extensions' tab should be hidden."
