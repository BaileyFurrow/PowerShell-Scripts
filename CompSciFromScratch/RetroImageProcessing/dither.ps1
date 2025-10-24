
$THRESHOLD = 127

class PatternPart {
    [int] $dc
    [int] $dr
    [int] $numerator
    [int] $denominator
    PatternPart([int]$deltaCol, [int]$deltaRow) {
        $this.dc = $deltaCol
        $this.dr = $deltaRow
        $this.numerator = 1
        $this.denominator = 8
    }
    PatternPart([int]$deltaCol, [int]$deltaRow, [int]$num, [int]$denom) {
        $this.dc = $deltaCol
        $this.dr = $deltaRow
        $this.numerator = $num
        $this.denominator = $denom
    }
}

$ATKINSON = @(
    [PatternPart]::new(1,0)
    [PatternPart]::new(2,0)
    [PatternPart]::new(-1,1)
    [PatternPart]::new(0,1)
    [PatternPart]::new(1,1)
    [PatternPart]::new(0,2)
)

function Dither {
    param (
        [Parameter(Position=1)]
        [System.Drawing.Bitmap]$Image
    )
    
    function Diffuse {
        param (
            [Parameter(Position=1)]
            [int]$c,
            [Parameter(Position=2)]
            [int]$r,
            [Parameter(Position=3)]
            [int]$errorInt,
            [Parameter(Position=1)]
            [PatternPart[]]$pattern
        )
        foreach ($part in $pattern) {
            $col = $c + $part.dc
            $row = $r + $part.dr
            if ($col -lt 0 -or $col -ge $image.Width -or $row -ge $image.Height) {
                continue
            }
            [float]$currentPixel = $image.GetPixel($col, $row).R
            $errorPart = [System.Math]::Floor(($errorInt * $part.numerator), $part.denominator)
            $newColor = $currentPixel + $errorPart
            $image.SetPixel($col, $row, [System.Drawing.Color]::FromArgb($newColor, $newColor, $newColor))
        }
    }
    $result = @([byte]0) * ($Image.Width * $Image.Height)
    for ($y = 0; $y -lt $Image.Height; $y++) {
        for ($x = 0; $x -lt $Image.Width; $x++) {
            $oldPixel = $Image.GetPixel($x, $y).R
            $newPixel = $oldPixel -gt $THRESHOLD ? 255 : 0
            result[$y * $Image.Width + $x] = $newPixel
            $difference = [int]($oldPixel - $newPixel)
            Diffuse($x, $y, $difference, $ATKINSON)
        }
    }
    return $result
}