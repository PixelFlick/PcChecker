param (
    [string]$Key
)

# Path to the keys file
$keysFile = "https://github.com/PixelFlick/PcChecker/blob/main/Keys.txt"

# Read the existing keys
$keys = Get-Content $keysFile

# Check if the key is valid and not used
if ($keys -contains $Key) {
    # Remove the key from the file (mark as used)
    $keys = $keys | Where-Object { $_ -ne $Key }
    $keys | Set-Content $keysFile

    # Path to the main script
    $mainScriptUrl = "https://github.com/PixelFlick/PcChecker/blob/main/PcChecker.ps1
    $tempScriptPath = "$env:TEMP\PcChecker.ps1"
    
    # Download and run the main script
    Invoke-WebRequest -Uri $mainScriptUrl -OutFile $tempScriptPath
    & $tempScriptPath
    
    # Clean up
    Remove-Item $tempScriptPath
} else {
    Write-Host "Invalid or already used key."
}
