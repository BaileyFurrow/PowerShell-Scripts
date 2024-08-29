# Following tutorial at https://blog.ironmansoftware.com/tui-powershell/
using namespace Terminal.Gui
Import-Module Microsoft.PowerShell.ConsoleGuiTools
$module = (Get-Module Microsoft.PowerShell.ConsoleGuiTools -List).ModuleBase
Add-Type -Path (Join-Path $module Terminal.Gui.dll)

# Init top level application
[Application]::Init()

# Create a window
$Window = [Window]::new()
$Window.Title = "Hello, World! (Press $([Application]::QuitKey) to quit)"
[Application]::Top.Add($Window)
[Application]::Run()

# Controls
# Button
$Button = [Button]::new()
$Button.Text = "Button"
$Window.Add($Button)