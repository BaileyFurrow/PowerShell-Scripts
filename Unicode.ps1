
function Get-UnicodeCharacter {
    [CmdletBinding()]
    param (
        [int]$Code
    )
    
    process {
        [char]$Code
    }
}