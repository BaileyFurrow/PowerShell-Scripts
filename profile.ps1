# Sets defaults for profile and runs first time use
# Add `$FirstTimeSetup = $true` to script to run first-time setup. Variable will be automatically removed after running.
$FirstTimeSetup = $true

# Sets output of last command as $__ variable.
$PSDefaultParameterValues['Out-Default:OutVariable'] = '__'

# Replaces aliases with resolved commands prior to execution
if (Get-Module -Name PSReadLine) {
    Set-PSReadLineKeyHandler -Key Enter -ScriptBlock {
        param($key, $arg)
        $origBuffer = $null
        $origCursor = 0
        [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$origBuffer, [ref]$origCursor)
        $tokens = $null
        $errors = $null
        [void][System.Management.Automation.Language.Parser]::ParseInput(
            $origBuffer,
            [ref]$tokens,
            [ref]$errors
        )

        # Collect replacements (do NOT edit the string yet)
        $replacements = foreach ($t in $tokens) {
            if (($t.TokenFlags -band [System.Management.Automation.Language.TokenFlags]::CommandName) -ne 0) {
                $cmd = Get-Command -Name $t.Text -ErrorAction SilentlyContinue
                if ($cmd -and $cmd.CommandType -eq 'Alias') {
                    [pscustomobject]@{
                        Start   = $t.Extent.StartOffset
                        Length  = $t.Extent.Text.Length
                        NewText = $cmd.ResolvedCommandName
                    }
                }
            }
        }

        if (-not $replacements) {
            [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
            return
        }

        # Apply replacements right-to-left to keep offsets valid
        $newBuffer = $origBuffer
        $newCursor = $origCursor

        foreach ($r in ($replacements | Sort-Object Start -Descending)) {
            $newBuffer = $newBuffer.Remove($r.Start, $r.Length).Insert($r.Start, $r.NewText)

            # Adjust cursor if the edit occurred before it
            if ($r.Start -lt $newCursor) {
                $delta = $r.NewText.Length - $r.Length
                $newCursor = [Math]::Max(0, $newCursor + $delta)
            }
        }

        # IMPORTANT: length is the *current* PSReadLine buffer length (i.e., original length)
        [Microsoft.PowerShell.PSConsoleReadLine]::Replace(0, $origBuffer.Length, $newBuffer)
        [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($newCursor)
        [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
    }
}

if ($FirstTimeSetup) {
    
    #region Setup Windows Terminal
    $wtSettingsPath = "$HOME\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
    if (-not (Test-Path $wtSettingsPath)) {
        Write-Warning 'Windows Terminal settings path not found. Unable to set options.'
        continue
    }
    $wtSettings = Get-Content $wtSettingsPath | ConvertFrom-Json
    # Add keybind to surround line with parentheses. Uses ANSI codes to accomplish
    $wtSettings.actions += '{"command": {"action": "sendInput", "input": "\u001b[H(\u001b[F)"}, "id": "User.sendInput.addParens"}' | ConvertFrom-Json
    $wtSettings.keybindings += [pscustomobject]@{
        id   = "User.sendInput.addParens"
        keys = "ctrl+0"
    }
    # Copy formatting
    $wtSettings.copyFormatting = "all"
    Set-Content -Path $wtSettingsPath -Value ($wtSettings | ConvertTo-Json -Depth 3)
    #endregion

    #region Remove $FirstTimeSetup
    $ast = [System.Management.Automation.Language.Parser]::ParseFile($MyInvocation.MyCommand.Path, [ref]$null, [ref]$null)
    $firstTimeAst = $ast.Find({ $args[0] -is [System.Management.Automation.Language.AssignmentStatementAst] -and $args[0].Left.VariablePath.UserPath -ieq 'FirstTimeSetup' }, $false)
    $scriptContents = Get-Content $MyInvocation.MyCommand.Path -Raw
    $before = $scriptContents.Substring(0, $firstTimeAst.Extent.StartOffset)
    $after = $scriptContents.Substring($firstTimeAst.Extent.EndOffset)
    $newScriptContents = $before + $after
    Set-Content -Path $MyInvocation.MyCommand.Path -Value $newScriptContents
    #endregion
}
