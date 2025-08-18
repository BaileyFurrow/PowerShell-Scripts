Add-Type -AssemblyName PresentationFramework
function Import-Xaml {
	[xml]$xaml = Get-Content -Path $PSScriptRoot\test.xaml
	$manager = New-Object System.Xml.XmlNamespaceManager -ArgumentList $xaml.NameTable
	Write-Host $xaml.NameTable.ToString()
	# $manager.AddNamespace("x", "http://schemas.microsoft.com/winfx/2006/xaml");
	$xamlReader = New-Object System.Xml.XmlNodeReader $xaml
	[Windows.Markup.XamlReader]::Load($xamlReader)
}

$Window = Import-Xaml
$Window.ShowDialog()