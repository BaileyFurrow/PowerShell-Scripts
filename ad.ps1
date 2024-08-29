# This file contains many AD-related commands to make certain AD actions and queries easier and faster to type.
function Get-ADPhone {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position=0, ParameterSetName="Username")]
        [string] $Identity,
        [Parameter(Mandatory, ParameterSetName="Name")]
        [string] $Name,
        # Only return value
        [Parameter()]
        [switch] $Value,
        # Select default telephone number
        [Parameter()]
        [switch] $Telephone,
        # Select home phone
        [Parameter()]
        [switch] $HomePhone,
        # Select mobile
        [Parameter()]
        [Alias("Cell", "CellPhone", "MobilePhone", "SmartPhone")]
        [switch] $Mobile,
        # Select fax
        [Parameter()]
        [switch] $Fax,
        # Select IP Phone
        [Parameter()]
        [switch] $ipPhone,
        # Select all phone numbers
        [Parameter()]
        [switch] $All
    )
    begin {
        if (-Not ($Telephone -or $HomePhone -or $Mobile -or $Fax -or $ipPhone -or $All)) {
            # Select Telephone and ipPhone by default
            $Telephone = $true
            $ipPhone = $true
        }
        if ($All) {
            $Telephone = $true
            $HomePhone = $true
            $Mobile = $true
            $Fax = $true
            $ipPhone = $true
        }
    }
    process {
        if ($Identity) {
            $user = Get-ADUser -Identity $Identity -Properties *
        } else {
            $user = Get-ADUser -Filter "Name -like '$Name'" -Properties *
        }
        $result = [ordered]@{}
        $result.Add("Name", $user.Name)
        $result.Add("Username", $user.SamAccountName)
        if ($Telephone) {
            $result.Add('Telephone', $user.telephone)
        }
        if ($HomePhone) {
            $result.Add('Home Phone', $user.HomePhone)
        }
        if ($Mobile) {
            $result.Add('Cell Phone', $user.Mobile)
        }
        if ($Fax) {
            $result.Add('Fax', $user.Fax)
        }
        if ($ipPhone) {
            $result.Add('IP Phone', $user.ipPhone)
        }
        if ($Value) {
            return $result[2..$result.count]
        } else {
            return $result
        }
    }
}
function Get-ADOffice {
    param (
        [CmdletBinding()]
        [Parameter(Mandatory, Position=0, ParameterSetName="Username")]
        [string]
        $Identity,
        # Search by name
        [Parameter(Mandatory, ParameterSetName="Name")]
        [string]
        $Name,
        # Return value only
        [Parameter()]
        [switch]
        $Value
    )
    if ($Identity) {
        $user = Get-ADUser -Identity $Identity -Properties physicalDeliveryOfficeName
    } else {
        $user = Get-ADUser -Filter "Name -like '*$Name*'" -Properties physicalDeliveryOfficeName
    }
    $result = [ordered]@{}
    $result.Add("Name", $user.Name)
    $result.Add("Username", $user.SamAccountName)
    $result.Add("Office", $user.physicalDeliveryOfficeName)
    if ($Value) {
        return $result[2..$result.count]
    } else {
        return $result
    }
}
