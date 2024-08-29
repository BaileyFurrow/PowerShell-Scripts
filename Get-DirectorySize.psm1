function Get-DirectorySize {
    <#
        .SYNOPSIS
            Gets the total size of the directory
        .DESCRIPTION
            Recursively scans a directory, gets a sum of all file sizes (using 
            the Length parameter), and returns the value in a specified format.
        .PARAMETER Path
            Specifies the directory
        .PARAMETER SizeFormat
            Specifies the format of the size preOutput
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

        [ValidateSet('B','KB','MB','GB','TB','Auto')]
        [PSDefaultValue(Help='Auto')]
        [string]$SizeFormat = 'Auto'
    )
    begin {
        $preOutput = @()
        Write-Debug "`$Value = $Value"
        Write-Debug "`$preOutput type before is $($preOutput.GetType())"
    }
    process {
        $Path | ForEach-Object {
            $obj = [PSCustomObject]@{
                PSTypeName = "Custom.DirectorySize"
                Name = $_
                Length = Get-ChildItem $_ -Recurse | Where-Object length -ne $null |
                    Select-Object -ExpandProperty Length | Measure-Object -sum |
                    Select-Object -ExpandProperty Sum
            }
            # $evalSize = Invoke-Expression "$($dirSize.toString())/1$SizeFormat"
            Write-Debug "`$_ = $_"
            # Write-Debug "`$evalSize = $evalSize`n"
                # Write-Debug "$($_.Name), $evalSize"
            Add-Member -InputObject $obj -MemberType NoteProperty -Name KB -Value $($obj.Length/1kb)
            Add-Member -InputObject $obj -MemberType NoteProperty -Name MB -Value $($obj.Length/1mb)
            Add-Member -InputObject $obj -MemberType NoteProperty -Name GB -Value $($obj.Length/1gb)
            Add-Member -InputObject $obj -MemberType NoteProperty -Name TB -Value $($obj.Length/1tb)
            $preOutput += $obj
        }
    }
    end {
        if ($SizeFormat -eq "Auto") {
            $avg = $preOutput | Measure-Object -Property Length -Average | Select-Object -ExpandProperty Average
            $SizeType = switch ($avg) {
                {$_ -ge 1gb} {
                    "GB"
                    continue
                }
                {$_ -ge 1mb} {
                    "MB"
                    continue
                }
                {$_ -ge 1kb} {
                    "KB"
                    continue
                }
                Default {
                    "Length"
                }
            }
            $output = @()
            $preOutput | ForEach-Object {
                $outObj = $_
                Add-Member -InputObject $outObj -MemberType AliasProperty -Name "Size ($SizeType)" -Value $SizeType -Force
                $output += $outObj
            }
        }
        Remove-TypeData -TypeName Custom.DirectorySize -ErrorAction SilentlyContinue
        Update-TypeData -TypeName Custom.DirectorySize -DefaultDisplayPropertySet "Name","Size ($SizeType)"
        return $output
    }
}

Set-Alias -Name gds -Value Get-DirectorySize
