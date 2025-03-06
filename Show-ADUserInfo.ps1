Add-Type -AssemblyName System.Windows.Forms

function Get-ADUserInfo {
    param (
        [string]$SamAccountName
    )
    
    try {
        if ($Debug -eq $true) {
            # Simulated test data
            $PasswordLastSetDate = [datetime]"2024-03-01"
            $DaysSincePassword = (New-TimeSpan -Start $PasswordLastSetDate -End (Get-Date)).Days

            $User = [PSCustomObject]@{
                Name              = "John Doe"
                SamAccountName    = "jdoe"
                Office            = "New York"
                Email             = "jdoe@example.com"
                Info              = "Test user for GUI"
                CustomAttribute15 = "Test Attribute"
                Manager           = "Jane Smith"
                Title             = "IT Specialist"
                Department        = "IT"
                LockedOut         = "False"
                PasswordExpired   = "False"
                PasswordLastSet   = $PasswordLastSetDate.ToString("yyyy-MM-dd")
                MemberOf          = "Domain Users, IT Group"
            }
            $User | Add-Member -MemberType NoteProperty -Name DaysSincePassword -Value "$DaysSincePassword"
            $User | Add-Member -MemberType AliasProperty -Name Username -Value SamAccountName
            $User | Add-Member -MemberType AliasProperty -Name CostCenter -Value CustomAttribute15
        }
        else {
            # Retrieve real data from AD
            $User = Get-ADUser -Identity $SamAccountName -Properties Office, EmailAddress, Info, CustomAttribute15, Manager, Title, Department, LockedOut, PasswordExpired, PasswordLastSet, MemberOf
            
            if ($User) {
                $PasswordLastSetDate = $User.PasswordLastSet
                $DaysSincePassword = (New-TimeSpan -Start $PasswordLastSetDate -End (Get-Date)).Days
                $Manager = if ($User.Manager) { (Get-ADUser -Identity $User.Manager).Name } else { "N/A" }
                $MemberOf = ($User.MemberOf | Get-ADGroup | Select-Object -ExpandProperty Name) -join ", "
                
                $User | Add-Member -MemberType NoteProperty -Name DaysSincePassword -Value "$DaysSincePassword"
                $User | Add-Member -MemberType AliasProperty -Name Username -Value SamAccountName
                $User | Add-Member -MemberType AliasProperty -Name CostCenter -Value CustomAttribute15
            }
        }
        
        return $User
    }
    catch {
        [System.Windows.Forms.MessageBox]::Show("User not found or error retrieving data.", "Error", "OK", "Error")
    }
    return $null
}

# Create the Form
$form = New-Object System.Windows.Forms.Form
$form.Text = "AD User Information"
$form.StartPosition = "CenterScreen"
$form.Size = New-Object System.Drawing.Size(550, 500)

# Create TableLayoutPanel
$tableLayout = New-Object System.Windows.Forms.TableLayoutPanel
$tableLayout.Dock = [System.Windows.Forms.DockStyle]::Fill
$tableLayout.AutoSize = $true
$tableLayout.ColumnCount = 6
$form.Controls.Add($tableLayout)

# Define column styles
$tableLayout.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::AutoSize)))
$tableLayout.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::AutoSize)))
$tableLayout.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::AutoSize)))
$tableLayout.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::AutoSize)))
$tableLayout.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::AutoSize)))
$tableLayout.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::AutoSize)))

# Define AutoComplete source
$autoComplete = New-Object System.Windows.Forms.AutoCompleteStringCollection
$allADUsers = Get-ADUser -Filter * -Properties Name, SamAccountName
$autoComplete.AddRange($allADUsers.SamAccountName)

# Username Input Row
$tableLayout.RowCount++
$tableLayout.Controls.Add((New-Object System.Windows.Forms.Label -Property @{Text = "Username:" }), 0, 0)
$textUser = New-Object System.Windows.Forms.TextBox -Property @{
    Width                    = 300
    AutoCompleteCustomSource = $autoComplete
    AutoCompleteMode         = [System.Windows.Forms.AutoCompleteMode]::SuggestAppend
    AutoCompleteSource       = [System.Windows.Forms.AutoCompleteSource]::CustomSource
}
$tableLayout.SetColumnSpan($textUser, 4)
$tableLayout.Controls.Add($textUser, 1, 0)
$buttonSearch = New-Object System.Windows.Forms.Button -Property @{Text = "Search" }
$tableLayout.Controls.Add($buttonSearch, 5, 0)
$form.AcceptButton = $buttonSearch

# Create empty row
$tableLayout.RowCount++
$tableLayout.Controls.Add((New-Object System.Windows.Forms.Label -Property @{Text = "" }), 0, $tableLayout.RowCount - 1)
$tableLayout.SetColumnSpan((New-Object System.Windows.Forms.Label -Property @{Text = "" }), 6)

# Labels, Read-Only Text Fields, and Copy Buttons for Results
$fields = @("Name", "Username", "Office", "Email", "Info", "CostCenter", "Manager", "Title", "Department", "MemberOf")
$textBoxes = @{}

foreach ($field in $fields) {
    $tableLayout.RowCount++
    $tableLayout.Controls.Add((New-Object System.Windows.Forms.Label -Property @{Text = "$field`:" }), 0, $tableLayout.RowCount - 1)
    
    $textBox = New-Object System.Windows.Forms.TextBox -Property @{ReadOnly = $true; Width = 300 }
    $tableLayout.SetColumnSpan($textBox, 4)
    $tableLayout.Controls.Add($textBox, 1, $tableLayout.RowCount - 1)
    $textBoxes[$field] = $textBox
    
    $copyButton = New-Object System.Windows.Forms.Button -Property @{Text = "Copy"}
    $copyButton.Tag = $textBox
    $copyButton.Add_Click({
        param($sender, $eventArgs)
        [System.Windows.Forms.Clipboard]::SetText($sender.Tag.Text)
    })
    $tableLayout.Controls.Add($copyButton, 5, $tableLayout.RowCount - 1)
}

# Place LockedOut and PasswordExpired on the same row
$tableLayout.RowCount++
$tableLayout.Controls.Add((New-Object System.Windows.Forms.Label -Property @{Text = "LockedOut:" }), 0, $tableLayout.RowCount - 1)
$textLockedOut = New-Object System.Windows.Forms.TextBox -Property @{ReadOnly = $true; Width = 125 }
$tableLayout.SetColumnSpan($textLockedOut, 2)
$tableLayout.Controls.Add($textLockedOut, 1, $tableLayout.RowCount - 1)
$textBoxes["LockedOut"] = $textLockedOut

$tableLayout.Controls.Add((New-Object System.Windows.Forms.Label -Property @{Text = "PasswordExpired:" }), 3, $tableLayout.RowCount - 1)
$textPasswordExpired = New-Object System.Windows.Forms.TextBox -Property @{ReadOnly = $true; Width = 125 }
$tableLayout.SetColumnSpan($textPasswordExpired, 2)
$tableLayout.Controls.Add($textPasswordExpired, 4, $tableLayout.RowCount - 1)
$textBoxes["PasswordExpired"] = $textPasswordExpired

# Place PasswordLastSet and DaysSincePassword on the same row
$tableLayout.RowCount++
$tableLayout.Controls.Add((New-Object System.Windows.Forms.Label -Property @{Text = "PasswordLastSet:"; Width = 125 }), 0, $tableLayout.RowCount - 1)
$textPasswordLastSet = New-Object System.Windows.Forms.TextBox -Property @{ReadOnly = $true; Width = 125 }
$tableLayout.SetColumnSpan($textPasswordLastSet, 2)
$tableLayout.Controls.Add($textPasswordLastSet, 1, $tableLayout.RowCount - 1)
$textBoxes["PasswordLastSet"] = $textPasswordLastSet

$tableLayout.Controls.Add((New-Object System.Windows.Forms.Label -Property @{Text = "DaysSincePassword:"; Width = 125 }), 3, $tableLayout.RowCount - 1)
$textDaysSincePassword = New-Object System.Windows.Forms.TextBox -Property @{ReadOnly = $true; Width = 125 }
$tableLayout.SetColumnSpan($textDaysSincePassword, 2)
$tableLayout.Controls.Add($textDaysSincePassword, 4, $tableLayout.RowCount - 1)
$textBoxes["DaysSincePassword"] = $textDaysSincePassword

# Search Button Click Event
$buttonSearch.Add_Click({
        $UserInfo = Get-ADUserInfo -SamAccountName $textUser.Text
        if ($UserInfo) {
            foreach ($field in $fields + $fieldsBool1 + $fieldsBool2) {
                $textBoxes[$field].Text = $UserInfo.$field
            }
        }
        else {
            foreach ($field in $fields + $fieldsBool1 + $fieldsBool2) {
                $textBoxes[$field].Text = ""
            }
        }
    })

# Pressing 'Enter' will perform search action
# $textUser.Add_KeyDown({
#     if ($_.KeyCode -eq [System.Windows.Forms.Keys]::Enter) {
#         $buttonSearch.PerformClick()
#         $_.SuppressKeyPress = $true
#     }
# })

# Show Form
$form.ShowDialog()
