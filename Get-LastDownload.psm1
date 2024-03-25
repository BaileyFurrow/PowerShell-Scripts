
function Get-LastDownload() {
# Gets the last download.
    return (Get-ChildItem $DW | Sort-Object LastWriteTime)[-1]
}
