# Scenario: Disable App Update (PR #17682, closes #16483)
# Sets preferences.update.appUpdate to false so Podman Desktop does not
# check for application updates on startup or present update prompts.

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
  "preferences.update.appUpdate": false
}
'@, $Utf8NoBom)

# Write locked.json
[System.IO.File]::WriteAllText($LockedFile, @'
{
  "locked": ["preferences.update.appUpdate"]
}
'@, $Utf8NoBom)

Write-Host "App update disabled via managed config."
Write-Host "  default-settings.json : $DefaultSettingsFile"
Write-Host "  locked.json           : $LockedFile"
Write-Host ""
Write-Host "Start Podman Desktop - it should not check for updates or show"
Write-Host "update prompts. The App Update preference should show a lock icon."
