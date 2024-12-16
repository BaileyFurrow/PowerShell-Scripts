function Format-Size {
    param (
        # Input to format
        [Parameter(Mandatory,ValueFromPipeline)]
        [double[]] $InputObject,

        # Specifies the input format. Default is byte.
        [Parameter()]
        [PSDefaultValue(Help="B")]
        [ValidateSet("B","KB","MB","GB")]
        [string] $InputFormat = "B",

        # Specifies the output format. Must be declared.
        # TODO: Add dynamic option and make it default.
        [Parameter(Position=0)]
        [PSDefaultValue(Help="Dynamically set based on size.")]
        [ValidateSet("Dynamic","B","KB","MB","GB")]
        [string] $OutputFormat = "Dynamic",

        # Returns the value as a double instead of a string with the format appended
        [Parameter()]
        [Alias("AsValue","AsNumber")]
        [switch] $AsDouble
    )

    $InputFormat = $InputFormat.ToUpper()
    $OutputFormat = $OutputFormat.ToUpper()

    $output = $InputObject | ForEach-Object {
        $ByteSize = -1
        if ($InputFormat -eq "B") {
            $ByteSize = $_
        } else {
            $ByteSize = Invoke-Expression "$_ * 1$InputFormat"
        }
        if ($OutputFormat -eq "B") {
            $value = $ByteSize
        } else {
            $value = Invoke-Expression "$ByteSize / 1$OutputFormat"
        }
        if ($OutputFormat -eq "DYNAMIC") {
            # TODO: Dynamic logic
            throw [System.NotImplementedException]::new("Dynamic feature has not been set up yet. Specify an option for -OutputFormat.")
        } else {
            if ($AsDouble) {
                return $value
            } else {
                if ($value -ge 1000) {
                    $formattedValue = [System.Math]::Round($value)
                } else {
                    $formattedValue = [double]("$value".Substring(0,4))
                }
                return "$formattedValue $OutputFormat"
            }
        }
    }
    return $output
}