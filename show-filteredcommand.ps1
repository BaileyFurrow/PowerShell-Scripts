
function Show-FilteredCommand {
    [CmdletBinding(DefaultParameterSetName='ByName')]
    param(
        [Parameter(Mandatory, Position=0)]
        [ValidateNotNullOrEmpty()]
        [string]$CommandName,

        # Parameters to keep in the displayed command
        [string[]]$Include,

        # Parameters to remove from the displayed command
        [string[]]$Exclude,

        # Keeps the proxy command for debugging purposes
        [switch]$KeepProxy
    )

    begin {
        function Resolve-Names([string[]]$patterns) {
            if (-not $patterns) { return @() }
            $allKeys = $paramTable.Keys
            $hits = foreach ($p in $patterns) {
                if ($p -like '*[*?]*') {
                    foreach ($k in $allKeys) { if ($k -like $p) { $k } }
                } else {
                    $allKeys | Where-Object { $_ -ieq $p }
                }
            }
            ($hits | Sort-Object -Unique | ForEach-Object { $paramTable[$_] }) | Sort-Object -Unique
        }
    }

    process {
        # Resolve the command and build editable metadata
        $cmdInfo = Get-Command -Name $CommandName -ErrorAction Stop
        $meta    = [System.Management.Automation.CommandMetadata]::new($cmdInfo)

        # Build a map of canonical parameter names and their aliases
        $paramTable = @{} # aliasOrName -> realName
        foreach ($parameter in $meta.Parameters.GetEnumerator()) {
            $real = $parameter.Key
            $paramTable[$real] = $real
            foreach ($aliasName in $parameter.Value.Aliases) { $paramTable[$aliasName] = $real }
        }

        # Helper to expand Include/Exclude (supports wildcards on names/aliases)

        $includeReal = Resolve-Names $Include
        $excludeReal = Resolve-Names $Exclude

        # Apply Include first (whitelist), then Exclude (blacklist)
        if ($includeReal.Count) {
            foreach ($name in @($meta.Parameters.Keys)) {
                if ($includeReal -notcontains $name) { [void]$meta.Parameters.Remove($name) }
            }
        }
        if ($excludeReal.Count) {
            foreach ($name in $excludeReal) { [void]$meta.Parameters.Remove($name) }
        }

        # Create a temporary proxy function with the filtered metadata
        $proxyBody = [System.Management.Automation.ProxyCommand]::Create($meta)
        $tempName  = "ShowCmd_$($cmdInfo.Name -replace '[^\w]+','_')_$([guid]::NewGuid().ToString('N').Substring(0,8))"
        Set-Item -Path ("Function:\{0}" -f $tempName) -Value $proxyBody

        try {
            $cmdString = Show-Command -Name $tempName -PassThru
        }
        finally {
            if (-not $KeepProxy) { Remove-Item ("Function:\$tempName") -ErrorAction SilentlyContinue }
        }
        $cmdString = $cmdString -replace "$tempName", $CommandName
        if (Get-Module PSReadLine -ErrorAction SilentlyContinue) {
            [Microsoft.PowerShell.PSConsoleReadLine]::AddToHistory($cmdString)
        } else {
            Import-Module PSReadLine -ErrorAction SilentlyContinue
        }
        if (-not [string]::IsNullOrEmpty($cmdString)) {
            Invoke-Expression $cmdString
        }
    }
}

# Only show -Name and -Id (including alias matching) for Get-Process
Show-FilteredCommand Get-ChildItem -Include Path, File, Directory, Force
