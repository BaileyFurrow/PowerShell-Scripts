function Measure-Lines {
    param (
        [Parameter(ValueFromPipeline=$true)]
        [string[]]$pipe,
        [string]$Path
    )
    process {
        if ($Path) {
            $out = Get-Content $Path | Measure-Object -Line
        } else {
            $out = $pipe | Measure-Object -Line
        }
        return $out.Lines
    }
}