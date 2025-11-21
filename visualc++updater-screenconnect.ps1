<#
.SYNOPSIS
    Visual C++ updater for ScreenConnect - Compact output
#>

$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'Continue'

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
    Write-Host "ERROR: visualc++updater.ps1 not found" -ForegroundColor Red
    Write-Host "Searched locations:" -ForegroundColor Red
    $scriptLocations | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
    exit 1
}

Write-Host "Visual C++ Redistributable Updater" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Run the script
$result = & $scriptPath 2>&1

# Filter output to show only important lines
$result | Where-Object {
    $_ -match "Visual C\+\+" -or
    $_ -match "Status:" -or
    $_ -match "INSTALLED" -or
    $_ -match "UP TO DATE" -or
    $_ -match "UPDATE AVAILABLE" -or
    $_ -match "Total updates" -or
    $_ -match "Processing" -or
    $_ -match "Installation" -or
    $_ -match "Update process completed" -or
    $_ -match "ERROR" -or
    $_ -match "WARNING"
} | ForEach-Object {
    Write-Host $_
}

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Scan completed - Exit code: $LASTEXITCODE" -ForegroundColor $(if ($LASTEXITCODE -eq 0) { "Green" } else { "Yellow" })

exit $LASTEXITCODE

