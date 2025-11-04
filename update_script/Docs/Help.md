# 📦 PackageUpdater Module

## 🧭 Overview

PackageUpdater is a modular PowerShell CLI tool for updating `pip`, `Chocolatey`, and `winget` packages with expressive logging, emoji feedback, and emotionally scoped UX. It narrates version changes, detects pip self-updates, formats durations verbosely, and provides a summary panel with clear emotional closure.

---

## Requirement
Use the PowerShell from the Windows Store to execute the script
  https://apps.microsoft.com/detail/9MZ1SNWT0N5D?hl=en-us&gl=US&ocid=pdpshare

## 🧰 Functions

### `Update-PipSelf`

- Detects whether `pip` itself needs updating.
- Runs `python -m pip install --upgrade pip`.
- Narrates outcome:
  - ✅ `"pip updated successfully"` if updated
  - 🧪 `"pip is already up to date"` if no update needed
  - ❌ `"pip self-update failed"` if an error occurs
- Logs output and errors with full stack trace.

---

### `Update-PipPackages`

- Scans for outdated pip packages using `pip list --outdated`.
- Updates each package individually with:
  ```powershell
  python -m pip install --upgrade <package>

- Narrates each update with:
- Package name
- From → To version
- Emoji and color-coded feedback
- Returns count of successfully updated packages.

### Update-ChocolateyPackages
Upgrades all Chocolatey packages using `choco upgrade all -y --no-progress`.
- Parses output to detect whether any packages were updated.
- Narrates:
- ✅ "Chocolatey packages updated" if changes occurred
- 🧪 "All Chocolatey packages are up to date" if nothing changed
- Logs raw output and errors.

### Update-WingetPackages
- Uses winget upgrade to detect updatable packages.
- Updates each package silently via background jobs.
- Displays spinner animation during updates.
- Narrates each update with:
- Package name
- From → To version
- Emoji and color-coded feedback
- Returns count of successfully updated packages.

### Save-PackageSnapshot
- Captures a snapshot of installed packages and versions.
- Saves to a timestamped JSON file in the log directory.
- Useful for auditing, rollback planning, or before/after comparisons.
- Optional and modular — can be toggled via config

### Show-SummaryPanel
- Displays a summary of update results:
- ✅ Pip, Chocolatey, Winget counts
- 🧪 Pip self-update status
- 🕒 Duration (formatted as 1 hour 2 minutes 03 seconds 045 milliseconds)
- Uses emoji and color-coded feedback for emotional clarity.

### Log-ErrorSummary
- Displays all errors captured during the update process.
- Each error includes:
- Source function
- Exception message
- Stack trace (if available)
- Narrated with ❌ emoji and red foreground color.

## Logging
All functions log to a timestamped file in:
$env:LOCALAPPDATA\PackageUpdateLogs

## Helper
- Converts raw seconds into expressive time strings:
Format-VerboseDuration 3661.045
# → "1 hour 1 minute 1 second 045 milliseconds"
- Only includes non-zero units.
- Pads milliseconds to 3 digits.
- Used in summary panel and duration narration.

Tab Completion
- Enable tab completion for all exported functions and parameters:
. .\TabCompletion.ps1

## Usage Example
Import-Module .\PackageUpdater.psm1
Update-PipSelf
Update-PipPackages
Update-ChocolateyPackages
Update-WingetPackages
Show-SummaryPanel -Pip 3 -Choco 2 -Winget 5 -Duration $duration -PipSelfUpdated $true
Log-ErrorSummary
