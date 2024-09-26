
function Get-InstalledApps {
    $x64 = Get-ItemProperty Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*
    $x64 | ForEach-Object {
        $_ | Add-Member -MemberType NoteProperty -Name Is64Bit -Value $true
    }
    $x32 = Get-ItemProperty Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*
    $x32 | ForEach-Object {
        $_ | Add-Member -MemberType NoteProperty -Name Is64Bit -Value $false
    }
    $allApps = $x64+$x32 | Sort-Object -Property DisplayName
    return $allApps
}