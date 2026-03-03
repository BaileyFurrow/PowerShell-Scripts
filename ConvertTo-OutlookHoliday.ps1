
[CmdletBinding()]
param (
    [Parameter(Position=0)]
    [string] $InputPath,

    [Parameter(Position=1)]
    [string] $OutputPath
)

if (-not $InputPath) {
    # Create Open File GUI to select CSV file.
    Add-Type -AssemblyName System.Windows.Forms
    $openDiag = [System.Windows.Forms.OpenFileDialog]::new()
    $filterList = @(
        'CSV Files (*.csv)|*.csv'
        'Excel Files (*.xlsx, *.xls)|*.xlsx;*.xls'
    )
    $openDiag.Filter = $filterList -join '|'
    $openDiag.Title = 'Select Data File to Convert to Outlook Holiday File'
    $result = $openDiag.ShowDialog()
    if ($result -ne 'OK') {
        exit
    }
    $InputPath = $openDiag.FileName
}

# Ensure $InputPath is the valid format and import
$file = Get-Item $InputPath
if ($file.Extension -notin @('.csv','.xls','.xlsx')) {
    throw [System.IO.FileFormatException]::new('Incorrect file type. Please select a CSV or Excel file and try again.')
}
$fileContents = ''
if ($file.Extension -match '\.xlsx?') {
    $tmpFile = New-TemporaryFile
    $excel = New-Object -ComObject Excel.Application
    $workbook = $excel.Workbooks.Open($file)
    $workbook.SaveAs("$tmpFile", 6)
    $workbook.Close()
    $excel.Quit()

    $fileContents = Get-Content $tmpFile
} else {
    $fileContents = Get-Content $file
}

$sections        = @()
$currentRegion   = $null
$currentHolidays = @()

foreach ($rawLine in $fileContents) {
    $line = $rawLine.TrimEnd(',').Trim()
    if (-not $line) { continue }

    # New region header: [Region Name]
    if ($line -match '^\[(.+)\]$') {
        # Flush previous region (if any)
        if ($currentRegion -and $currentHolidays.Count -gt 0) {
            $sections += [pscustomobject]@{
                Region   = $currentRegion
                Holidays = $currentHolidays
            }
        }
        $currentRegion   = $matches[1]
        $currentHolidays = @()
        continue
    }
    # Holiday line: Name,Date
    $parts = $line.Split(',')
    if ($parts.Count -ne 2) {
        $lineNum = $fileContents.IndexOf($line) + 1
        throw "Invalid holiday name at row $lineNum (expected 'Name,Date'): '$line'.`nThis is likely due to a comma being used in a holiday name. Remove all errant commas and try again."
    }

    $name       = $parts[0].Trim()
    $dateString = $parts[1].Trim()
    $date = [datetime]$dateString
    $currentHolidays += [pscustomobject]@{
        Name = $name
        Date = $date
    }
}

# Flush last region
if ($currentRegion -and $currentHolidays.Count -gt 0) {
    $sections += [pscustomobject]@{
        Region   = $currentRegion
        Holidays = $currentHolidays
    }
}

if (-not $sections) {
    throw "No regions/holidays were parsed from input."
}

# Build .hol output
$outLines = @()

foreach ($section in $sections) {
    $outLines += ('[{0}] {1}' -f $section.Region, $section.Holidays.Count)

    foreach ($h in $section.Holidays) {
        $outLines += ('{0}, {1:yyyy/MM/dd}' -f $h.Name, $h.Date)
    }
}

if (-not $OutputPath) {
    # Import forms again in case input path was provided
    Add-Type -AssemblyName System.Windows.Forms
    $saveDiag = [System.Windows.Forms.SaveFileDialog]::new()
    $saveDiag.Filter = 'Outlook Holiday File (*.hol)|*.hol'
    $saveDiag.Title = 'Save Holiday File As...'
    $result = $saveDiag.ShowDialog()
    $OutputPath = $saveDiag.FIleName
}

$outLines | Set-Content -Path $OutputPath
$outLines