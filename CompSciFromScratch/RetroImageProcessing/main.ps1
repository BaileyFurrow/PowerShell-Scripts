[CmdletBinding()]
param (
    [Parameter()]
    [string] $ImageFile,

    [Parameter()]
    [string] $OutputFile,

    [Parameter()]
    [switch] $GIF
)

. .\dither.ps1

$MAXWIDTH = 576
$MAXHEIGHT = 720

function ConvertTo-Grayscale {
    param (
        [System.Drawing.Bitmap]$OldImage
    )
    $newImage = [System.Drawing.Bitmap]::new($OldImage.Width, $OldImage.Height)
    $g = [System.Drawing.Graphics]::FromImage($newImage)
    $colorMatrix = [System.Drawing.Imaging.ColorMatrix]::new(
        [float[][]]@(
            [float[]]@(.3, .3, .3, 0, 0)
            [float[]]@(.59, .59, .59, 0, 0)
            [float[]]@(.11, .11, .11, 0, 0)
            [float[]]@(0, 0, 0, 1, 0)
            [float[]]@(0, 0, 0, 0, 1)
        )
    )
    $imgAttr = [System.Drawing.Imaging.ImageAttributes]::new()
    $imgAttr.SetColorMatrix($colorMatrix)
    $g.DrawImage(
        $OldImage,
        [System.Drawing.Rectangle]::new(0, 0, $OldImage.Width, $OldImage.Height),
        0,
        0,
        $OldImage.Width,
        $OldImage.Height,
        [System.Drawing.GraphicsUnit]::Pixel,
        $imgAttr
    )
    $g.Dispose()
    return $newImage
}

function Prepare {
    param (
        [Parameter(Position=1)]
        [string]$FileName
    )
    $fullFile = Get-Item $FileName
    $image = [System.Drawing.Bitmap]::FromFile($fullFile.FullName)
    if ($image.Width -gt $MAXWIDTH -or $image.Height -gt $MAXHEIGHT) {
        $desiredRatio = $MAXWIDTH / $MAXHEIGHT
        $ratio = $image.Width / $image.Height
        if ($ratio -ge $desiredRatio) {
            $newSize = @($MAXWIDTH, [int]($image.Height * ($MAXWIDTH / $image.Width)))
        } else {
            $newSize = @([int]($image.Width * ($MAXHEIGHT / $image.Height)), $MAXHEIGHT)
        }
        $thumbnail = $image.GetThumbnailImage($newSize[0], $newSize[1], [System.Drawing.Image+GetThumbnailImageAbort]::new({return $false}, [System.IntPtr]::Zero), [System.IntPtr]::Zero)
    }
    return ConvertTo-Grayscale -OldImage $thumbnail
}

$original = Prepare $ImageFile
$ditheredData = Dither($original)
if ($GIF) {
    $ditheredData.Save("$ImageFile.gif", [System.Drawing.Imaging.ImageFormat]::Gif)
}
# Write-MacPaintFile -ArgsHere