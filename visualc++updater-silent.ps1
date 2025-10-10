<#
.SYNOPSIS
    Silent Visual C++ updater for ScreenConnect/RMM tools
    
.DESCRIPTION
    Runs the Visual C++ updater with minimal output suitable for RMM tools
#>

# Suppress progress bars and verbose output
$ProgressPreference = 'SilentlyContinue'
$VerbosePreference = 'SilentlyContinue'

# Capture the output
$outputPath = Join-Path $env:TEMP "vcredist_update_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"

try {
    # Run the main script and capture output
    $scriptPath = Join-Path $PSScriptRoot "visualc++updater.ps1"
    
    if (-not (Test-Path $scriptPath)) {
        $scriptPath = "C:\temp\visualc++updater.ps1"
    }
    
    if (-not (Test-Path $scriptPath)) {
        Write-Output "ERROR: visualc++updater.ps1 not found"
        exit 1
    }
    
    Write-Output "Starting Visual C++ Redistributable update check..."
    Write-Output "Full log: $outputPath"
    Write-Output ""
    
    # Run the script and capture output
    & $scriptPath *>&1 | Tee-Object -FilePath $outputPath
    
    $exitCode = $LASTEXITCODE
    
    Write-Output ""
    Write-Output "========================================="
    Write-Output "Update process completed"
    Write-Output "Exit Code: $exitCode"
    Write-Output "Full log saved to: $outputPath"
    Write-Output "========================================="
    
    exit $exitCode
}
catch {
    Write-Output "ERROR: $($_.Exception.Message)"
    Write-Output "Full log: $outputPath"
    exit 1
}

