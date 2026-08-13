# Scenario: Mock WSL Service Error for PR #17936
# Replaces podman.exe with a .cmd wrapper that returns a WSL service error
# when "machine list" is called, while forwarding all other commands to the
# real binary.
#
# Purpose: Reproduce the bug from https://github.com/podman-desktop/podman-desktop/issues/17420
# where a broken WSL causes Podman Desktop to show a misleading "Podman needs
# to be set up" notification instead of surfacing the actual WSL error.
#
# Requirements: Run as Administrator (needed to rename files in Program Files)
#
# Usage:
#   .\scenario-wsl-error-mock.ps1           # Apply the mock
#   .\scenario-wsl-error-mock.ps1 -Restore  # Restore the real binary

param(
    [switch]$Restore
)

# Locate podman.exe
$PodmanDir = if (Test-Path "$env:LOCALAPPDATA\Programs\Podman\podman.exe") {
    "$env:LOCALAPPDATA\Programs\Podman"
} elseif (Test-Path "${env:ProgramFiles}\RedHat\Podman\podman.exe") {
    "${env:ProgramFiles}\RedHat\Podman"
} else {
    $found = (Get-Command podman.exe -ErrorAction SilentlyContinue).Source
    if ($found) { Split-Path $found } else { $null }
}

if (-not $PodmanDir) {
    Write-Error "Could not find podman.exe. Ensure Podman is installed."
    exit 1
}

$PodmanExe  = "$PodmanDir\podman.exe"
$PodmanReal = "$PodmanDir\podman-real.exe"
$PodmanCmd  = "$PodmanDir\podman.cmd"

if ($Restore) {
    # --- Restore ---
    if (-not (Test-Path $PodmanReal)) {
        Write-Host "Nothing to restore: podman-real.exe not found."
        exit 0
    }
    Remove-Item $PodmanCmd -Force -ErrorAction SilentlyContinue
    Rename-Item $PodmanReal "podman.exe"
    Write-Host "Restored podman.exe from podman-real.exe."
    Write-Host "Verify: podman machine list"
    exit 0
}

# --- Apply ---
if (Test-Path $PodmanReal) {
    Write-Error "podman-real.exe already exists. Run with -Restore first."
    exit 1
}

if (-not (Test-Path $PodmanExe)) {
    Write-Error "podman.exe not found at $PodmanDir"
    exit 1
}

# Rename the real binary
Rename-Item $PodmanExe "podman-real.exe"

# Create the .cmd wrapper
$WrapperContent = @"
@echo off
echo %* | findstr /i "machine list" >nul
if %errorlevel%==0 (
    echo Error: command C:\WINDOWS\system32\wsl.exe failed: exit status 0xffffffff 1>&2
    echo Wsl/Service/E_UNEXPECTED 1>&2
    exit /b 1
)
"$PodmanDir\podman-real.exe" %*
"@

[System.IO.File]::WriteAllText($PodmanCmd, $WrapperContent, [System.Text.Encoding]::ASCII)

Write-Host "WSL error mock applied."
Write-Host ""
Write-Host "What changed:"
Write-Host "  Renamed: podman.exe -> podman-real.exe"
Write-Host "  Created: podman.cmd (returns WSL error on 'machine list')"
Write-Host "  Path:    $PodmanDir"
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Open Podman Desktop"
Write-Host "  2. Verify the WSL warning appears (not 'Podman needs to be set up')"
Write-Host "  3. Run: .\scenario-wsl-error-mock.ps1 -Restore"
