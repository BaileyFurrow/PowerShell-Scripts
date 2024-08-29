# Custom GUI with pwsh
# Tutorial by Dan Stolts of ITProGuru

# Add .NET assembly object for Windows Forms
Add-Type -Assembly System.Windows.Forms

Write-Host "Create form" (Get-Date)

$form = New-Object System.Windows.Forms.Form
$form.FormBorderStyle = "FixedToolWindow"
$form.Text = "PowerShell Custom GUI Window"
$form.StartPosition = "CenterScreen"
$form.Width = 740 ; $form.Height = 380

# Add buttons
$buttonPanel = New-Object System.Windows.Forms.Panel
$buttonPanel.Size = New-Object Drawing.Size @(400,40)
$buttonPanel.Dock = "Bottom"

# Cancel button
$cancelButton = New-Object System.Windows.Forms.Button
$cancelButton.Top = $buttonPanel.Height - $cancelButton.Height - 10
$cancelButton.Left = $buttonPanel.Width - $cancelButton.Width - 10
$cancelButton.Text = "Cancel"
$cancelButton.DialogResult = "Cancel"
$cancelButton.Anchor = "Right"

# OK button
$okButton = New-Object System.Windows.Forms.Button
$okButton.Top = $cancelButton.Top
$okButton.Left = $cancelButton.Left - $okButton.Width - 10
$okButton.Text = "OK"
$okButton.DialogResult = "OK"
$okButton.Anchor = "Right"

# Add buttons to panel
$buttonPanel.Controls.Add($okButton)
$buttonPanel.Controls.Add($cancelButton)

# Add button panel to form
$form.Controls.Add($buttonPanel)

# Set default actions for buttons
$form.AcceptButton = $okButton        # ENTER = OK
$form.CancelButton = $cancelButton    # ESCAPE = Cancel

# Label and Textbox
# Computername
$lblHost = New-Object System.Windows.Forms.Label
$lblHost.Text = "Host Name:"
$lblHost.Top = 10
$lblHost.Left = 5
$lblHost.Width = 150
$lblHost.AutoSize = $true
# Add to form
$form.Controls.Add($lblHost)

# Textbox
$txtHost = New-Object System.Windows.Forms.TextBox
$txtHost.TabIndex = 0
$txtHost.Top = 10
$txtHost.Left = 160
$txtHost.Width = 120
$txtHost.Text = $env:COMPUTERNAME
# Add to form
$form.Controls.Add($txtHost)

# Finalize form and show dialog
Write-Host "Show form" (Get-Date)
$form.Activate()
$result = $form.ShowDialog()
Write-Host $result