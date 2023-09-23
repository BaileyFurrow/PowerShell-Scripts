$audio = Get-AudioDevice -List | Where-Object Name -Like "Speakers*"
Set-AudioDevice -ID $audio.ID
