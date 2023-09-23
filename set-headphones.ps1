$audio = Get-AudioDevice -List | Where-Object Name -Like "Main*"
Set-AudioDevice -ID $audio.ID
