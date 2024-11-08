function Get-Application {
    <#
    .SYNOPSIS
        Retrives application(s) information from a remote or local computer.
    .DESCRIPTION
        Using the registry, retrieves a list of applications from the registry of a local or remote computer.
        This is achieved by checking the subkeys of HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\
        and HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\ for 64-bit and 32-bit software,
        respectively.
    .NOTES
        Requires admin rights.
    .EXAMPLE
        Get-Application 
        Retrieves all applications on the local computer.
    .EXAMPLE
        Get-Application -ComputerName Client01
        Retrieves all applications on the remote computer Client01.
    .EXAMPLE
        Get-Application -Name "*PowerShell*" -ComputerName Client02
        Retrieves applications on remote computer Client02 that contain
        PowerShell in the name.
    #>
    
    param (
        # Name of application to find. If none are selected, lists all applications.
        [Parameter(Position=0)]
        [SupportsWildcards()]
        [Alias("App","Program","ProgramName","AppName","Application")]
        [string[]] $ApplicationName=".*",

        # Name of remote computer to access. Uses local PC by default.
        [Parameter(Position=1)]
        [Alias("PC","PCName","ResourceName")]
        [string] $ComputerName=".",

        # Only return 64-bit applications.
        # [Parameter(ParameterSetName="64-bit")]
        [switch] $x64,

        # Only return 32-bit applications.
        # [Parameter(ParameterSetName="32-bit")]
        [switch] $x86
    )
    begin {
        # Skip the computer if it cannot be connected to.
        if ($ComputerName -ne "." -and -not (Test-Connection $ComputerName -Quiet)) {
            Write-Error -Message "The target computer is not online or does not exist."
            Write-Debug $ComputerName
            return
        }
    }
    process {
        $ICMScriptBlock = {
            $AppList = @()
            $SelectParams = @{"Property"=@("DisplayName","DisplayVersion","Publisher",@{
                Name="InstallDate"
                Expression={[datetime]::ParseExact([string]$_.InstallDate, 'yyyyMMdd', $null)}
            },"UninstallString")}
            # 64-bit
            if (-not $using:x86) {
                $AppList += (Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*) | 
                    Where-Object DisplayName -Match $using:ApplicationName | 
                    Select-Object @SelectParams
            }
            # 32-bit
            if (-not $using:x64) {
                $SelectParams["Property"] += @{
                    Name="is32bit"
                    Expr={$True}
                }
                $AppList += (Get-ItemProperty HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*) |
                    Where-Object DisplayName -Match $using:ApplicationName |
                    Select-Object @SelectParams
            }
            return $AppList
        }
        return Invoke-Command -ComputerName $ComputerName -ScriptBlock $ICMScriptBlock |
            Select-Object * -ExcludeProperty RunspaceId | Sort-Object DisplayName
    }
}