
[CmdletBinding(DefaultParameterSetName='Path')]
[OutputType([System.Object])]
param (
    # Path to XML file
    [Parameter(Mandatory, Position=1, ParameterSetName='Path', ValueFromPipelineByPropertyName)]
    [System.IO.FileInfo] $Path,

    # Contents of XML file
    [Parameter(Mandatory, Position=1, ParameterSetName='Contents', ValueFromPipeline)]
    [xml] $XML
)

Add-Type -AssemblyName PresentationFramework
if ($Path) {
    $XML = Get-Content -Path $Path
}
$nsManager = [System.Xml.XmlNamespaceManager]::new($XML.NameTable)
$nsManager.AddNamespace('x', 'https://schemas.microsoft.com/winfx/2006/xaml')
$xmlReader = [System.Xml.XmlNodeReader]::new($XML)
[System.Windows.Markup.XamlReader]::Load($xmlReader)