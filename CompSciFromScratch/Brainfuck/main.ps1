# using module ./brainfuck.psm1

[CmdletBinding()]
param (
    [Parameter(Position=1)]
    [string]$BrainFuckFile = './test.bf'
)

class SafeByte {
    [byte] $Value

    SafeByte() { $this.Value = 0 }
    SafeByte([byte] $b) { $this.Value = $b }
    SafeByte([int]  $i) { $this.Value = [byte](($i) -band 0xFF) }  # wrap

    static [SafeByte] op_Addition([SafeByte]$a, [SafeByte]$b) { return $a.Value + $b.Value }
    static [SafeByte] op_Subtraction([SafeByte]$a, [SafeByte]$b) { return $a.Value - $b.Value }
    # [bool] Equals([SafeByte]$other) {
    #     if ($null -eq $other) { return $false }
    #     return $this.Value -eq $other.Value
    # }
    [bool] Equals([object]$obj) {
        if ($null -eq $obj) { return $false }
        if ($obj -is [SafeByte]) { return $this.Value -eq ([SafeByte]$obj).Value }
        if ($obj -is [byte]) { return $this.Value -eq [byte]$obj }
        if ($obj -is [int]) { return $this.Value -eq [byte](([int]$obj) -band 0xFF) }
        return $false
    }
    [string] ToString() { return $this.Value.ToString() }
}

class Brainfuck {
    [string] $SourceCode
    Brainfuck($FileName) {
        $this.SourceCode = Get-Content $FileName -Raw
    }
    Execute() {
        $cells = @([SafeByte]0) * 30000
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
                    "." { [System.Console]::Write([char]$cells[$cellsIndex].Value)  }
                    "," { $cells[$cellsIndex] = [SafeByte]([System.Console]::Read()) }
                    "[" {
                        if ($cells[$cellsIndex] -eq [SafeByte]0) {
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
                # Write-Host $instructionIndex
            }
        } catch {
            Write-Error "Interpreter is invalid.`nCell: $($cells[$cellsIndex])`nCell index: $cellsIndex`nInstruction index: $instructionIndex"
            throw $_
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
        throw "Could not find match for $startBracket at $start."
    }
}

[Brainfuck]::new($BrainFuckFile).Execute()