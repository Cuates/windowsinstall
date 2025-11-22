# Run-PackageUpdater.ps1
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Elevate if not admin
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "🔐 Administrator Terminal Is Needed..." -ForegroundColor Yellow
    exit
}

# Import module
$modulePath = Join-Path $PSScriptRoot 'PackageUpdater.psm1'
if (-not (Test-Path $modulePath)) {
    Write-Host "❌ Could not find PackageUpdater.psm1 in $PSScriptRoot" -ForegroundColor Red
    exit 1
}
Import-Module $modulePath -Force

# # Initialize log folder exists
# Initialize-LogFolder

# Load tab completion
$tabPath = Join-Path $PSScriptRoot 'TabCompletion.ps1'
if (Test-Path $tabPath) {
    . $tabPath
}

# 🧾 Show startup header
Clear-Host
Write-FancyHeader "PACKAGE UPDATER"
Write-Host "  Started: " -NoNewline -ForegroundColor Gray
Write-Host (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -ForegroundColor White
Write-Host "  Log: " -NoNewline -ForegroundColor Gray
Write-Host (Get-LogFilePath) -ForegroundColor White

# Run update workflow
$start = Get-Date
# Save-PackageSnapshot -Label "before"

$pip = Update-PipPackages
$choco = Update-ChocolateyPackages
$winget = Update-WingetPackages

# Save-PackageSnapshot -Label "after"
$duration = (Get-Date) - $start

Show-SummaryPanel -Pip $pip.Count -Choco $choco.Count -Winget $winget -Duration $duration -PipSelfUpdated $pip.PipSelfUpdated -ChocoSkipped $choco.Skipped
Show-ErrorSummary

# Optional: graceful exit countdown
Write-Host ""
for ($i = 5; $i -gt 0; $i--) {
    Write-Host "  Closing in $i seconds... Press any key to exit now." -NoNewline -ForegroundColor Cyan
    if ([Console]::KeyAvailable) {
        $null = [Console]::ReadKey($true)
        break
    }
    Start-Sleep -Seconds 1
}
Write-Host ""