function Format-Size {
    param (
        [CmdletBinding()]
        # Input to format
        [Parameter(Mandatory,Position=0,ValueFromPipeline)]
        [double[]] $InputObject,

        # Specifies the input format. Default is byte.
        [Parameter()]
        [PSDefaultValue(Help="B")]
        [ValidateSet("B","KB","MB","GB")]
        [string] $InputFormat = "B",

        # Specifies the output format.
        [Parameter(Position=1)]
        [ValidateSet("","B","KB","MB","GB")]
        [string] $OutputFormat,

        # Returns the value as a double instead of a string with the format appended
        [Parameter()]
        [Alias("AsValue","AsNumber")]
        # [ValidateScript({ $InputObject.Length -eq 1 -or $OutputFormat })]
        [switch] $AsDouble
    )

    begin {
        $InputFormat = $InputFormat.ToUpper()
        $OutputFormat = $OutputFormat.ToUpper()

        # Validate -AsDouble parameter
        if ($AsDouble -and ($InputObject.Length -gt 1 -and -not $OutputFormat)){
            throw [System.ArgumentException]::new("The -AsDouble switch can only be used if the -InputObject has a length of 1 or if an -OutputFormat is specified.")
        }
        function Get-FormattedSize($ByteValue, $Unit) {
            if ($Unit -eq "B") {
                $doubleValue = $ByteValue
            } else {
                $doubleValue = Invoke-Expression "$ByteValue / 1$Unit"
            }
            $doubleValue
        }
        
        # Truncates a provided double to a minimum total length of 4 (including the decimal place).
        function Format-Truncated($LengthyValue) {
            $isSmallNumber = $LengthyValue -eq [System.Math]::Ceiling($LengthyValue)
            if ($LengthyValue -ge 1000 -or $isSmallNumber) {
                $formattedValue = [System.Math]::Round($LengthyValue)
            } else {
                $formattedValue = [double]("$LengthyValue".Substring(0,4))
            }
            $formattedValue
        }
    }

    process {
        $output = $InputObject | ForEach-Object {
            $ByteSize = -1

            # Get the byte size of the input value
            if ($InputFormat -eq "B") {
                $ByteSize = $_
            } else {
                $ByteSize = Invoke-Expression "$_ * 1$InputFormat"
            }

            # If no OutputFormat is specified, dynamically determine unit to use.
            if (-not $OutputFormat) {
                $OutputFormat = switch ($ByteSize) {
                    { $_ -ge 1gb } {
                        "GB"
                        continue
                    }
                    { $_ -ge 1mb } {
                        "MB"
                        continue
                    }
                    { $_ -ge 1kb } {
                        "KB"
                        continue
                    }
                    Default {
                        "B"
                    }
                }
            } 
            $value = Get-FormattedSize $ByteSize $OutputFormat
            if ($AsDouble) {
                return $value
            } else {
                $truncValue = Format-Truncated $value
                return "$truncValue $OutputFormat"
            }
            
        }
        $output
    }
}