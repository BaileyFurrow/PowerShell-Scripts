
class SafeByte {
    [byte] $Value

    SafeByte([byte] $b) { $this.Value = $b }
    SafeByte([int]  $i) { $this.Value = [byte](($i) -band 0xFF) }  # wrap

    [string] ToString() { return $this.Value.ToString() }
}

class Brainfuck {
    [string] $SourceCode
    Brainfuck($FileName) {
        $this.SourceCode = Get-Content $FileName -Raw
    }
    Execute() {
        $cells = [SafeByte[]]::new(30000)
        $cellsIndex = 0
        $instructionIndex = 0
        try {
            while ($instructionIndex -lt $this.SourceCode.Length) {
                $instruction = $this.SourceCode[$instructionIndex]
                switch ($instruction) {
                    ">" { $cellsIndex += 1 }
                    "<" { $cellsIndex -= 1 }
                    "+" { $cells[$cellsIndex] = [SafeByte]($cells[$cellsIndex] + 1) }
                    "-" { $cells[$cellsIndex] = [SafeByte]($cells[$cellsIndex] - 1) }
                    "." { [System.Console]::Write([char]$cells[$cellsIndex])  }
                    "," { $cells[$cellsIndex] = [SafeByte]([System.Console]::Read()) }
                    "[" {
                        if ($cells[$cellsIndex] -eq 0) {
                            $instructionIndex = $this.FindBracketMatch($instructionIndex, $true)
                        }
                    }
                    "]" {
                        if ($cells[$cellsIndex] -ne 0) {
                            $instructionIndex = $this.FindBracketMatch($instructionIndex, $false)
                        }
                    }
                }
                $instructionIndex += 1
            }
        } catch {
            Write-Error "Interpreter is invalid.`nCell: $($cells[$cellsIndex])`nCell index: $cellsIndex`nInstruction index: $instructionIndex"
            # throw $_
        }
    }
    [int] FindBracketMatch($start, $forward) {
        $inBetweenBrackets = 0
        $direction = $forward ? 1 : -1
        $location = $start + $direction
        $startBracket = $forward ? "[" : "]"
        $endBracket = $forward ? "]" : "["
        while ($location -ge 0 -and $location -lt $this.SourceCode.Length) {
            if ($this.SourceCode[$location] -eq $endBracket) {
                if ($inBetweenBrackets -eq 0) {
                    return $location
                }
                $inBetweenBrackets -= 1
            } elseif ($this.SourceCode[$location] -eq $startBracket) {
                $inBetweenBrackets += 1
            }
            $location += $direction
        }
        Write-Error "Could not find match for $startBracket at $start."
        return $start
    }
}
