param(
    [string]$InitialUsername
)

Add-Type -AssemblyName System.Windows.Forms

function Get-ADUserInfo {
    param (
        [string]$SamAccountName
    )
    
    try {
        # Retrieve real data from AD
        $User = Get-ADUser -Identity $SamAccountName -Properties Office, Mail, Info, ExtensionAttribute15, Manager, Title, Department, LockedOut, PasswordExpired, PasswordLastSet, MemberOf, IPPhone
            
        if ($User) {
            $PasswordLastSetDate = $User.PasswordLastSet
            $DaysSincePassword = (New-TimeSpan -Start $PasswordLastSetDate -End (Get-Date)).Days
            # $Manager = if ($User.Manager) { (Get-ADUser -Identity $User.Manager).Name } else { "N/A" }
            # $MemberOf = ($User.MemberOf | Get-ADGroup | Select-Object -ExpandProperty Name) -join ", "
                
            $User | Add-Member -Force -MemberType NoteProperty -Name DaysSincePassword -Value "$DaysSincePassword"
            $User | Add-Member -Force -MemberType AliasProperty -Name Username -Value SamAccountName
            $User | Add-Member -Force -MemberType AliasProperty -Name CostCenter -Value ExtensionAttribute15
        }
        Write-Host $user
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
# $form.StartPosition = "CenterScreen"
$form.Size = New-Object System.Drawing.Size(550, 510)
$form.MaximizeBox = $false
$form.FormBorderStyle = 'FixedDialog'

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
$autoComplete.AddRange($allADUsers.SamAccountName -split " ")

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

function Add-UserInfoRow ([string]$fieldName, [string]$buttonName, [scriptblock]$buttonAction) {
    $tableLayout.RowCount++
    $tableLayout.Controls.Add((New-Object System.Windows.Forms.Label -Property @{Text = "$fieldName`:" }), 0, $tableLayout.RowCount - 1)

    $textBox = New-Object System.Windows.Forms.TextBox -Property @{ReadOnly = $true; Width = 300 }
    $tableLayout.SetColumnSpan($textBox, 4)
    $tableLayout.Controls.Add($textBox, 1, $tableLayout.RowCount - 1)
    $textBoxes[$fieldName] = $textBox

    $button = New-Object System.Windows.Forms.Button -Property @{Text = $buttonName }
    $button.Tag = $textBox
    if ($buttonName -ieq "Copy") {
        $button.Add_Click({
                param($sender, $eventArgs)
                [System.Windows.Forms.Clipboard]::SetText($sender.Tag.Text)
            })
    }
    elseif ($buttonName -ieq "More...") {
        $button.Add_Click($buttonAction)
    }
    else {
        throw "Invalid button type."
    }
    $tableLayout.Controls.Add($button, 5, $tableLayout.RowCount - 1)
    $buttons[$fieldName] = $button
}

# Labels, Read-Only Text Fields, and Copy Buttons for Results
$fields = @("Name", "Username", "Office", "Mail", "IPPhone", "Info", "CostCenter", "Manager", "Title", "Department", "MemberOf", "LockedOut", "PasswordExpired", "PasswordLastSet", "DaysSincePassword")
$textBoxes = @{}
$buttons = @{}

Add-UserInfoRow Name Copy
Add-UserInfoRow Username Copy
Add-UserInfoRow Office Copy
Add-UserInfoRow Mail Copy
Add-UserInfoRow IPPhone Copy
Add-UserInfoRow Info Copy
Add-UserInfoRow CostCenter Copy
Add-UserInfoRow Manager "More..." {
    param($sender, $eventArgs)
    [System.Windows.Forms.Cursor]::Current = [System.Windows.Forms.Cursors]::WaitCursor
    $managerUsername = (Get-ADUser $textBoxes['Manager'].Text).SamAccountName
    . $PSScriptRoot\Show-ADUserInfo.ps1 $managerUsername
    [System.Windows.Forms.Cursor]::Current = [System.Windows.Forms.Cursors]::Default
}
Add-UserInfoRow Title Copy
Add-UserInfoRow Department Copy
Add-UserInfoRow MemberOf "More..." {
    param($sender, $eventArgs)
    $groups = (Get-ADUser $textBoxes['Username'].Text -Properties MemberOf).MemberOf
    $groupNames = @()
    foreach ($group in $groups) {
        $groupNames += (Get-ADGroup $group -ErrorAction SilentlyContinue).Name ?? $group
    }
    $groupNames = $groupNames | Sort-Object
    . $PSScriptRoot\MoreInfoWindow.ps1 $groupNames "AD Groups - $($textBoxes['Username'].Text)"
}

# foreach ($field in $fields) {
#     $tableLayout.RowCount++
#     $tableLayout.Controls.Add((New-Object System.Windows.Forms.Label -Property @{Text = "$field`:" }), 0, $tableLayout.RowCount - 1)
    
#     $textBox = New-Object System.Windows.Forms.TextBox -Property @{ReadOnly = $true; Width = 300 }
#     $tableLayout.SetColumnSpan($textBox, 4)
#     $tableLayout.Controls.Add($textBox, 1, $tableLayout.RowCount - 1)
#     $textBoxes[$field] = $textBox
    
#     $copyButton = New-Object System.Windows.Forms.Button -Property @{Text = "Copy" }
#     $copyButton.Tag = $textBox
#     $copyButton.Add_Click({
#             param($sender, $eventArgs)
#             [System.Windows.Forms.Clipboard]::SetText($sender.Tag.Text)
#         })
#     $tableLayout.Controls.Add($copyButton, 5, $tableLayout.RowCount - 1)
# }

# MemberOf needs a special button
# $tableLayout.RowCount++
# $tableLayout.Controls.Add((New-Object System.Windows.Forms.Label -Property @{Text = "MemberOf:" }), 0, $tableLayout.RowCount - 1)

# $textMemberOf = New-Object System.Windows.Forms.TextBox -Property @{ReadOnly = $true; Width = 300 }
# $tableLayout.SetColumnSpan($textMemberOf, 4)
# $tableLayout.Controls.Add($textMemberOf, 1, $tableLayout.RowCount - 1)
# $textBoxes['MemberOf'] = $textMemberOf

# $moreButton = New-Object System.Windows.Forms.Button -Property @{Text = 'More...' }
# $moreButton.tag = $textMemberOf
# $moreButton.Add_Click({
#         param($sender, $eventArgs)
#         $groups = (Get-ADUser $textBoxes['Username'].Text -Properties MemberOf).MemberOf
#         $groupNames = @()
#         foreach ($group in $groups) {
#             $groupNames += (Get-ADGroup $group).Name
#         }
#         . $PSScriptRoot\MoreInfoWindow.ps1 $groupNames "AD Groups - $($textBoxes['Username'].Text)"
#     })
# $tableLayout.Controls.Add($moreButton, 5, $tableLayout.RowCount - 1)

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
$toolPasswordExpiry = New-Object System.Windows.Forms.ToolTip
$toolPasswordExpiry.SetToolTip($textDaysSincePassword, "Passwords expire after 90 days.")

# Take action on accounts
$tableLayout.RowCount++
$accountActions = [ordered]@{
    Unlock        = New-Object System.Windows.Forms.Button -Property @{Text = "Unlock Account" }
    ResetPassword = New-Object System.Windows.Forms.Button -Property @{Text = "Reset Password" }
    EmailUser     = New-Object System.Windows.Forms.Button -Property @{Text = "Email User" }
    CallUser      = New-Object System.Windows.Forms.Button -Property @{Text = "Call User" }
}
$buttonFlow = New-Object System.Windows.Forms.FlowLayoutPanel
$buttonFlow.AutoSize = $true
$buttonFlow.WrapContents = $false
$buttonFlow.FlowDirection = [System.Windows.Forms.FlowDirection]::LeftToRight
foreach ($action in $accountActions.Keys) {
    $accountActions[$action].AutoSize = $true
    $buttonFlow.Controls.Add($accountActions[$action])
}
$tableLayout.SetColumnSpan($buttonFlow, 6)
$tableLayout.Controls.Add($buttonFlow, 0, $tableLayout.RowCount - 1)

#region Button Events

# Click events for account actions
$accountActions['Unlock'].Add_Click({
        try {
            if (-not ([System.Security.Principal.WindowsPrincipal][System.Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) {
                throw [System.AccessViolationException]::new("The current user is not an administrator or does not have access. Please try again as admin.")
            }
            $AccountUnlock = Get-ADUser -Identity $textBoxes['Username'].Text | Unlock-ADAccount -PassThru
            $isAccountLocked = [bool]$AccountUnlock.LockedOut
            if ($isAccountLocked) {
                throw "Unhandled exception: Account not unlocked. Please contact Bailey."
            }
            else {
                [System.Windows.Forms.MessageBox]::Show(
                    "$($AccountUnlock.SamAccountName) successfully unlocked!",
                    "Account Unlock Successful",
                    [System.Windows.Forms.MessageBoxButtons]::OK,
                    [System.Windows.Forms.MessageBoxIcon]::None
                )
            }
        }
        catch {
            [System.Windows.Forms.MessageBox]::Show($_.ToString(), "Error", "OK", "Error")
        }
    })

$accountActions['ResetPassword'].Add_Click({
        $sendToForm = [System.Windows.Forms.Form]::new()
        $sendToForm.Text = "Manager Or User"
        $sendToForm.Size = [System.Drawing.Size]::new(300, 150)
        $sendToForm.StartPosition = 'CenterParent'
        $sendToForm.FormBorderStyle = 'FixedToolWindow'

        $lblPrompt = [System.Windows.Forms.Label]::new()
        $lblPrompt.Text = "Send temporary password to manager or user?"
        $lblPrompt.Location = [System.Drawing.Point]::new(10, 25)
        $lblPrompt.Width = 280

        $btnManager = [System.Windows.Forms.Button]::new()
        $btnManager.Text = "Manager"
        $btnManager.Location = [System.Drawing.Point]::new(50, 75)
        $btnManager.Size = [System.Drawing.Size]::new(75, 25)
        $btnManager.DialogResult = "OK"

        $btnUser = [System.Windows.Forms.Button]::new()
        $btnUser.Text = "User"
        $btnUser.Location = [System.Drawing.Point]::new(150, 75)
        $btnUser.Size = [System.Drawing.Size]::new(75, 25)
        $btnUser.DialogResult = "OK"

        $sendToForm.Controls.Add($lblPrompt)
        $sendToForm.Controls.Add($btnManager)
        $sendToForm.Controls.Add($btnUser)
        $userButton = $sendToForm.ShowDialog()
        $userChoice = ""

        if ($userButton -eq [System.Windows.Forms.DialogResult]::OK) {
            if ($sendToForm.ActiveControl -eq $btnManager) {
                $userChoice = "Manager"
            }
            elseif ($sendToForm.ActiveControl -eq $btnUser) {
                $userChoice = "User"
            }
            else {
                return
            }
        }

        . $PSScriptRoot\..\Passphrase.ps1
        Get-ADUser -Identity $textBoxes['Username'].Text | Reset-ADUserPassword -SendTo $userChoice
    })

$accountActions['EmailUser'].Add_Click({
        $email = $textBoxes['Mail'].Text
        try {
            $email = [mailaddress]$email
        }
        catch [System.ArgumentException], [System.Management.Automation.PSInvalidCastException] {
            # Try using a potential address in the info field
            $email = $textBoxes['Info'].Text
            try {
                $email = [mailaddress]$email
            }
            catch [System.ArgumentException], [System.Management.Automation.PSInvalidCastException] {
                $email = $null
            }
        }
        if ($null -eq $email) {
            [System.Windows.Forms.MessageBox]::Show("No valid email address found for this user.", "Email Address Not Found", "OK", "Error")
        }
        else {
            Start-Process "mailto:$($email.Address)"
        }
    })

$accountActions['CallUser'].Add_Click({
        $phone = [int]$textBoxes['IPPhone'].Text
        if ($phone -le 0 -or $phone -gt 9999999) {
            [System.Windows.Forms.MessageBox]::Show("Internal phone extension is either missing or not valid.", "Error", "OK", "Error")
        }
        else {
            $telURI = "tel:$phone"
            Start-Process $telURI
        }
    })

$setFieldValues = {
    $form.ActiveControl = $null
    $UserInfo = Get-ADUserInfo -SamAccountName $textUser.Text
    Write-Host ([bool]$UserInfo)
    if ($UserInfo) {
        foreach ($field in $fields) {
            $textBoxes[$field].Text = $UserInfo.$field
        }
    }
    else {
        foreach ($field in $fields) {
            $textBoxes[$field].Text = ""
        }
    }
}

# Search Button Click Event
$buttonSearch.Add_Click($setFieldValues)


# Pressing 'Enter' will perform search action
# $textUser.Add_KeyDown({
#     if ($_.KeyCode -eq [System.Windows.Forms.Keys]::Enter) {
#         $buttonSearch.PerformClick()
#         $_.SuppressKeyPress = $true
#     }
# })

#endregion
if ($InitialUsername) {
    $textUser.Text = $InitialUsername
    $setFieldValues.Invoke()
}

# Show Form
$form.ShowDialog()
