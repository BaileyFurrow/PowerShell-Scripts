
Add-Type -AssemblyName System.Windows.Forms

$main = New-Object System.Windows.Forms.Form
$main.Text = 'GUI Test'
$main.Width = 600
$main.Height = 400
$main.AutoSize = $true


$main.ShowDialog()