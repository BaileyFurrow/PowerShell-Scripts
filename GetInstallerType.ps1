function Get-InstallerType {
    param (
        [string]$Path
    )

    if (!(Test-Path $Path -PathType Leaf)) {
        Write-Error "File not found: $Path"
        return
    }
    $ExecutablePath = (Get-Item $Path).FullName

    $installerTypes = @{
        "Inno Setup"     = "Inno Setup";
        "Nullsoft"       = "NSIS (Nullsoft Scriptable Install System)";
        "InstallShield"  = "InstallShield";
        "Wise"           = "Wise Installer";
        "WiX Toolset"    = "WiX (Windows Installer XML)";
        "Advanced Installer" = "Advanced Installer";
    }
    $quietArgumentStrings = @{
        "Inno Setup" = "/VERYSILENT /NORESTART"
        "Nullsoft" = "/allusers /S"
        "InstallShield" = "-s -SMS"
        "Wise" = "/S"
        "WiX Toolset" = "/quiet"
    }

    $detectedType = "Unknown"

    # Read file details
    try {
        $fileInfo = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($ExecutablePath)
        $description = $fileInfo.FileDescription
        $productName = $fileInfo.ProductName
        $companyName = $fileInfo.CompanyName
        $version = $fileInfo.FileVersion

        $metaData = "$description $productName $companyName"
        foreach ($key in $installerTypes.Keys) {
            if ($metaData -match [regex]::Escape($key)) {
                $detectedType = $installerTypes[$key]
                break
            }
        }
    } catch {
        Write-Error "Failed to read file properties."
    }

    # If still unknown, scan for installer-specific signatures in the file content
    if ($detectedType -eq "Unknown") {
        try {
            $fileContent = Get-Content $ExecutablePath -Raw -ErrorAction Stop
            foreach ($key in $installerTypes.Keys) {
                if ($fileContent -match [regex]::Escape($key)) {
                    $detectedType = $installerTypes[$key]
                    break
                }
            }
        } catch {
            Write-Error "Failed to read binary data."
        }
    }

    # If the program is already installed, check the registry
    if ($detectedType -eq "Unknown") {
        $regPaths = @(
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
            "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
        )
        foreach ($path in $regPaths) {
            $uninstallEntries = Get-ItemProperty -Path $path -ErrorAction SilentlyContinue | Where-Object { $_.UninstallString -like "*$ExecutablePath*" }
            if ($uninstallEntries) {
                $uninstallString = $uninstallEntries.UninstallString
                if ($uninstallString -match "uninstall.exe /S") { $detectedType = "NSIS (Nullsoft)" }
                elseif ($uninstallString -match "setup.exe /silent") { $detectedType = "InstallShield" }
                elseif ($uninstallString -match "msiexec.exe") { $detectedType = "MSI (Windows Installer)" }
                break
            }
        }
    }

    # Output result
    [PSCustomObject]@{
        FilePath     = $ExecutablePath
        InstallerType = $detectedType
        Version      = $version
        ProductName  = $productName
    }
}

# Example usage:
# Get-InstallerType "C:\Path\To\Installer.exe"
