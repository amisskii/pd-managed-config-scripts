# Scenario: Disable Extension Catalog (PR #16425)
# Sets extensions.catalog.enabled to false so the extension catalog
# is hidden from Extensions, Settings, Authentication, and Kubernetes pages.

$DefaultSettingsDir = "$env:PROGRAMDATA\Podman Desktop"
$DefaultSettingsFile = "$DefaultSettingsDir\default-settings.json"
$LockedFile = "$DefaultSettingsDir\locked.json"
$UserSettingsDir = "$env:USERPROFILE\.local\share\containers\podman-desktop\configuration"
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
  "extensions.catalog.enabled": false
}
'@, $Utf8NoBom)

# Write locked.json
[System.IO.File]::WriteAllText($LockedFile, @'
{
  "locked": ["extensions.catalog.enabled"]
}
'@, $Utf8NoBom)

Write-Host "Extension catalog disabled via managed config."
Write-Host "  default-settings.json : $DefaultSettingsFile"
Write-Host "  locked.json           : $LockedFile"
Write-Host ""
Write-Host "Start Podman Desktop - catalog should be hidden from Extensions,"
Write-Host "Settings, Authentication, and Kubernetes pages."
