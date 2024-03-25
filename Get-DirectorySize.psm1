function Get-DirectorySize {
    <#
        .SYNOPSIS
            Gets the total size of the directory
        .DESCRIPTION
            Recursively scans a directory, gets a sum of all file sizes (using 
            the Length parameter), and returns the value in a specified format.
        .PARAMETER Path
            Specifies the directory
        .PARAMETER Size
            Specifies the format of the size output
        .PARAMETER Value
            Returns the value only rather than a hash table with
            formatted strings
        .OUTPUTS
            If -Value is set, returns a System.Double
            Otherwise, returns a System.String
    #>
    param (
        [PSDefaultValue(Help='Current directory')]
        [Parameter(Position=0,ValueFromPipeline)]
        [ValidateScript(
            {Test-Path $_}
            # ErrorMessage = "`n{0} is not a valid path. Validate that the path exists and try again."
        )]
        [System.IO.DirectoryInfo[]]$Path = $PWD.Path,

        [ValidateSet('B','KB','MB','GB','TB')]
        [PSDefaultValue(Help='MB')]
        [string]$Size = 'MB',

        [switch]$Value
    )
    begin {
        $retVal = If ($Value) {@()} Else {@{}}
        Write-Debug "`$Value = $Value"
        Write-Debug "`$retVal type before is $($retVal.GetType())"
    }
    process {
        $Path | foreach {
            $dirSize = Get-ChildItem $_ -Recurse | Where length -ne $null |
                Select-Object -ExpandProperty Length | Measure-Object -sum |
                Select-Object -ExpandProperty Sum 
            $evalSize = Invoke-Expression "$($dirSize.toString())/1$Size"
            Write-Debug "`$_ = $_"
            Write-Debug "`$dirSize = $dirSize"
            Write-Debug "`$evalSize = $evalSize`n"
            if ($Value) {
                $retVal += $evalSize
            } else {
                Write-Debug "$($_.Name), $evalSize"
                $retVal.Add($_.Name, $evalSize.ToString("0.###"))
            }
        }
    }
    end {
        Write-Verbose $retVal
        Write-Debug "`$retVal type after is $($retVal.GetType())"
        # return ($retVal | Format-Table -Property Name,@{Label="Size"; Expression={$_.Value}})
        return $retVal
    }
}

Set-Alias -Name gds -Value Get-DirectorySize
