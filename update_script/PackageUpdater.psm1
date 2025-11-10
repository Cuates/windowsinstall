Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$OutputEncoding = [System.Text.Encoding]::UTF8

# Global setup
# $script:LogDir = "$env:LOCALAPPDATA\PackageUpdateLogs"
# $script:LogFile = Join-Path $script:LogDir "update_$(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss').log"
$scriptRoot = $MyInvocation.MyCommand.Path | Split-Path
$script:LogFile = Join-Path $scriptRoot "update_$(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss').log"
$script:Errors = @()

function Write-Log {
    param(
        [Parameter(Mandatory)]
        [string]$Message,
        [ValidateSet('INFO','WARN','ERROR','DEBUG','SUCCESS')]
        [string]$Level = 'INFO'
    )
    if (-not [string]::IsNullOrWhiteSpace($Message)) {
        $cleanMessage = $Message.Trim()
        $cleanLevel = if ($null -ne $Level) { $Level.Trim() } else { "" }
        $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
        $formattedMessage = "[{0}] [{1}] {2}" -f $timestamp, $cleanLevel, $cleanMessage
        Add-Content -Path $script:LogFile -Value $formattedMessage -Encoding UTF8

        $icon = switch ($cleanLevel) {
            'INFO'    { '🛈'; $color = 'White' }
            'WARN'    { '⚠️'; $color = 'Yellow' }
            'ERROR'   { '❌'; $color = 'Red' }
            'DEBUG'   { '🔍'; $color = 'DarkGray' }
            'SUCCESS' { '✅'; $color = 'Green' }
        }

        Write-Host "$icon $cleanMessage" -ForegroundColor $color
    }
}

function Write-LogLine {
    param([string]$Message)
    if (-not [string]::IsNullOrWhiteSpace($Message)) {
        $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
        $formattedMessage = "[{0}] {1}" -f $timestamp, $Message.Trim()
        Add-Content -Path $script:LogFile -Value $formattedMessage -Encoding UTF8
    }
}

# function Initialize-LogFolder {
#     $logFolder = Join-Path $env:LOCALAPPDATA 'PackageUpdateLogs'
#     if (-not (Test-Path $logFolder)) {
#         try {
#             New-Item -Path $logFolder -ItemType Directory -Force | Out-Null
#             Write-Log "Created log folder: $logFolder" -Level 'INFO'
#         } catch {
#             Write-Log "Failed to create log folder: $logFolder" -Level 'ERROR'
#             throw $_
#         }
#     }
# }

function Write-ExceptionDetails {
    param([System.Exception]$ex)
    Write-Log "Error: $($ex.Message)" -Level 'ERROR'
    Write-Log "Type: $($ex.GetType().FullName)" -Level 'DEBUG'
    Write-Log "StackTrace:`n$($ex.StackTrace)" -Level 'DEBUG'
}

function Write-FancyHeader {
    param([string]$Title)
    $line = "=" * 60
    Write-Host "`n+$line+" -ForegroundColor White
    Write-Host "|$('{0,-60}' -f $Title)|" -ForegroundColor White
    Write-Host "+$line+`n" -ForegroundColor White
}

function Save-PackageSnapshot {
    param([string]$Label)
    try {
        $snapshot = Get-Package | Select-Object Name, Version
        $snapshot | ConvertTo-Json -Depth 3 | Set-Content "$script:LogDir\snapshot_$Label.json"
        Write-Log "Saved snapshot: $Label" -Level 'DEBUG'
    } catch {
        Write-ExceptionDetails -ex $_.Exception
        $script:Errors += "Snapshot failed: $Label"
    }
}

function Show-SummaryPanel {
    param(
        [int]$Pip,
        [int]$Choco,
        [int]$Winget,
        [TimeSpan]$Duration,
        [Nullable[bool]]$PipSelfUpdated,
        [bool]$ChocoSkipped
    )
    Write-FancyHeader "UPDATE SUMMARY"
    # "+==== UPDATE SUMMARY ====+" | Add-Content -Path $script:LogFile
    Write-LogLine "+==== UPDATE SUMMARY ====+"

    if ($null -eq $PipSelfUpdated) {
        Write-Host "🧪 pip self-update skipped (Python not found)" -ForegroundColor DarkGray
        # "pip self-update skipped (Python not found)" | Add-Content -Path $script:LogFile
        Write-LogLine "pip self-update skipped (Python not found)"
    } elseif ($PipSelfUpdated) {
        Write-Host "🧪 pip itself was updated" -ForegroundColor Cyan
        # "pip itself was updated" | Add-Content -Path $script:LogFile
        Write-LogLine "pip itself was updated"
        Write-Host "✅ Pip: $Pip updated" -ForegroundColor Green
        # "Pip: $Pip updated" | Add-Content -Path $script:LogFile
        Write-LogLine "Pip: $Pip updated"
    } else {
        Write-Host "🧪 pip itself was already up to date" -ForegroundColor Gray
        # "pip itself was already up to date" | Add-Content -Path $script:LogFile
        Write-LogLine "pip itself was already up to date"
        Write-Host "✅ Pip: $Pip updated" -ForegroundColor Green
        # "Pip: $Pip updated" | Add-Content -Path $script:LogFile
        Write-LogLine "Pip: $Pip updated"
    }

    if ($ChocoSkipped) {
        Write-Host "⚪ Chocolatey not found. Skipped." -ForegroundColor DarkGray
        # "Chocolatey not found. Skipped." | Add-Content -Path $script:LogFile
        Write-LogLine "Chocolatey not found. Skipped."
    } else {
        Write-Host "✅ Choco: $Choco updated" -ForegroundColor Green
        # "Choco: $Choco updated" | Add-Content -Path $script:LogFile
        Write-LogLine "Choco: $Choco updated"
    }

    Write-Host "✅ Winget: $Winget updated" -ForegroundColor Green
    # "Winget: $Winget updated" | Add-Content -Path $script:LogFile
    Write-LogLine "Winget: $Winget updated"

    Write-Host "🕒 Duration: $(Format-VerboseDuration $Duration.TotalSeconds)" -ForegroundColor White
    # "Duration: $(Format-VerboseDuration $Duration.TotalSeconds)" | Add-Content -Path $script:LogFile
    Write-LogLine "Duration: $(Format-VerboseDuration $Duration.TotalSeconds)"
}

function Show-ErrorSummary {
    if ($script:Errors.Count -gt 0) {
        Write-FancyHeader "ERROR SUMMARY"
        $script:Errors | ForEach-Object { Write-Host "❌ $_" -ForegroundColor Red }
    }
}

function Get-LogFilePath {
    return $script:LogFile
}

function Format-VerboseDuration {
    param([double]$Seconds)
    $totalMs = [math]::Round($Seconds * 1000)
    $hours = [math]::Floor($totalMs / 3600000)
    $minutes = [math]::Floor(($totalMs % 3600000) / 60000)
    $seconds = [math]::Floor(($totalMs % 60000) / 1000)
    $milliseconds = $totalMs % 1000

    function Pluralize ($value, $unit) {
        return "$value $unit" + ($(if ($value -eq 1) { "" } else { "s" }))
    }

    $parts = @()
    if ($hours -gt 0)       { $parts += Pluralize $hours 'hour' }
    if ($minutes -gt 0)     { $parts += Pluralize $minutes 'minute' }
    if ($seconds -gt 0)     { $parts += Pluralize $seconds 'second' }
    $parts += ("{0:D3} millisecond{1}" -f [int]$milliseconds, $(if ($milliseconds -eq 1) { "" } else { "s" }))
    return $parts -join ' '
}

function Test-PythonAvailable {
    if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
        return $false
    }
    try {
        $version = python --version 2>&1
        if ($version -match 'Microsoft Store') {
            return $false
        }
        return $true
    } catch {
        return $false
    }
}

function Update-PipSelf {
    # "+==== Update PIP Itself ====+" | Add-Content -Path $script:LogFile
    Write-LogLine "+==== Update PIP Itself ====+"
    Write-FancyHeader "Updating pip itself"

    if (-not (Test-PythonAvailable)) {
        Write-Log "Python not found or alias detected. Skipping pip self-update." -Level 'WARN'
        return $null
    }

    try {
        Write-Host "🔍 Checking for pip self-update..." -ForegroundColor Cyan
        Write-LogLine "Checking for pip self-update..."
        $output = python -m pip install --upgrade pip 2>&1
        $output | ForEach-Object {
            if ($_ -notmatch '^WARNING: Ignoring') {
                Write-Host $_ -ForegroundColor Gray
                # Add-Content -Path $script:LogFile -Value $_ -Encoding UTF8
                Write-LogLine $_

            }
        }

        if ($output -match 'Requirement already satisfied: pip') {
            Write-Log "pip is already up to date." -Level 'SUCCESS'
            return $false
        }

        Write-Log "pip updated successfully." -Level 'SUCCESS'
        return $true
    } catch {
        Write-ExceptionDetails -ex $_.Exception
        $script:Errors += "pip self-update failed"
        return $false
    }
}

function Update-PipPackages {
    $pipSelfUpdated = Update-PipSelf

    # "+==== Update PIP Packages ====+" | Add-Content -Path $script:LogFile
    Write-LogLine "+==== Update PIP Packages ====+"
    Write-FancyHeader "Python Pip Packages"

    if (-not (Test-PythonAvailable)) {
        Write-Log "Python not found or alias detected. Skipping pip packages." -Level 'WARN'
        return @{ Count = 0; PipSelfUpdated = $null }
    }

    try {
        Write-Host "🔍 Checking for outdated pip packages..." -ForegroundColor Cyan
        Write-LogLine "Checking for outdated pip packages..."
        $outdated = python -m pip list --outdated --format=json 2>&1 | Out-String
        $json = ($outdated -split "`n" | Where-Object { $_ -notmatch '^(WARNING|\[notice\]|pip._vendor)' }) -join ''
        if ([string]::IsNullOrWhiteSpace($json) -or $json -eq '[]') {
            Write-Log "All pip packages are up to date!" -Level 'SUCCESS'
            return @{ Count = 0; PipSelfUpdated = $pipSelfUpdated }
        }

        $list = $json | ConvertFrom-Json
        if (-not $list -or -not ($list -is [System.Collections.IEnumerable])) {
            Write-Log "All pip packages are up to date!" -Level 'SUCCESS'
            return @{ Count = 0; PipSelfUpdated = $pipSelfUpdated }
        }

        $count = $list.Count
        Write-Host "📦 Found $count outdated package(s)`n" -ForegroundColor Cyan
        $i = 0
        foreach ($pkg in $list) {
            $i++
            Write-Host "[$i/$count] Updating $($pkg.name): $($pkg.version) → $($pkg.latest_version)" -ForegroundColor Yellow
            try {
                python -m pip install --upgrade $pkg.name 2>&1 | Tee-Object -Variable pipOutput | ForEach-Object {
                    Write-Host $_ -ForegroundColor Gray
                    # Add-Content -Path $script:LogFile -Value $_ -Encoding UTF8
                    Write-LogLine $_

                }
            } catch {
                Write-ExceptionDetails -ex $_.Exception
                $script:Errors += "Failed to update $($pkg.name)"
            }
        }

        Write-Log "Pip packages updated." -Level 'SUCCESS'
        return @{ Count = $count; PipSelfUpdated = $pipSelfUpdated }
    } catch {
        Write-ExceptionDetails -ex $_.Exception
        $script:Errors += "pip list failed"
        return @{ Count = 0; PipSelfUpdated = $pipSelfUpdated }
    }
}

function Update-ChocolateyPackages {
    # "+==== Update Chocolatey Packages ====+" | Add-Content -Path $script:LogFile
    Write-LogLine "+==== Update Chocolatey Packages ====+"
    Write-FancyHeader "Chocolatey Packages"

    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        Write-Log "Chocolatey not found. Skipping." -Level 'WARN'
        return @{ Count = 0; Skipped = $true }
    }

    try {
        Write-Host "🔍 Starting Chocolatey upgrade..." -ForegroundColor Cyan
        Write-LogLine "Starting Chocolatey upgrade..."
        cmd /c "choco upgrade all -y --no-progress" | Tee-Object -Variable chocoOutput | ForEach-Object {
            Write-Host $_ -ForegroundColor Gray
            # Add-Content -Path $script:LogFile -Value $_ -Encoding UTF8
            Write-LogLine $_

        }

        $count = 0
        foreach ($line in $chocoOutput) {
            if ($line -match 'Chocolatey upgraded (\d+)/\d+ packages') {
                $count = [int]$matches[1]
                break
            }
        }

        if ($count -eq 0 -or $chocoOutput -match 'No packages to upgrade|already up to date') {
            Write-Log "All Chocolatey packages are up to date!" -Level 'SUCCESS'
            return @{ Count = 0; Skipped = $false }
        }

        Write-Log "Chocolatey packages updated: $count" -Level 'SUCCESS'
        return @{ Count = $count; Skipped = $false }
    } catch {
        Write-ExceptionDetails -ex $_.Exception
        $script:Errors += "Chocolatey update failed"
        return @{ Count = 0; Skipped = $false }
    }
}

function Update-WingetPackages {
    # "+==== Update Winget Packages ====+" | Add-Content -Path $script:LogFile
    Write-LogLine "+==== Update Winget Packages ====+"
    Write-FancyHeader "Winget Packages"

    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Log "Winget not found. Skipping." -Level 'WARN'
        return 0
    }

    try {
        Write-Host "🔍 Starting Winget upgrade..." -ForegroundColor Cyan
        Write-LogLine "Starting Winget upgrade..."

        $upgradable = winget upgrade --accept-source-agreements 2>&1
        # Add-Content -Path $script:LogFile -Value $upgradable -Encoding UTF8
        # Write-LogLine $upgradable


        if ($upgradable -match "No installed package found|No applicable update found") {
            Write-Log "All winget packages are up to date!" -Level 'SUCCESS'
            return 0
        }

        Write-Host "📦 Packages to upgrade:" -ForegroundColor Cyan
        $upgradable -split "`n" | Where-Object { $_ -match '^\s*\S+\s+\S+\s+\S+' } | ForEach-Object {
            Write-Host "  $_" -ForegroundColor Gray
        }

        $job = Start-Job {
            winget upgrade --all --silent --accept-source-agreements --accept-package-agreements 2>&1
        }

        $spin = @('|','/','-','\'); $i = 0
        while ($job.State -eq 'Running') {
            Write-Host "`r$($spin[$i]) Updating..." -NoNewline -ForegroundColor Cyan
            $i = ($i + 1) % $spin.Count
            Start-Sleep -Milliseconds 100
        }

        $output = Receive-Job $job
        Remove-Job $job

        # 🔄 Post-upgrade narration
        $output | ForEach-Object {
            # Write-Host $_ -ForegroundColor Gray
            # Add-Content -Path $script:LogFile -Value $_ -Encoding UTF8
            Write-LogLine $_
        }

        Write-Host "`r✅ Winget packages updated!        " -ForegroundColor Green
        # "Winget packages updated successfully." | Add-Content -Path $script:LogFile
        Write-LogLine "Winget packages updated successfully."

        return 1
    } catch {
        Write-ExceptionDetails -ex $_.Exception
        $script:Errors += "Winget update failed"
        return 0
    }
}

Export-ModuleMember -Function Update-PipPackages, Update-ChocolateyPackages, Update-WingetPackages, Update-PipSelf, Save-PackageSnapshot, Show-SummaryPanel, Show-ErrorSummary, Write-FancyHeader, Get-LogFilePath, Test-PythonAvailable

# Export-ModuleMember -Function Update-PipPackages, Update-ChocolateyPackages, Update-WingetPackages, Update-PipSelf, Save-PackageSnapshot, Show-SummaryPanel, Show-ErrorSummary, Write-FancyHeader, Get-LogFilePath, Initialize-LogFolder, Test-PythonAvailable