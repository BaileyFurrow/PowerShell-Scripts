# PowerShell Scripts

Welcome to my PowerShell scripts! These are random scripts that I create
occassionally and use either rarely or almost daily; there's no inbetween.

## Folder Descriptions

### [Cheat-Sheets](/Cheat-Sheets/)

Cheat sheets for various PowerShell commands.

### [sharex-deployment](/sharex-deployment/)

Automated install script for ShareX. To deploy in a corporate environment with
uploading disabled by default.

### [Windows-Super-God-Mode-NoUI](/Windows-Super-God-Mode-NoUI/)

A copy of [ThioJoe's](https://github.com/ThioJoe) [Super God Mode
repo](https://github.com/ThioJoe/Windows-Super-God-Mode) with the UI removed.

## File Descriptions

### [Count.psm1](/Count.psm1)

Counts the number of lines in a file using the built-in `Measure-Object` cmdlet.

### [Format-JSON.psm1](/Format-JSON.psm1)

Pretty-prints JSON using only one command. By default, two piped commands are
needed to achieve this. This bring it down to one.

### [Format-Size.psm1](/Format-Size.psm1)

Formats a given byte value to the specified unit (GB, KB, etc).

### [Get-Application.ps1](/Get-Application.ps1)

Using the registry, finds all applications installed for all users. Accomplishes
this by searching `HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\`

### [Get-DirectorySize.psm1](/Get-DirectorySize.psm1)

Gives you the size of a given directory. Can take multiple directories. Provides
size options from bytes to terabytes; defaults to megabytes.

### [Get-InstalledApps.ps1](/Get-InstalledApps.ps1)

Prototype of the [Get-Application](#get-applicationps1) script. Has a field for
specifying if it is 64 or 32 bit.

### [Get-LastDownload.psm1](/Get-LastDownload.psm1)

The most basic script in the world. Retrieves the last modified file in the Downloads folder.

> [!NOTE]
> This script is very dumb and assumes that you have a `$DW` variable set to
> your Downloads folder. Mine is set in my profile script. I might create an
> updated version that pulls the Downloads folder from the GUID by invoking the
> `SHGetKnownFolderPath` function from `shell32.dll`.

### [get-monitors.ps1](/get-monitors.ps1)

Pulls the monitor information from WMI and displays them.

### [Get-YouTubePlaylistTime.psm1](/Get-YouTubePlaylistTime.psm1)

Using the YouTube Data API, takes a YouTube playlist and calculates the amount
of time needed to watch an entire playlist.

### [gui.ps1](/gui.ps1)

Follows a PowerShell GUI tutorial from Dan Stolts.

### [Import-HTML.psm1](/Import-HTML.psm1)

Imports an HTML file as a COM object, allowing for easier parsing.

### [Optimize-Files.ps1](/Optimize-Files.ps1)

Sorts files into multiple folders based on file extension.

### [QuickRun.md](/QuickRun.md)

Includes a bunch of commands to run to quickly navigate to various folders and
tools.

### [Restart-Chromebox.psm1](/Restart-Chromebox.psm1)

Automates restarting my Chromebox server (runs my OctoPrint setup and a couple of monitoring tools).

### [Restart-OctoPrint.psm1](/Restart-OctoPrint.psm1)

Automates restarting the OctoPrint service on the Chromebox.

### [set-headphones.ps1](/set-headphones.ps1)

Literally just change main audio output to headphones.

### [set-speakers.ps1](/set-speakers.ps1)

Literally just change main audio output to speakers.

### [settings.ps1](/settings.ps1)

An exact copy of [this script from
SS64](https://ss64.com/ps/syntax-settings.html).  Really, it's just a good
reference for `ms-settings` shortcuts.

### [wifiscan.ps1](/wifiscan.ps1)

Parses the `wifiscan.txt` file and outputs an organized file into
`wifiscan.json`. Written with some help from ChatGPT.
