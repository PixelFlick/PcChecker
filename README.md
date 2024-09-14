
# PcCheckerTool

This Tool is designed to check for potential cheat-related files and suspicious executables on a Windows system, focusing on registry entries and system configurations and it creates a log file on the desktop.


## Features Breakdown

- Registry Analysis for Cheats: Scans specific registry paths (bam\State, MuiCache, MostRecentApplication, MountedDevices) for cheat-related files and executables.

- File Logging: Creates a log file named PcCheckLogs.txt on the desktop, logging suspicious files, cheat-related executables, and paths.

- Cheat Detection Patterns: Searches for common cheat file names (e.g., loader.exe, klar, lethal, Aptitude, visuals, dma, inject, etc.) and randomly generated .exe files.

- DMA Devices Check: Uses msinfo32 and Device Manager to detect DMA-capable devices, which can be exploited by certain cheats.

- Cleanup & Formatting: Ensures the log file is cleaned of duplicates and formatted for readability.

## How It Works

- Registry Scan: The script checks various registry paths for cheat-related executables and logs any suspicious files.

- Log File Creation: A PcCheckLogs.txt file is generated on the user's desktop, storing all findings.

- Additional Checks: The script scans the system configuration for DMA-related devices and adds relevant entries to the log file.

- Final Output: The log file is cleaned, formatted, and saved on the desktop, providing a clear summary of the scan results.
## Installation

- Download the script or clone this repository:

```bash
git clone https://github.com/PixelFlick/PcChecker.git
```
    
- Run PcChecker.Exe


## Log File Example

```HKLM:\SYSTEM\CurrentControlSet\Services\bam\State\UserSettings\0001001
loader.exe : Path\To\Cheat\loader.exe
Q3T86U1U7F.exe : Path\To\Cheat\Q3T86U1U7F.exe
gc.exe : Path\To\Cheat\gc.exe

DMA-capable device found: Device_Name
```
## Disclaimer

- This script is intended for educational purposes and for detecting potential cheats in a controlled environment. Use it responsibly and ensure that you comply with local laws and regulations regarding system security and privacy.
