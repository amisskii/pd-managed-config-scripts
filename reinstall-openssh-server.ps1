# Requires Administrator privileges
#Requires -RunAsAdministrator

Write-Host "1. Stopping active SSH services..." -ForegroundColor Yellow
Stop-Service sshd, ssh-agent -ErrorAction SilentlyContinue

Write-Host "2. Removing existing OpenSSH Server and configuration..." -ForegroundColor Yellow
Remove-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0 -ErrorAction SilentlyContinue
Remove-Item -Path "C:\ProgramData\ssh" -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "3. Installing fresh OpenSSH Server..." -ForegroundColor Yellow
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0

Write-Host "4. Configuring firewall rules..." -ForegroundColor Yellow
if (!(Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -ErrorAction SilentlyContinue)) {
    New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
} else {
    Enable-NetFirewallRule -Name "OpenSSH-Server-In-TCP"
}

Write-Host "5. Setting default shell to PowerShell..." -ForegroundColor Yellow
New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -PropertyType String -Force | Out-Null

Write-Host "6. Starting SSH Service..." -ForegroundColor Yellow
Set-Service -Name sshd -StartupType Automatic
Start-Service sshd

Write-Host "OpenSSH Server reinstalled and running successfully!" -ForegroundColor Green
