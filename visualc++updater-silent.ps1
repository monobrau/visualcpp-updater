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
    # Try to find the main script in multiple locations
    $scriptLocations = @(
        (Join-Path $PSScriptRoot "visualc++updater.ps1"),     # Same directory as this script
        "C:\temp\visualc++updater.ps1",                        # Common temp location
        (Join-Path $env:TEMP "visualc++updater.ps1")          # User temp directory
    )

    $scriptPath = $null
    foreach ($location in $scriptLocations) {
        if (Test-Path $location) {
            $scriptPath = $location
            break
        }
    }

    if (-not $scriptPath) {
        Write-Output "ERROR: visualc++updater.ps1 not found in any of the following locations:"
        $scriptLocations | ForEach-Object { Write-Output "  - $_" }
        exit 1
    }

    Write-Output "Using script: $scriptPath"
    
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

