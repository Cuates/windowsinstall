# TabCompletion.ps1

# 🔧 Tab completion for pip package names (Update-PipPackages -Name)
Register-ArgumentCompleter -CommandName Update-PipPackages -ParameterName name -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParams)
    try {
        python -m pip list --format=columns | ForEach-Object {
            if ($_ -match '^\S+\s+\S+') {
                $pkg = ($_ -split '\s+')[0]
                if ($pkg -like "$wordToComplete*") {
                    [System.Management.Automation.CompletionResult]::new($pkg, $pkg, 'ParameterValue', "pip package: $pkg")
                }
            }
        }
    } catch {}
}

# 🧪 Tab completion for Save-PackageSnapshot -Label
Register-ArgumentCompleter -CommandName Save-PackageSnapshot -ParameterName Label -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParams)
    'before','after','pre-update','post-update','baseline' | Where-Object {
        $_ -like "$wordToComplete*"
    } | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', "Snapshot label: $_")
    }
}

# 📊 Tab completion for Show-SummaryPanel parameters
Register-ArgumentCompleter -CommandName Show-SummaryPanel -ParameterName PipSelfUpdated -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParams)
    'true','false' | Where-Object {
        $_ -like "$wordToComplete*"
    } | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', "Boolean: $_")
    }
}

# 🧼 Placeholder completions (can be expanded later)
foreach ($cmd in @(
    'Update-PipSelf',
    'Update-ChocolateyPackages',
    'Update-WingetPackages',
    'Log-ErrorSummary'
)) {
    Register-ArgumentCompleter -CommandName $cmd -ScriptBlock {
        param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParams)
        return
    }
}
