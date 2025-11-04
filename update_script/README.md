# 📦 PackageUpdater

A modular PowerShell CLI tool for updating `pip`, `Chocolatey`, and `winget` packages — with expressive logging, emoji feedback, version-aware narration, and emotionally scoped UX.

## 🚀 Features

- Modular update functions for `pip`, `choco`, and `winget`
- Smart detection of `pip` self-updates
- Version-aware narration with emoji and color-coded feedback
- Verbose duration formatting (e.g., `1 hour 2 minutes 03 seconds 045 milliseconds`)
- Summary panel with emotionally scoped closure
- Optional snapshot support for auditing (coming soon)
- Tab completion and help documentation included

## 📦 Installation

1. Use the PowerShell from the Windows Store to execute the script
  https://apps.microsoft.com/detail/9MZ1SNWT0N5D?hl=en-us&gl=US&ocid=pdpshare
2. Clone or copy the `PackageUpdater` folder to your PC.
3. Open PowerShell **as Administrator**.
4. Navigate to the folder:
   ```powershell
   cd "C:\Path\To\PackageUpdater"

## Run the Updater
Use the hybrid launcher script:
  .\Run-PackageUpdater.ps1

## This will:
- Elevate to admin if needed
- Import the module
- Enable tab completion
- Run all update functions
- Show a summary panel and error report

## Folder Structure
PackageUpdater/
├── PackageUpdater.psm1           # Core module with all update functions
├── PackageUpdater.psd1           # Module manifest
├── TabCompletion.ps1             # Tab completion setup
├── Run-PackageUpdater.ps1        # Hybrid launcher script
├── Docs/
│   └── Help.md                   # Function documentation
└── README.md                     # This file

## Available Functions
Import-Module .\PackageUpdater.psm1
- Update-PipPackages — Updates all outdated pip packages
- Update-ChocolateyPackages — Runs choco upgrade all with narration
- Update-WingetPackages — Updates all upgradable winget packages
- Update-PipSelf — Detects and updates pip itself only if needed

## Summary & Logging
- Show-SummaryPanel -Pip 3 -Choco 2 -Winget 5 -Duration (New-TimeSpan) -PipSelfUpdated $true
- Log-ErrorSummary — Displays any captured errors

## Optional Helpers
- Save-PackageSnapshot -Label "before" — (optional) capture installed package state

## Logging
$env:LOCALAPPDATA\PackageUpdateLogs

## Tab Completion
. .\TabCompletion.ps1

## Documentation
. .\Docs\Help.md

## Verbose Duration
Format-VerboseDuration 3661.045
# → "1 hour 1 minute 1 second 045 milliseconds"
