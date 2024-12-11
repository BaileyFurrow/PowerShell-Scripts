
# Quick Run commands

Might be good to create shortcuts in USG folder...

> [!NOTE]
> Much of this comes from [ThioJoe's](https://github.com/ThioJoe) [Super God Mode repo](https://github.com/ThioJoe/Windows-Super-God-Mode) on Github.

## Control Panel/Microsoft Management Console (MMC)

Programs and features - `appwiz.cpl`

Power configuration - `powercfg.cpl`

- Closing the lid - `control.exe /name Microsoft.PowerOptions /page pageGlobalSettings`

Edit local group policy - `gpedit.msc`

Windows features - `OptionalFeatures.exe`

Rename PC/Join Domain - `SystemPropertiesComputerName.exe`

## Windows Settings

> [!NOTE]
> These URI paths are found in the System Settings DLL (C:\\Windows\\ImmersiveControlPanel\\SystemSettings.dll). To enumerate all of them, run this PowerShell code:
>
> ```PowerShell
> $content = [System.IO.File]::ReadAllText('C:\Windows\ImmersiveControlPanel\SystemSettings.dll')
> [regex]::Matches($content, 'ms-settings:[a-z-]+') | Select-Object Value
> ```

Installed apps - `ms-settings:installed-apps`

Ethernet - `ms-settings:network-ethernet`

Optional features - `ms-settings:optionalfeatures`

Power settings - `ms-settings:powersleep`

Printers - `ms-settings:printers`

Microphone privacy - `ms-settings:privacy-microphone`

Sound - `ms-settings:sound`

System - `ms-settings:system`
*Pressing `Win+X y` also works*

Clipboard history - `ms-settings:clipboard`

Devices - `ms-settings:devices`

## Named Folders

> [!NOTE]
> These are special named folders created by Windows. They can be found at the following registry entry:
>
> `HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions`

> \> PowerShell Fun
> You can resolve these path locations in PowerShell using the following command borrowed from .NET. This works the same as entering `shell:OneDrive` into File Explorer.
>
> `[System.Environment]::GetFolderPath('OneDrive')`

Network Shortcuts - `shell:NetHood`

OneDrive - `shell:OneDrive`

Recycle Bin - `shell:RecycleBinFolder`

Recent Files - `shell:Recent`

Send to locations - `shell:SendTo`

Screenshots - `shell:Screenshots`

AppData (Roaming) - `shell:Appdata`

Appdata Local - `shell:Local Appdata`

Profile root (C:\\Users\\*username*) - `shell:Profile`

Startup folder - `shell:Startup`

Documents folder - `shell:MyDocuments` or `shell:Personal`

> [!NOTE]
> The above is useful to determine if user's files are set to save to OneDrive by default.
