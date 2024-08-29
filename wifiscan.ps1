# Thx Chat-GPT

# Define the input and output file paths
$inputFilePath = "./wifiscan.txt"
$outputFilePath = "./wifiscan.json"

# Read the content of the input file
$content = Get-Content -Path $inputFilePath

# Initialize variables
$networks = @()
$currentSSID = $null
$currentBSSID = $null

# Process each line
foreach ($line in $content) {
    if ($line -match "^SSID\s(\d+)\s:\s(.*)$") {
        if ($currentBSSID -ne $null) {
            $currentSSID["BSSIDs"] += $currentBSSID
            $currentBSSID = $null
        }
        if ($currentSSID -ne $null) {
            $networks += $currentSSID
        }
        $currentSSID = @{
            "SSID" = $matches[2].Trim()
            "BSSIDs" = @()
        }
    } elseif ($line -match "^\s+Network type\s+:\s(.*)$") {
        $currentSSID["NetworkType"] = $matches[1].Trim()
    } elseif ($line -match "^\s+Authentication\s+:\s(.*)$") {
        $currentSSID["Authentication"] = $matches[1].Trim()
    } elseif ($line -match "^\s+Encryption\s+:\s(.*)$") {
        $currentSSID["Encryption"] = $matches[1].Trim()
    } elseif ($line -match "^\s+BSSID\s(\d+)\s+:\s(.*)$") {
        if ($currentBSSID -ne $null) {
            $currentSSID["BSSIDs"] += $currentBSSID
        }
        $currentBSSID = @{
            "BSSID" = $matches[2].Trim()
        }
    } elseif ($line -match "^\s+Signal\s+:\s(.*)$") {
        $currentBSSID["Signal"] = $matches[1].Trim()
    } elseif ($line -match "^\s+Radio type\s+:\s(.*)$") {
        $currentBSSID["RadioType"] = $matches[1].Trim()
    } elseif ($line -match "^\s+Band\s+:\s(.*)$") {
        $currentBSSID["Band"] = $matches[1].Trim()
    } elseif ($line -match "^\s+Channel\s+:\s(.*)$") {
        $currentBSSID["Channel"] = $matches[1].Trim()
    } elseif ($line -match "^\s+Basic rates \(Mbps\)\s+:\s(.*)$") {
        $currentBSSID["BasicRates"] = $matches[1].Trim()
    } elseif ($line -match "^\s+Other rates \(Mbps\)\s+:\s(.*)$") {
        $currentBSSID["OtherRates"] = $matches[1].Trim()
    } elseif ($line -match "^\s+Bss Load:") {
        $currentBSSID["BssLoad"] = @{}
    } elseif ($line -match "^\s+Connected Stations:\s+(.*)$") {
        $currentBSSID["BssLoad"]["ConnectedStations"] = $matches[1].Trim()
    } elseif ($line -match "^\s+Channel Utilization:\s+(.*)$") {
        $currentBSSID["BssLoad"]["ChannelUtilization"] = $matches[1].Trim()
    } elseif ($line -match "^\s+Medium Available Capacity:\s+(.*)$") {
        $currentBSSID["BssLoad"]["MediumAvailableCapacity"] = $matches[1].Trim()
    } elseif ($line -match "^\s+QoS MSCS Supported\s+:\s(.*)$") {
        $currentBSSID["QoSMSCSSupported"] = $matches[1].Trim()
    } elseif ($line -match "^\s+QoS Map Supported\s+:\s(.*)$") {
        $currentBSSID["QoSMapSupported"] = $matches[1].Trim()
    }
}

# Add the last BSSID and SSID if they exist
if ($currentBSSID -ne $null) {
    $currentSSID["BSSIDs"] += $currentBSSID
}
if ($currentSSID -ne $null) {
    $networks += $currentSSID
}

# Convert the data to JSON
$json = $networks | ConvertTo-Json -Depth 5

# Write the JSON to the output file
Set-Content -Path $outputFilePath -Value $json

Write-Output "Parsing complete. JSON saved to $outputFilePath"
