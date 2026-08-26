# Scenario: Restrict Provider Updates (PR #17878, closes #17877, #16484)
# Sets providers.allowUpdate to an allow-list of extension IDs that may
# register provider engine updates. Default is ["*"] (allow all);
# [] blocks all; ["podman-desktop.podman"] allows only Podman.
# This scenario blocks all providers from showing the update button.

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

# Write default-settings.json (block all provider updates)
[System.IO.File]::WriteAllText($DefaultSettingsFile, @'
{
  "providers.allowUpdate": []
}
'@, $Utf8NoBom)

# Write locked.json
[System.IO.File]::WriteAllText($LockedFile, @'
{
  "locked": ["providers.allowUpdate"]
}
'@, $Utf8NoBom)

Write-Host "Provider updates restricted via managed config (allow-list: none)."
Write-Host "  default-settings.json : $DefaultSettingsFile"
Write-Host "  locked.json           : $LockedFile"
Write-Host ""
Write-Host "Start Podman Desktop and check the Resources page - the update"
Write-Host "button should not appear on any provider card."
Write-Host "Check logs for: Provider update registration blocked for extension"
Write-Host "'<id>' by providers.allowUpdate configuration"
Write-Host ""
Write-Host "To allow only specific providers instead, replace [] above with"
Write-Host "e.g. [`"podman-desktop.podman`"]."
