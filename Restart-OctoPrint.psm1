function Restart-OctoPrint() {
# This function restarts the OctoPrint service on the Chromebox.
    ssh -t bailey@dells-hells "systemctl restart octoprint"
    Write-Host "Waiting for OctoPrint server to start..."
    $ttstart = Measure-Command {while (!(Test-NetConnection dells-hells -port 5000 -informationlevel quiet -WarningAction SilentlyContinue)) {
        Start-Sleep 1
    }}
    Write-Host "Started! Time elapsed: $($ttstart.Minutes):$('{0:d2}' -f $ttstart.Seconds)"
}

Export-ModuleMember -Function Restart-OctoPrint
