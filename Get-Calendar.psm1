
# WIP!!!!!!!!!

# EXAMPLE:
#
#      August 2023
# Su Mo Tu We Th Fr Sa
#        1  2  3  4  5
#  6  7  8  9 10 11 12
# 13 14 15 16 17 18 19
# 20 21 22 23 24 25 26
# 27 28 29 30 31

# Key:
#    -1    Display single month output. (default)
#    -3    Display prev/current/next month output.
#    -s    Display Sunday as the first day of the week.
#    -m    Display monday as the first day of the week.
#    -j    Display julian dates (days one-based, numbered from January 1).
#    -y    Display a calendar for the current year.
#    -V    Display version information and exit.

function Get-Calendar {

    param(
        [switch]$3,
        [switch]$s,
        [switch]$m,
        [switch]$j,
        [switch]$y,
        [switch]$V,

        [Parameter(Position=0)]
        [int]$Day = (Get-Date).Day,

        [Parameter(Position=1)]
        [int]$Month = (Get-Date).Month,

        [Parameter(Position=2)]
        [int]$Year = (Get-Date).Year
    )

}
