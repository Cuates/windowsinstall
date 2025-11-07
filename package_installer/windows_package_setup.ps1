# bootstrap.ps1

# Elevation check (non-invasive)
If (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script must be run as Administrator. Please reopen your terminal with elevated privileges and try again." -ForegroundColor Red
    Exit 1
}

$choice = Read-Host "Choose installer (pip/choco/winget)"

# Ensure Winget is available if using winget
if ($choice -eq "winget") {
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Error "Winget is not available. Please ensure you're running Windows 11 with the latest updates."
        exit 1
    }
}

# Ensure Chocolatey is installed if using choco
if ($choice -eq "choco") {
    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        Write-Host "Chocolatey not found. Installing..."
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        Start-Sleep -Seconds 10
    }

    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        Write-Error "Chocolatey installation failed. Please check your system and try again."
        exit 1
    }
}

# Check if Python is installed via Winget
$pythonInstalled = winget list | Select-String "Python.Python.3"
if (-not $pythonInstalled) {
    Write-Host "Python is not installed. Searching for latest Python 3.x package via Winget..."

    $latestPythonId = winget search python |
        Where-Object { $_ -match "Python\.Python\.3\.\d+" } |
        ForEach-Object {
            $fields = ($_ -replace '\s{2,}', '|').Split('|')
            [PSCustomObject]@{
                Id      = $fields[1]
                Version = $fields[2]
            }
        } |
        Sort-Object { [Version]$_.Version } -Descending |
        Select-Object -First 1

    if ($null -eq $latestPythonId) {
        Write-Error "Could not find a valid Python 3.x package via Winget. Try 'winget source reset --force' and 'winget source update'."
        exit 1
    }

    $pythonId = $latestPythonId.Id
    Write-Host "🔍 Installing latest Python package: $pythonId"
    winget install --id $pythonId --silent --accept-package-agreements --accept-source-agreements

    Write-Host "`nPython installation initiated. Please close and reopen your PowerShell terminal as administrator before running this script again." -ForegroundColor Yellow
    exit 0
}

# Run Python installer script
python install_packages.py $choice