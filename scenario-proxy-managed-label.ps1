# Scenario: Proxy Managed Label (Issue #15206)
# Sets up proxy settings via managed configuration with locked fields,
# so the UI shows a "managed-by" label on the Proxy page.
#
# Usage:
#   .\scenario-proxy-managed-label.ps1 [community|redhat]
#   $env:PD_BUILD = 'redhat'; .\scenario-proxy-managed-label.ps1
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

# Write default-settings.json with proxy values
[System.IO.File]::WriteAllText($DefaultSettingsFile, @'
{
  "proxy.http": "http://example.com:8080",
  "proxy.https": "http://example.com:8080",
  "proxy.no": "localhost"
}
'@, $Utf8NoBom)

# Write locked.json to lock proxy settings
[System.IO.File]::WriteAllText($LockedFile, @'
{
  "locked": ["proxy.http", "proxy.https", "proxy.no"]
}
'@, $Utf8NoBom)

Write-Host "Proxy managed label config applied."
Write-Host "  default-settings.json : $DefaultSettingsFile"
Write-Host "  locked.json           : $LockedFile"
Write-Host ""
Write-Host "Start Podman Desktop and check the Proxy page for managed-by labels."
