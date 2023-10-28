function Restart-Chromebox() {
# This function restarts the chromebox and uses Test-Connection to find out when it returns online.
    ssh -t bailey@chromebox "sudo reboot"
    Write-Host "Waiting for Chromebox to shutdown..."
    Start-Sleep 5
    Write-Host "Waiting for Chromebox to boot..."
    $ttboot = Measure-Command {while (!(Test-Connection chromebox -quiet -count 1)) {
        Start-Sleep 1
    }}
    Write-Host "Booted! Time elasped: $($ttboot.Minutes):$('{0:d2}' -f $ttboot.Seconds)"
    Write-Host "Waiting for OctoPrint server to start..."
    $ttstart = Measure-Command {while (!(Test-NetConnection chromebox -port 5000 -informationlevel quiet -WarningAction SilentlyContinue)) {
        Start-Sleep 1
    }}
    Write-Host "Started! Time elapsed: $($ttstart.Minutes):$('{0:d2}' -f $ttstart.Seconds)"
}

Export-ModuleMember -Function Restart-Chromebox
