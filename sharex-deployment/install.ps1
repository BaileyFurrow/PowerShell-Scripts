param (
    [switch] $NoInstall
)
# This must be run as admin in order to make the necessary registry changes.

$ShareXInstallFile = "./sharex-16.1.0.exe"

# Install ShareX silently

if (-not $NoInstall) {
    Invoke-Item -Path "$ShareXInstallFile /VERYSILENT"
}

# Create ShareX registry key

$ShareXRegPath = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\ShareX"
New-Item -Path $ShareXRegPath 

# Disable checks for updates, as these will be completed by PatchMyPC/MECM

$DisableUpdateCheckSplat = @{
    Path = $ShareXRegPath
    Name = "DisableUpdateCheck"
    Type = "DWord"
    Value = 1
}
New-ItemProperty @DisableUpdateCheckSplat

# Disable uploading

$DisableUploadSplat = @{
    Path = $ShareXRegPath
    Name = "DisableUpload"
    Type = "DWord"
    Value = 1
}
New-ItemProperty @DisableUploadSplat

# Set screenshot path to Pictures folder

$PicturesFolder = [System.Environment]::GetFolderPath("MyPictures")
$PersonalPathSplat = @{
    Path = $ShareXRegPath
    Name = "PersonalPath"
    Type = "String"
    Value = "$PicturesFolder\Screenshots"
}
New-ItemProperty @PersonalPathSplat
