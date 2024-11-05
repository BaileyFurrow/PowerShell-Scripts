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
        # Name of remote computer to access. Uses local PC by default.
        [Parameter()]
        [string] $ComputerName,

        # Name of application to find. If none are selected, lists all applications.
        [Parameter()]
        [SupportsWildcards()]
        [string[]] $Name,

        # Only return 64-bit applications.
        [Parameter(ParameterSetName="64-bit")]
        [switch] $x64,

        # Only return 32-bit applications.
        [Parameter(ParameterSetName="32-bit")]
        [switch] $x86

    )
}