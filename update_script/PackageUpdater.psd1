@{
    # Script module file associated with this manifest
    RootModule = 'PackageUpdater.psm1'

    # Version number of this module
    ModuleVersion = '1.0.0'

    # Unique identifier for this module
    GUID = 'd3f9c7e2-1a2b-4e5f-9c3e-abc123456789'

    # Author of this module
    Author = 'D'

    # Description of the functionality provided by this module
    Description = 'Modular CLI tool for updating pip, Chocolatey, and winget packages with expressive feedback, emoji logging, and summary narration.'

    # Minimum version of the PowerShell engine required
    PowerShellVersion = '5.1'

    # Functions to export from this module
    FunctionsToExport = @(
      'Update-PipSelf',
      'Update-PipPackages',
      'Update-ChocolateyPackages',
      'Update-WingetPackages',
      'Save-PackageSnapshot',
      'Show-SummaryPanel',
      'Log-ErrorSummary',
      'Write-FancyHeader',
      'Get-LogFilePath'
    )

    # Cmdlets to export (none)
    CmdletsToExport = @()

    # Variables to export (none)
    VariablesToExport = @()

    # Aliases to export (none)
    AliasesToExport = @()

    # Private data to pass to the module
    PrivateData = @{}
}