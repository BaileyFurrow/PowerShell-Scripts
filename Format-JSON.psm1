
function Format-JSON {
    <#
        .SYNOPSIS
            Pretty-prints JSON using only one command.

        .DESCRIPTION
            Pretty-prints JSON using only one command. The default way to do this in vanilla PowerShell requires piping two commands.

        .PARAMETER JSON
            JSON string to prettify.

        .PARAMETER Path
            Path to JSON file.

        .INPUTS
            System.String. Must be in the JSON format.

        .OUTPUTS
            System.String. Prettified JSON.

    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ParameterSetName="Text", ValueFromPipeline=$true)]
        [string[]]$JSON,

        [Parameter(Mandatory, ParameterSetName="Path", Position=0)]
        [System.URI]$Path
    )

    begin {
        if ($Path) {
            $JSON = Get-Content $Path -Raw
        }
    }

    process {
        Write-Debug "$($JSON -join '')"
        Write-Debug "$($JSON.GetType())"
        return $JSON -join "" | ConvertFrom-JSON | ConvertTo-JSON
    }
}

Export-ModuleMember -Function Format-JSON
