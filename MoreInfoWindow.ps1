param (
    [string[]]$Items,
    [string]$Title = 'ADGroups'
)
Add-Type -AssemblyName System.Windows.Forms

# Create the Form
$form = New-Object System.Windows.Forms.Form
$form.Text = $Title
$form.Size = New-Object System.Drawing.Size(410, 300)
$form.StartPosition = "CenterScreen"
$form.MinimumSize = New-Object System.Drawing.Size(200, 200)
$form.MaximizeBox = $false
$form.FormBorderStyle = 'SizableToolWindow'

# Pressing `Esc` closes the form
$form.KeyPreview = $true
$form.Add_KeyUp({
        param($sender, $e)
        if ($e.KeyCode -eq [System.Windows.Forms.Keys]::Escape) {
            $sender.Close()
        }
    })

# Create the ListView
$listView = New-Object System.Windows.Forms.ListView
$listView.View = [System.Windows.Forms.View]::Details
$listView.FullRowSelect = $true
$listView.Columns.Add("Items", 385)
$listView.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right -bor [System.Windows.Forms.AnchorStyles]::Bottom
$listView.Height = 200
$listView.Width = 390

# Add provided items to ListView
$Items | ForEach-Object {
    $item = New-Object System.Windows.Forms.ListViewItem($_)
    $listView.Items.Add($item)
}

$listView.AutoResizeColumns([System.Windows.Forms.ColumnHeaderAutoResizeStyle]::ColumnContent)

# Create Panel for Buttons
$buttonFlow = New-Object System.Windows.Forms.FlowLayoutPanel
$buttonFlow.Dock = [System.Windows.Forms.DockStyle]::Bottom
$buttonFlow.FlowDirection = [System.Windows.Forms.FlowDirection]::RightToLeft
$buttonFlow.Height = 40
$form.Controls.Add($buttonFlow)

# Uniform button size
$buttonSize = New-Object System.Drawing.Size(75, 25)

# Create the Close Button
# $closeButton = New-Object System.Windows.Forms.Button
# $closeButton.Text = "Close"
# $closeButton.Size = $buttonSize
# $closeButton.Add_Click({ $form.Close() })
# $buttonFlow.Controls.Add($closeButton)
# $form.CancelButton = $closeButton

# Create the Copy Button
$copyButton = New-Object System.Windows.Forms.Button
$copyButton.Text = "Copy"
$copyButton.Size = $buttonSize
$copyButton.Add_Click({
        if ($listView.SelectedItems.Count -gt 0) {
            [System.Windows.Forms.Clipboard]::SetText($listView.SelectedItems[0].Text)
        }
    })
$buttonFlow.Controls.Add($copyButton)

# Add controls to form
$form.Controls.Add($listView)

# Show the Form
$form.ShowDialog()