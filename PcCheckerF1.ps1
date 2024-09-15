function Format-Output {
    param($name, $value)
    $formattedOutput = "{0} : {1}" -f $name, $value
    # Replace 'System.Byte[]' with an empty string
    $formattedOutput -replace 'System.Byte\[\]', ''
}

function List-BAMStateUserSettings {
    Write-Host "Listing BAM State UserSettings..."
    $registryPath = "HKLM:\SYSTEM\CurrentControlSet\Services\bam\State\UserSettings"
    $userSettings = Get-ChildItem -Path $registryPath | Where-Object { $_.Name -like "*1001" }

    # Desktop path
    $desktopPath = [System.Environment]::GetFolderPath('Desktop')
    # Output file path
    $outputFile = Join-Path -Path $desktopPath -ChildPath "PcCheckLogs.txt"

    # Clear the output file if it already exists
    if (Test-Path $outputFile) { Clear-Content $outputFile }

    # Create a hashtable to store logged paths
    $loggedPaths = @{}

    # Function to scan a registry path and log specific results
    function Scan-RegistryPath {
        param($regPath)

        Write-Host "Scanning registry path: $regPath"
        if (Test-Path $regPath) {
            $entries = Get-ItemProperty -Path $regPath
            $entries.PSObject.Properties | ForEach-Object {
                if ($_.Name -match "exe" -or $_.Name -match ".rar" -and -not $loggedPaths.ContainsKey($_.Name)) {
                    # Check for specific names or random EXE format
                    if ($_.Name -match "loader.exe|klar|ruyzaq|gc|lethal|dma|Aptitude|visuals|HIbana|Shxdow|Scoob|linear|inject|privat|firmware|software|Rubin" -or $_.Name -match "^[A-Z0-9]{8}\.exe$") {
                        Add-Content -Path $outputFile -Value (Format-Output $_.Name $_.Value)
                        $loggedPaths[$_.Name] = $true
                    }
                }
            }
        } else {
            Write-Host "The registry key $regPath does not exist."
        }
    }

    # Scan the main BAM registry path
    if ($userSettings) {
        Write-Host "User Settings ending in 1001:"
        foreach ($setting in $userSettings) {
            Write-Host $setting.Name
            Add-Content -Path $outputFile -Value "`n$($setting.PSPath)"
            $items = Get-ItemProperty -Path $setting.PSPath | Select-Object -Property *
            foreach ($item in $items.PSObject.Properties) {
                if (($item.Name -match "exe" -or $item.Name -match ".rar") -and -not $loggedPaths.ContainsKey($item.Name)) {
                    if ($item.Name -match "loader.exe|klar|ruyzaq|gc|lethal|dma|Aptitude|visuals|HIbana|Shxdow|Scoob|linear|inject|privat|firmware|software|Rubin" -or $item.Name -match "^[A-Z0-9]{8}\.exe$") {
                        Add-Content -Path $outputFile -Value (Format-Output $item.Name $item.Value)
                        $loggedPaths[$item.Name] = $true
                    }
                }
            }
        }
        Write-Host "Results written to $outputFile"
    } else {
        Write-Host "No User Settings ending in 1001 found."
    }

    # Additional registry paths to scan
    $additionalPaths = @(
        "HKCR:\Local Settings\Software\Microsoft\Windows\Shell\MuiCache",
        "HKCU:\SOFTWARE\Microsoft\DirectInput\MostRecentApplication",
        "HKLM:\SYSTEM\MountedDevices"
    )

    foreach ($path in $additionalPaths) {
        Scan-RegistryPath -regPath $path
    }

    # Now let's read the HKCU AppCompatFlags Compatibility Assistant Store registry key
    Write-Host "Reading HKCU AppCompatFlags Compatibility Assistant Store registry key..."
    $compatRegistryPath = "HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Compatibility Assistant\Store"
    Write-Host "Reading registry path: $compatRegistryPath"
    $compatEntries = Get-ItemProperty -Path $compatRegistryPath

    # Log the entries
    $compatEntries.PSObject.Properties | ForEach-Object {
        if (($_.Name -match "exe" -or $_.Name -match ".rar") -and -not $loggedPaths.ContainsKey($_.Name)) {
            if ($_.Name -match "loader.exe|klar|ruyzaq|gc|lethal|dma|Aptitude|visuals|HIbana|Shxdow|Scoob|linear|inject|privat|firmware|software|Rubin" -or $_.Name -match "^[A-Z0-9]{8}\.exe$") {
                Add-Content -Path $outputFile -Value (Format-Output $_.Name $_.Value)
                $loggedPaths[$_.Name] = $true
            }
        }
    }

    # Add the new registry key
    Write-Host "Reading HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FeatureUsage\AppSwitched registry key..."
    $newRegistryPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FeatureUsage\AppSwitched"
    Write-Host "Reading registry path: $newRegistryPath"
    if (Test-Path $newRegistryPath) {
        $newEntries = Get-ItemProperty -Path $newRegistryPath
        # Log the entries
        $newEntries.PSObject.Properties | ForEach-Object {
            if (($_.Name -match "exe" -or $_.Name -match ".rar") -and -not $loggedPaths.ContainsKey($_.Name)) {
                if ($_.Name -match "loader.exe|klar|ruyzaq|gc|lethal|dma|Aptitude|visuals|HIbana|Shxdow|Scoob|linear|inject|privat|firmware|software|Rubin" -or $_.Name -match "^[A-Z0-9]{8}\.exe$") {
                    Add-Content -Path $outputFile -Value (Format-Output $_.Name $_.Value)
                    $loggedPaths[$_.Name] = $true
                }
            }
        }
    } else {
        Write-Host "The registry key $newRegistryPath does not exist."
    }

    # Check for DMA devices using msinfo32 and Device Manager
    Write-Host "Checking for DMA devices using msinfo32 and Device Manager..."
    $msinfoFile = Join-Path -Path $desktopPath -ChildPath "msinfo.nfo"
    
    # Generate msinfo32 report
    & msinfo32 /nfo $msinfoFile
    $msinfoText = Get-Content -Path $msinfoFile

    # Look for DMA information in msinfo32 report
    if ($msinfoText -match "DMA Channel") {
        Add-Content -Path $outputFile -Value "DMA Channel found in msinfo32 report."
    } else {
        Write-Host "No DMA Channel found in msinfo32 report."
    }

    # Check in Device Manager for DMA-capable devices
    $devices = Get-PnpDevice | Where-Object { $_.Class -eq "System" }
    if ($devices -match "DMA") {
        Add-Content -Path $outputFile -Value "DMA-capable device found: $($devices)"
    } else {
        Write-Host "No DMA-capable device found."
    }

    # Additional check for DMA information in system configuration
    Write-Host "Checking additional system configuration for DMA information..."
    $additionalConfigPaths = @(
        "HKLM:\SYSTEM\CurrentControlSet\Control\CriticalDeviceDatabase",
        "HKLM:\SYSTEM\CurrentControlSet\Control\Class"
    )

    foreach ($path in $additionalConfigPaths) {
        Scan-RegistryPath -regPath $path
    }

    # Remove duplicate lines, filter out lines containing { and }, and remove ":" from the lines
    Get-Content $outputFile | Sort-Object | Get-Unique | Where-Object { $_ -notmatch "\{.*\}" } | ForEach-Object { $_ -replace ":", "" } | Set-Content $outputFile

    # Final confirmation for output file
    if (Test-Path $outputFile) {
        Write-Host "Output file created successfully on the desktop."
    } else {
        Write-Host "Failed to create output file on the desktop."
    }

    # NEW CODE: Copy folder names from Documents/My Games/Rainbow Six - Siege and construct URLs

    $r6Path = [System.IO.Path]::Combine([System.Environment]::GetFolderPath('MyDocuments'), "My Games", "Rainbow Six - Siege")

    if (Test-Path $r6Path) {
        Write-Host "Found Rainbow Six - Siege folder. Retrieving folder names..."
        $folderNames = Get-ChildItem -Path $r6Path -Directory | Select-Object -ExpandProperty Name
        foreach ($folderName in $folderNames) {
            $url = "https://r6.tracker.network/r6siege/profile/ubi/${folderName}"
            Add-Content -Path $outputFile -Value "URL for folder ${folderName}: $url"
        }
        Write-Host "Folder URLs written to $outputFile."
    } else {
        Write-Host "Rainbow Six - Siege folder not found in Documents."
    }
}

# Call the function
List-BAMStateUserSettings
