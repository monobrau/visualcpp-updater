# Visual C++ Redistributable Updater

A comprehensive PowerShell script that automatically updates all Visual C++ Redistributable packages (2005-2022) on Windows systems.

## Features

- **Automatic Detection** - Scans for installed Visual C++ versions
- **Smart Version Checking** - Only updates when necessary
- **EOL Version Support** - Handles end-of-life versions (2005, 2008, 2010, 2012, 2013)
- **Current Versions** - Keeps 2015-2022 unified runtime up to date
- **Silent Operation** - Runs without user interaction
- **RMM/ScreenConnect Compatible** - Multiple output modes for automation tools
- **Exit Code 4096 Handling** - Properly handles "already installed" scenarios
- **Major.Minor.Build Matching** - Smart version comparison for EOL products

## Supported Versions

- ✅ Visual C++ 2005 SP1 (KB2538242) - If installed
- ✅ Visual C++ 2008 SP1 (KB2538243) - If installed
- ✅ Visual C++ 2010 SP1 (KB2565063) - If installed
- ✅ Visual C++ 2012 Update 4 - If installed
- ✅ Visual C++ 2013 - If installed
- ✅ Visual C++ 2015-2022 (latest unified) - If installed

## Quick Start

**Run from PowerShell (as Administrator):**
```powershell
iex (iwr "https://raw.githubusercontent.com/monobrau/visualcpp-updater/main/visualc++updater.ps1" -UseBasicParsing).Content
```

**Run from ScreenConnect:**
```powershell
#!ps
#maxlength=200000
#timeout=300000
iex (iwr "https://raw.githubusercontent.com/monobrau/visualcpp-updater/main/visualc++updater.ps1" -UseBasicParsing).Content
```

## Scripts

### visualc++updater.ps1
The main updater script with full detailed output.

```powershell
.\visualc++updater.ps1
```

### visualc++updater-silent.ps1
Wrapper with minimal output suitable for RMM tools. Saves full log to temp directory.

```powershell
.\visualc++updater-silent.ps1
```

### visualc++updater-screenconnect.ps1
Compact output specifically formatted for ConnectWise ScreenConnect commands.

```powershell
.\visualc++updater-screenconnect.ps1
```

## Usage

### Local Usage
```powershell
# Run the main script locally
.\visualc++updater.ps1
```

### Run Directly from Web (PowerShell)

**Standard Output (Detailed):**
```powershell
# Download and execute with full output
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$script = Invoke-WebRequest -Uri "https://raw.githubusercontent.com/monobrau/visualcpp-updater/main/visualc++updater.ps1" -UseBasicParsing
Invoke-Expression $script.Content
```

**One-liner (Advanced):**
```powershell
# Single command execution
iex (iwr -Uri "https://raw.githubusercontent.com/monobrau/visualcpp-updater/main/visualc++updater.ps1" -UseBasicParsing).Content
```

**Save and Execute:**
```powershell
# Download to temp folder and run
$ProgressPreference = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/monobrau/visualcpp-updater/main/visualc++updater.ps1" -OutFile "$env:TEMP\visualc++updater.ps1" -UseBasicParsing
& "$env:TEMP\visualc++updater.ps1"
```

### ConnectWise ScreenConnect Commands

**Option 1: Full Output (Recommended)**
```powershell
#!ps
#maxlength=200000
#timeout=300000
$ProgressPreference='SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12
$temp="$env:TEMP\visualc++updater.ps1"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/monobrau/visualcpp-updater/main/visualc++updater.ps1" -OutFile $temp -UseBasicParsing
& $temp
```

**Option 2: Compact Output (Better for ScreenConnect Console)**
```powershell
#!ps
#maxlength=200000
#timeout=300000
$ProgressPreference='SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12
$temp="$env:TEMP"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/monobrau/visualcpp-updater/main/visualc++updater-screenconnect.ps1" -OutFile "$temp\vc-sc.ps1" -UseBasicParsing
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/monobrau/visualcpp-updater/main/visualc++updater.ps1" -OutFile "$temp\visualc++updater.ps1" -UseBasicParsing
& "$temp\vc-sc.ps1"
```

**Option 3: Direct Execution (No File Save)**
```powershell
#!ps
#maxlength=200000
#timeout=300000
$ProgressPreference='SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12
iex (iwr "https://raw.githubusercontent.com/monobrau/visualcpp-updater/main/visualc++updater.ps1" -UseBasicParsing).Content
```

### RMM Tools (Datto, NinjaRMM, Atera, etc.)

**PowerShell Script Component:**
```powershell
# Set TLS and progress preferences
$ProgressPreference = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Download script
$scriptUrl = "https://raw.githubusercontent.com/monobrau/visualcpp-updater/main/visualc++updater.ps1"
$scriptPath = Join-Path $env:TEMP "visualc++updater.ps1"
Invoke-WebRequest -Uri $scriptUrl -OutFile $scriptPath -UseBasicParsing

# Execute with error handling
try {
    & $scriptPath
    $exitCode = $LASTEXITCODE
    if ($exitCode -eq 3010) {
        Write-Output "SUCCESS: Updates installed. Reboot required."
    } elseif ($exitCode -eq 0) {
        Write-Output "SUCCESS: All updates completed."
    } else {
        Write-Output "WARNING: Script exited with code $exitCode"
    }
    exit $exitCode
} catch {
    Write-Output "ERROR: $($_.Exception.Message)"
    exit 1
}
```

## Requirements

- Windows PowerShell 5.1 or later
- Administrative privileges (for installation)
- Internet connection (to download updates)

## How It Works

1. **Detection Phase**
   - Scans registry for installed Visual C++ versions
   - Detects both x86 and x64 architectures
   - Checks current version numbers

2. **Version Comparison**
   - For EOL versions: Compares Major.Minor.Build (e.g., 9.0.30729)
   - For current versions: Checks if installed version is recent enough
   - Smart handling of registry version formats

3. **Dynamic URL Resolution** (New!)
   - **Method 1**: Queries winget package manifests from GitHub
   - **Method 2**: Scrapes Microsoft Download Center confirmation pages
   - **Method 3**: Falls back to hardcoded URLs if dynamic methods fail
   - Ensures script continues working even if Microsoft reorganizes downloads
   - 2015-2022 versions use aka.ms URLs that auto-redirect to latest

4. **Update Phase**
   - Downloads only necessary updates from official Microsoft sources
   - Installs silently without user interaction
   - Handles exit codes properly (0, 3010, 4096, 5100)
   - Cleans up temporary files

5. **Reporting**
   - Shows detection results with color coding
   - Displays update status for each version
   - Shows actual download URL being used
   - Reports success/failure with exit codes

## Exit Codes

- `0` - Success, no updates needed or all updates completed
- `1` - Error occurred during update process
- `3010` - Success, reboot required

## Version Detection Logic

For **EOL versions** (2005-2013):
- If Major.Minor.Build matches target (e.g., 9.0.30729 vs 9.0.30729.5677)
- Considers it **already updated** (registry doesn't always show full revision)
- Skips unnecessary downloads and installations

For **Current versions** (2015-2022):
- Dynamically checks latest available version
- Only updates if installed version is older than threshold

## Exit Code 4096 Handling

Exit code 4096 means "already installed or newer version present":
- Script creates marker files to prevent repeated attempts
- Recognizes this as successful state
- Won't retry on subsequent runs

## Example Output

```
=============================================
Visual C++ All Versions Updater (2005-2022)
=============================================

Scanning for installed Visual C++ redistributables...

=============================================
Detection Results
=============================================

Visual C++ 2008 [EOL] (KB2538243):
  [x64] INSTALLED
        Current Version: 9.0.30729
        Status: UP TO DATE (will skip)

Visual C++ 2015-2022 [Active]:
  [x64] INSTALLED
        Current Version: 14.38.33130
        Status: Will check latest version dynamically

Total updates to process: 1

=============================================
Beginning updates...
=============================================

Processing Visual C++ 2015-2022...
  Downloading latest version...
  Installing...
  Installation successful.

=============================================
Update process completed.
=============================================
```

## Security

- All downloads are from official Microsoft servers
- No third-party hosting or modified installers
- Downloads use HTTPS exclusively (enforced via TLS 1.2)
- File version verification included
- Dynamic URL resolution uses trusted sources (GitHub winget-pkgs, Microsoft Download Center)

## Important Notes

### Running Scripts from the Web
When using `iex (iwr ...)` to run scripts directly from the web:
- ✅ **Pros**: No files left on disk, quick execution, always gets latest version
- ⚠️ **Cons**: Cannot inspect code before execution, requires internet during run
- 💡 **Best Practice**: Review the script on GitHub first, then run it

### ScreenConnect Configuration
- **Timeout**: Set to 300000ms (5 minutes) to allow for large downloads
- **Max Length**: Set to 200000 to capture all output
- **Shell**: Use PowerShell (#!ps) for best compatibility

### RMM Tool Integration
Exit codes are designed for automation:
- `0` = Success (safe to continue)
- `3010` = Success but reboot needed (schedule reboot)
- `1` = Error (alert administrator)

## Troubleshooting

### "UPDATE AVAILABLE" but won't install
- For EOL versions with version like 9.0.30729, this is expected
- The update is already applied, registry just doesn't show full version
- Script will skip installation automatically

### Exit code 4096 repeatedly
- This has been fixed in current version
- Script creates marker files to prevent repeats
- Delete marker files in `%TEMP%` if you want to retry

### Downloads failing
- Check internet connection
- Verify Microsoft download URLs are accessible
- Check if antivirus is blocking downloads

## License

MIT License - Feel free to use and modify

## Author

Created for system administrators managing Windows environments

## Contributing

Contributions welcome! Please test thoroughly before submitting pull requests.

## Changelog

### v2.1 (2025-01-XX)
- **Dynamic URL Resolution**: Automatically resolves download URLs using multiple methods
  - Queries winget package manifests from GitHub
  - Scrapes Microsoft Download Center as backup
  - Falls back to hardcoded URLs if needed
- **Major Code Refactoring**: Reduced code from 1078 to 733 lines (-32%)
  - Eliminated duplicate x86/x64 logic with reusable function
  - Added exit code constants for better readability
  - Improved error handling with detailed context
- **Security Enhancements**:
  - All URLs now use HTTPS exclusively
  - Added temp directory validation with write permission checks
  - Enhanced version comparison with better validation
- **Professional Logging**: Replaced DEBUG output with proper Write-Verbose
- **Wrapper Script Improvements**: Multi-location script discovery (PSScriptRoot, C:\temp, %TEMP%)
- **Documentation**: Comprehensive web-based and ScreenConnect usage instructions

### v2.0 (2024-10-10)
- Added Major.Minor.Build matching for EOL versions
- Fixed exit code 4096 handling with marker files
- Added ScreenConnect-specific output mode
- Improved version comparison logic
- Better detection status display

### v1.0
- Initial release
- Support for all VC++ versions 2005-2022

