$dlls = @(
    '.\DymoSDK.dll'
)
add-type -path $dlls
[DymoSDK.App]::Init()
$label = [DymoSDK.Implementations.DymoLabel]::Instance
$label.LoadLabelFromFilePath("C:\Users\baile\OneDrive\Documents\ptrun.dymo")
$label.GetLabelObjects()
[System.IO.File]::WriteAllBytes("C:\Users\baile\OneDrive\Programming\PowerShell\DYMO\Preview.png", $label.GetPreviewLabel())