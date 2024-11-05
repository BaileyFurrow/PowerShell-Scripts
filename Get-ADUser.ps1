function Get-ADUser {
    [CmdletBinding()]
    param (
        # Username to lookup
        [Parameter(Mandatory,Position=0,ParameterSetName="Identity")]
        [string[]]
        $Identity,

        # Filter by value
        [Parameter(Mandatory,ParameterSetName="Filter")]
        [string]
        $Filter
    )
    
    begin {
        
    }
    
    process {
        
    }
    
    end {
        
    }
}