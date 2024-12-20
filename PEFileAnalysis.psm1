# https://yuriygeorgiev.com/2023/12/18/windows-portable-executable-pe-file-format/

function Get-PEHeaderOffset {
    param (
        [string[]]$Path
    )
    foreach ($File in $Path) {
        $FileObj = Get-Item $File
        $LEHex = (Format-Hex -Path $FileObj -Offset 0x3C -Count 4).Bytes
        [PSCustomObject]@{
            Path   = $FileObj
            Offset = [System.BitConverter]::ToInt32($LEHex,0)
        }
    }
}

function Get-PECodeSize {
    param (
        [string[]]$path
    )
    foreach ($File in $path) {
        $FileObj = Get-Item $File
        $PEHeaderOffset = (Get-PEHeaderOffset $File).Offset
        $CodeSizeOffset = $PEHeaderOffset + 28
        $Hex = (Format-Hex -Path $FileObj -Offset $CodeSizeOffset -Count 4).Bytes
        [PSCustomObject]@{
            Path = $FileObj
            CodeSize = [System.BitConverter]::ToInt32($Hex,0)
        }
    }
}

function Get-PEInitializedData {
    param (
        [string[]]$Path
    )
    foreach ($File in $Path) {
        $FileObj = Get-Item $File
        $PEHeaderOffset = (Get-PEHeaderOffset $File).Offset
        $InitializedDataOffset = $PEHeaderOffset + 32
        $Hex = (Format-Hex -Path $FileObj -Offset $InitializedDataOffset -Count 4).Bytes
        [PSCustomObject]@{
            Path = $FileObj
            InitializedDataSize = [System.BitConverter]::ToInt32($Hex,0)
        }
    }    
}

function Get-IsSFX {
    param (
        [string[]]$Path
    )
    foreach ($File in $Path) {
        $CodeSize = (Get-PECodeSize $File).CodeSize
        $InitializedDataSize = (Get-PEInitializedData $File).InitializedDataSize
        $isSFX = $false
        if ($CodeSize -lt $InitializedDataSize) {
            $isSFX = $true
        }
        [PSCustomObject]@{
            Path = $File
            IsSFX = $isSFX
            CodeSize = $CodeSize
            InitializedDataSize = $InitializedDataSize
        }
    }
}