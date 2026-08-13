# Scenario: Mock WSL Service Error for PR #17936
# Creates a mock podman.exe that returns a WSL service error when
# "machine list" is called, while forwarding all other commands to
# the real binary (saved as podman-real.exe).
#
# Purpose: Reproduce the bug from https://github.com/podman-desktop/podman-desktop/issues/17420
# where a broken WSL causes Podman Desktop to show a misleading "Podman needs
# to be set up" notification instead of surfacing the actual WSL error.
#
# Why rename is required: Podman Desktop uses Node.js spawn('podman.exe') directly,
# not through a shell, so .cmd/.bat wrappers won't be found. The only way to
# intercept is to replace the actual podman.exe.
#
# Safety: The original binary is preserved as podman-real.exe. The -Restore flag
# swaps it back. If the script is interrupted mid-apply, both files exist.
#
# Requirements: Run as Administrator
#
# Usage:
#   .\scenario-wsl-error-mock.ps1           # Apply the mock
#   .\scenario-wsl-error-mock.ps1 -Restore  # Restore the real binary

param(
    [switch]$Restore
)

# Locate podman.exe or podman-real.exe (for restore)
$PodmanDir = if (Test-Path "$env:LOCALAPPDATA\Programs\Podman\podman.exe") {
    "$env:LOCALAPPDATA\Programs\Podman"
} elseif (Test-Path "$env:LOCALAPPDATA\Programs\Podman\podman-real.exe") {
    "$env:LOCALAPPDATA\Programs\Podman"
} elseif (Test-Path "${env:ProgramFiles}\RedHat\Podman\podman.exe") {
    "${env:ProgramFiles}\RedHat\Podman"
} elseif (Test-Path "${env:ProgramFiles}\RedHat\Podman\podman-real.exe") {
    "${env:ProgramFiles}\RedHat\Podman"
} else {
    $found = (Get-Command podman.exe -ErrorAction SilentlyContinue).Source
    if ($found) { Split-Path $found } else { $null }
}

if (-not $PodmanDir) {
    Write-Error "Could not find podman installation directory."
    exit 1
}

$PodmanExe  = "$PodmanDir\podman.exe"
$PodmanReal = "$PodmanDir\podman-real.exe"

if ($Restore) {
    if (-not (Test-Path $PodmanReal)) {
        Write-Host "Nothing to restore: podman-real.exe not found at $PodmanDir"
        exit 0
    }
    Remove-Item $PodmanExe -Force -ErrorAction SilentlyContinue
    Rename-Item $PodmanReal "podman.exe"
    Write-Host "Restored original podman.exe"
    Write-Host "Verify: podman machine list"
    exit 0
}

# --- Apply ---
if (Test-Path $PodmanReal) {
    Write-Error "podman-real.exe already exists at $PodmanDir. Run with -Restore first."
    exit 1
}

if (-not (Test-Path $PodmanExe)) {
    Write-Error "podman.exe not found at $PodmanDir"
    exit 1
}

# Step 1: Copy original as backup (original stays in place)
Copy-Item $PodmanExe $PodmanReal

# Step 2: Create a small C# wrapper exe that mimics WSL error on "machine list"
$WrapperSource = @'
using System;
using System.Diagnostics;
using System.IO;
using System.Linq;

class PodmanMock {
    static int Main(string[] args) {
        string joined = string.Join(" ", args).ToLower();
        if (joined.Contains("machine") && joined.Contains("list")) {
            Console.Error.WriteLine("Error: command C:\\WINDOWS\\system32\\wsl.exe failed: exit status 0xffffffff");
            Console.Error.WriteLine("Wsl/Service/E_UNEXPECTED");
            return 1;
        }
        // Forward to real podman
        string dir = Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().Location);
        string realPodman = Path.Combine(dir, "podman-real.exe");
        var psi = new ProcessStartInfo {
            FileName = realPodman,
            UseShellExecute = false,
            RedirectStandardOutput = true,
            RedirectStandardError = true
        };
        foreach (var arg in args) psi.ArgumentList.Add(arg);
        var proc = Process.Start(psi);
        Console.Write(proc.StandardOutput.ReadToEnd());
        Console.Error.Write(proc.StandardError.ReadToEnd());
        proc.WaitForExit();
        return proc.ExitCode;
    }
}
'@

# Compile the wrapper using the .NET C# compiler available on Windows
$TempCs = "$env:TEMP\podman-mock.cs"
[System.IO.File]::WriteAllText($TempCs, $WrapperSource, [System.Text.UTF8Encoding]::new($false))

# Find csc.exe from .NET Framework
$CscPath = Join-Path ([System.Runtime.InteropServices.RuntimeEnvironment]::GetRuntimeDirectory()) "csc.exe"
if (-not (Test-Path $CscPath)) {
    # Fallback: search in .NET Framework directories
    $CscPath = Get-ChildItem "C:\Windows\Microsoft.NET\Framework64\*\csc.exe" -ErrorAction SilentlyContinue | Sort-Object FullName -Descending | Select-Object -First 1 -ExpandProperty FullName
}

if (-not $CscPath) {
    Write-Error "C# compiler (csc.exe) not found. Cannot create wrapper."
    # Clean up: remove backup since we can't complete
    Remove-Item $PodmanReal -Force -ErrorAction SilentlyContinue
    exit 1
}

$TempExe = "$env:TEMP\podman-mock.exe"
$compileResult = & $CscPath /nologo /out:$TempExe /target:exe $TempCs 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Error "Compilation failed: $compileResult"
    Remove-Item $PodmanReal -Force -ErrorAction SilentlyContinue
    exit 1
}

# Step 3: Replace podman.exe with the compiled wrapper
Remove-Item $PodmanExe -Force
Move-Item $TempExe $PodmanExe

# Clean up temp files
Remove-Item $TempCs -Force -ErrorAction SilentlyContinue

Write-Host "WSL error mock applied."
Write-Host ""
Write-Host "What changed:"
Write-Host "  Backup:  podman.exe -> podman-real.exe"
Write-Host "  Replaced: podman.exe with mock wrapper"
Write-Host "  Path:    $PodmanDir"
Write-Host ""
Write-Host "The mock returns 'Wsl/Service/E_UNEXPECTED' for 'podman machine list'"
Write-Host "and forwards all other commands to podman-real.exe."
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Verify:  podman machine list  (should show WSL error)"
Write-Host "  2. Verify:  podman --version     (should work normally)"
Write-Host "  3. Open Podman Desktop and check for WSL warning"
Write-Host "  4. Restore: .\scenario-wsl-error-mock.ps1 -Restore"
