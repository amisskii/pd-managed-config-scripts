# Scenario: Proxy Managed Label (Issue #15206)
# Sets up proxy settings via managed configuration with locked fields,
# so the UI shows a "managed-by" label on the Proxy page.

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

# Write default-settings.json with proxy values
@'
{
  "proxy.http": "http://example.com:8080",
  "proxy.https": "http://example.com:8080",
  "proxy.no": "localhost"
}
'@ | Set-Content $DefaultSettingsFile -Encoding UTF8

# Write locked.json to lock proxy settings
@'
{
  "locked": ["proxy.http", "proxy.https", "proxy.no"]
}
'@ | Set-Content $LockedFile -Encoding UTF8

Write-Host "Proxy managed label config applied."
Write-Host "  default-settings.json : $DefaultSettingsFile"
Write-Host "  locked.json           : $LockedFile"
Write-Host ""
Write-Host "Start Podman Desktop and check the Proxy page for 'managed-by' labels."
