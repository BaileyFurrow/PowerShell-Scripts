
       $date = Get-Date
       $MonthName = $date.ToString("MMMM")
       $first = Get-Date -Day 1


       Write-Host "$MonthName $Year"
       Write-Host "Su Mo Tu We Th Fr Sa"
       $MyInvocation
