function Get-Monitors($computerName=$env:COMPUTERNAME) {
    $results = @()
    Get-CimInstance -ClassName WMIMonitorID -Namespace root\wmi | ForEach-Object {
        $man = [System.Text.Encoding]::ASCII.GetString($_.ManufacturerName).Trim(0x00)
        $prod = [System.Text.Encoding]::ASCII.GetString($_.ProductCodeID).Trim(0x00)
        $serial = [System.Text.Encoding]::ASCII.GetString($_.SerialNumberID).Trim(0x00)
        $name = [System.Text.Encoding]::ASCII.GetString($_.UserFriendlyName).Trim(0x00)

        $sizes = Get-CimInstance wmimonitorbasicdisplayparams -Namespace root\wmi | 
            Where-Object InstanceName -like $_.InstanceName
        $diagSize = ([System.Math]::Round(([System.Math]::Sqrt([System.Math]::Pow($Sizes.MaxHorizontalImageSize, 2) + [System.Math]::Pow($sizes.MaxVerticalImageSize, 2)) / 2.54), 0))
        
        $obj = [PSCustomObject]@{
            Manufacturer = $man
            Name         = $name
            ProductID    = $prod
            Serial       = $serial
            Size         = $diagSize
        }
        $results += $obj
    }
    return $results
}