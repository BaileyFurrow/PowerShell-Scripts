
function Optimize-LocalSystem {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ParameterSetName='IndividualParams')]
        [ValidateSet('CleanTempFiles', 'CheckUpdates')]
        [string]$Operation,

        [Parameter(Mandatory, ParameterSetName='CSVInput')]
        [PSCustomObject]$CSVRow
    )
    switch ($PSCmdlet.ParameterSetName) {
        'CSVInput' { 
            $Operation = $CSVRow.Operation
        }
    }
    switch ($Operation) {
        'CheckUpdates' { 
            Write-Host 'Check for Windows updates.'
        }
        'CleanTempFiles' {
            if ($PSCmdlet.ShouldProcess('Temporary files', 'Remove')) { 
                Remove-Item "C:\Temp\NonExistentFile.txt" -ErrorAction Stop
                Write-Host 'Cleaning temp files.'
            }
        }
        Default {
            Write-Error "Invalid operation. You chose $_, but that option is not handled in the switch statement."
        }
    }
}