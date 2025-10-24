# PSClipboardHistory.ps1
# Clipboard History for PowerShell (text-only, cross-platform)
# Style: native PowerShell, concise, no external modules.


# $script:IsWindows = $PSVersionTable.Platform -match 'Win32NT' -or $IsWindows

if ($IsWindows) {
    Add-Type -AssemblyName PresentationCore, PresentationFramework | Out-Null
}

#region Config & State
$script:Cfg = [ordered]@{
    MaxItems        = 200
    PollMilliseconds= 300
    StorePath       = Join-Path ([Environment]::GetFolderPath('ApplicationData')) 'PSClipboardHistory\history.json'
    CaptureWhitespaceNormalize = $false  # if $true, trims and collapses spaces for de-dupe key only
}
$script:State = [ordered]@{
    Items = @()            # list of [pscustomobject]
    Timer = $null          # [System.Timers.Timer]
    LastHash = $null
    Running = $false
}
#endregion

function Initialize-ClipboardStore {
    $dir = Split-Path $script:Cfg.StorePath -Parent
    if (-not (Test-Path $dir)) { $null = New-Item -ItemType Directory -Path $dir -Force }
    if (Test-Path $script:Cfg.StorePath) {
        try {
            $json = Get-Content -Path $script:Cfg.StorePath -Raw -ErrorAction Stop
            $data = if ($json) { $json | ConvertFrom-Json -ErrorAction Stop } else { @() }
            $script:State.Items = @($data | ForEach-Object {
                # Back-compat normalization
                [pscustomobject]@{
                    Id        = $_.Id
                    Text      = $_.Text
                    Pinned    = [bool]$_.Pinned
                    Created   = Get-Date $_.Created
                    LastUsed  = if ($_.LastUsed) { Get-Date $_.LastUsed } else { $null }
                    UseCount  = [int]($_.UseCount ?? 0)
                    Length    = ($_.Text ?? '').Length
                }
            })
        } catch { $script:State.Items = @() }
    } else {
        $script:State.Items = @()
        Save-ClipboardStore
    }
}

function Save-ClipboardStore {
    $script:State.Items |
        ConvertTo-Json -Depth 5 |
        Set-Content -Path $script:Cfg.StorePath -Encoding UTF8
}

# function Get-ClipboardText {
#     try {
#         # Native Get-Clipboard works on all PS7 platforms (may require xclip/pbpaste on Linux/macOS)
#         $t = Get-Clipboard -Raw -ErrorAction Stop
#         if ($null -eq $t) { return $null }
#         [string]$t
#     } catch { $null }
# }

function Get-DeDupeKey([string]$Text) {
    if ($script:Cfg.CaptureWhitespaceNormalize) {
        ($Text -replace '\s+', ' ').Trim()
    } else {
        $Text
    }
}

# function Add-ClipboardItem([string]$Text) {
#     if ([string]::IsNullOrEmpty($Text)) { return }

#     $key = Get-DeDupeKey $Text
#     $existing = $script:State.Items | Where-Object { (Get-DeDupeKey $_.Text) -eq $key } | Select-Object -First 1
#     if ($existing) {
#         # bump existing to top, keep pin state
#         $existing.LastUsed = Get-Date
#         $existing.UseCount++
#         # move to top, preserve relative order of pins
#         $others = $script:State.Items | Where-Object { $_.Id -ne $existing.Id }
#         $script:State.Items = @($existing) + $others
#     } else {
#         $item = [pscustomobject]@{
#             Id       = ([guid]::NewGuid()).Guid
#             Text     = $Text
#             Pinned   = $false
#             Created  = Get-Date
#             LastUsed = $null
#             UseCount = 0
#             Length   = $Text.Length
#         }
#         # insert after current pins (pins stay at very top)
#         $pins, $rest = $script:State.Items | Group-Object { $_.Pinned } | ForEach-Object {
#             if ($_.Name -eq 'True') { ,$_.Group } else { ,$_.Group }
#         }
#         if ($pins) {
#             $script:State.Items = @($pins + @($item) + $rest)
#         } else {
#             $script:State.Items = @($item) + $script:State.Items
#         }
#         # enforce MaxItems keeping pins
#         $pins = $script:State.Items | Where-Object Pinned
#         $nonPins = $script:State.Items | Where-Object { -not $_.Pinned }
#         $keep = $script:Cfg.MaxItems - ($pins.Count)
#         if ($keep -lt 0) { $keep = 0 }
#         $script:State.Items = @($pins + $nonPins | Select-Object -First $keep)
#     }
#     Save-ClipboardStore
# }

# function Start-ClipboardHistory {
# <#
# .SYNOPSIS
#   Start background clipboard watcher (text only).
# #>
#     if ($script:State.Running) { return }
#     Initialize-ClipboardStore
#     # $script:State.LastHash = $null

#     $timer = [System.Timers.Timer]::new($script:Cfg.PollMilliseconds)
#     $timer.AutoReset = $true
#     # Store LastHash on timer as property to access during event.
#     $timer | Add-Member -NotePropertyName LastHash -NotePropertyValue $null -Force
#     $null = Register-ObjectEvent -InputObject $timer -EventName Elapsed -SourceIdentifier 'PSCH.Timer' -Action {
#         try {
#             $snap = Get-ClipboardSnapshot
#             if ($null -eq $snap) { return }
#             # Hash to avoid re-adding identical consecutive copies
#             $hash = Get-ClipboardHash -Snapshot $snap
#             if ($hash -ne $event.Sender.LastHash) {
#                 $event.Sender.LastHash = $hash
#                 Add-ClipboardItem
#             }
#         } catch {
#             write-host $_.InvocationInfo.PositionMessage -ForegroundColor Red
#             write-host $_ -ForegroundColor Red
#         }
#     }
#     $timer.Start()
#     $script:State.Timer = $timer
#     $script:State.Running = $true
#     Write-Verbose "Clipboard history started (poll: $($script:Cfg.PollMilliseconds) ms)."
# }

# state handles
$script:PollThread     = $null
$script:PollDispatcher = $null

function Start-ClipboardHistory {
    if ($script:State.Running) { return }
    Initialize-ClipboardStore

    # capture config for the delegate
    $intervalMs = [int]$script:Cfg.PollMilliseconds
    $ready      = [System.Threading.AutoResetEvent]::new($false)

    # build the thread with a proper delegate (ThreadStart)
    $threadStart = [System.Threading.ThreadStart]{
        try {
            [void][Reflection.Assembly]::Load("WindowsBase")
            [void][Reflection.Assembly]::Load("PresentationCore")
            [void][Reflection.Assembly]::Load("PresentationFramework")

            $timer   = New-Object System.Windows.Threading.DispatcherTimer
            $timer.Interval = [TimeSpan]::FromMilliseconds($intervalMs)
            $lastHash = $null

            $timer.Add_Tick({
                try {
                    $snap = Get-ClipboardSnapshot
                    if ($null -eq $snap) { return }
                    $hash = Get-ClipboardHash $snap
                    if ($hash -ne $lastHash) {
                        $lastHash = $hash
                        Add-ClipboardItem   # multi-format add/de-dupe
                    }
                } catch { }
            })

            $timer.Start()
            $Global:__PSCH_PollDispatcher = [System.Windows.Threading.Dispatcher]::CurrentDispatcher
            $ready.Set() | Out-Null
            [System.Windows.Threading.Dispatcher]::Run()
        } catch {
            $ready.Set() | Out-Null
        }
    }

    $script:PollThread = [System.Threading.Thread]::new($threadStart)
    $script:PollThread.IsBackground = $true
    $script:PollThread.SetApartmentState([Threading.ApartmentState]::STA)
    $script:PollThread.Start()
    $ready.WaitOne() | Out-Null

    $script:PollDispatcher = $Global:__PSCH_PollDispatcher
    $script:State.Running  = $true
}

# function Stop-ClipboardHistory {
# <#
# .SYNOPSIS
#   Stop clipboard watcher.
# #>
#     if (-not $script:State.Running) { return }
#     try {
#         $script:State.Timer.Stop()
#         $script:State.Timer.Dispose()
#     } catch { }
#     Get-EventSubscriber -SourceIdentifier 'PSCH.Timer' -ErrorAction SilentlyContinue | Unregister-Event | Out-Null
#     $script:State.Timer = $null
#     $script:State.Running = $false
# }

function Stop-ClipboardHistory {
    if (-not $script:State.Running) { return }
    try {
        if ($script:PollDispatcher) { $script:PollDispatcher.InvokeShutdown() }
        if ($script:PollThread)     { $script:PollThread.Join(500) | Out-Null }
    } catch { }
    $script:PollDispatcher = $null
    $script:PollThread     = $null
    $script:State.Running  = $false
}

# function Get-ClipboardHistory {
# <#
# .SYNOPSIS
#   Get clipboard history items.
# .PARAMETER Filter
#   Simple -like filter over Text.
# .PARAMETER Top
#   Limit results.
# .PARAMETER IncludeText
#   Include full Text (default shows a preview).
# #>
#     param(
#         [string]$Filter,
#         [int]$Top = [int]::MaxValue,
#         [switch]$IncludeText
#     )
#     Initialize-ClipboardStore
#     $items = $script:State.Items
#     if ($Filter) { $items = $items | Where-Object { $_.Text -like "*$Filter*" } }
#     $items = $items | Select-Object Id, Pinned, Created, LastUsed, UseCount, Length,
#         @{n='Preview';e={ ($_.Text -replace '\s+', ' ').Trim() | ForEach-Object { $_.Substring(0, [Math]::Min(80, $_.Length)) } }}
#     if ($IncludeText) {
#         $items = $items | Select-Object *, @{n='Text';e={ ($script:State.Items | Where-Object Id -EQ $_.Id).Text }}
#     }
#     $items | Select-Object -First $Top
# }

# function Set-ClipboardHistoryItem {
# <#
# .SYNOPSIS
#   Restore an item to clipboard by Id.
# #>
#     param(
#         [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
#         [string]$Id
#     )
#     process {
#         $item = $script:State.Items | Where-Object Id -EQ $Id | Select-Object -First 1
#         if (-not $item) { throw "No item with Id '$Id'." }
#         Set-Clipboard -Value $item.Text
#         $item.LastUsed = Get-Date
#         $item.UseCount++
#         Save-ClipboardStore
#         $item
#     }
# }

function Invoke-ClipboardPicker {
<#
.SYNOPSIS
  Interactive picker in console, fuzzy filter with /text.
.DESCRIPTION
  Type to filter, Enter to choose; Esc to cancel.
#>
    param(
        [string]$Filter
    )
    Initialize-ClipboardStore
    $items = if ($Filter) { $script:State.Items | Where-Object { $_.Text -like "*$Filter*" } } else { $script:State.Items }
    if (-not $items) { Write-Host "No items."; return }
    # Render a numbered list (preview lines)
    $width = [Console]::WindowWidth
    $i = 0
    $display = foreach ($it in $items) {
        $i++
        $pin = if ($it.Pinned) {'📌 '} else {''}
        $preview = ($it.Text -replace '\s+', ' ').Trim()
        if ($preview.Length -gt ($width-10)) { $preview = $preview.Substring(0, [Math]::Max(0,$width-13)) + '...' }
        '{0,3}. {1}{2}' -f $i, $pin, $preview
    }
    $display | ForEach-Object { Write-Host $_ }
    $sel = Read-Host 'Pick number (Enter=1, Esc cancels)'
    if ($sel -eq '') { $sel = 1 }
    if ($sel -as [int] -lt 1 -or $sel -as [int] -gt $items.Count) { Write-Warning "Invalid selection."; return }
    $chosen = $items[$sel-1]
    Set-Clipboard -Value $chosen.Text
    $chosen.LastUsed = Get-Date
    $chosen.UseCount++
    Save-ClipboardStore
    $chosen
}

function Set-ClipboardHistoryPin {
<#
.SYNOPSIS
  Pin or unpin an item by Id.
#>
    param(
        [Parameter(Mandatory)][string]$Id,
        [switch]$Unpin
    )
    $item = $script:State.Items | Where-Object Id -EQ $Id | Select-Object -First 1
    if (-not $item) { throw "No item with Id '$Id'." }
    $item.Pinned = -not $Unpin
    # keep pins at top
    $pins = $script:State.Items | Where-Object Pinned
    $nonPins = $script:State.Items | Where-Object { -not $_.Pinned }
    $script:State.Items = @($pins + $nonPins)
    Save-ClipboardStore
    $item
}

function Remove-ClipboardHistoryItem {
<#
.SYNOPSIS
  Remove item(s) by Id.
#>
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string[]]$Id
    )
    process {
        foreach ($i in $Id) {
            $script:State.Items = $script:State.Items | Where-Object { $_.Id -ne $i }
        }
    }
    end { Save-ClipboardStore }
}

function Clear-ClipboardHistory {
<#
.SYNOPSIS
  Clear non-pinned items (use -All to nuke everything).
#>
    param([switch]$All)
    if ($All) {
        $script:State.Items = @()
    } else {
        $script:State.Items = $script:State.Items | Where-Object Pinned
    }
    Save-ClipboardStore
}

function Export-ClipboardHistory {
<#
.SYNOPSIS
  Export to JSON file.
#>
    param([Parameter(Mandatory)][string]$Path)
    $script:State.Items | ConvertTo-Json -Depth 5 | Set-Content -Path $Path -Encoding UTF8
}

function Import-ClipboardHistory {
<#
.SYNOPSIS
  Import from JSON file (appends; de-dupes).
#>
    param([Parameter(Mandatory)][string]$Path)
    $data = Get-Content -Path $Path -Raw | ConvertFrom-Json
    foreach ($i in $data) { Add-ClipboardItem -Text $i.Text }
}

function Get-ClipboardSnapshot {
<#
.SYNOPSIS
  Capture a multi-format snapshot of the clipboard (Windows: Text/Html/Rtf/Image/FileDropList).
#>
    if (-not $script:IsWindows) {
        # Cross-platform fallback: text only
        $t = Get-Clipboard -Raw -ErrorAction SilentlyContinue
        if ($null -eq $t) { return $null }
        return [pscustomobject]@{
            Formats  = @('Text')
            Payloads = @{ Text = [string]$t }
            Meta     = @{}
        }
    }

    # Windows: use WPF Clipboard/DataObject
    $data = [System.Windows.Clipboard]::GetDataObject()
    if (-not $data) { return $null }

    $formats = @()
    $payloads = @{}
    $meta = @{}

    # Text (plain)
    if ($data.GetDataPresent([System.Windows.DataFormats]::UnicodeText)) {
        $txt = [string]$data.GetData([System.Windows.DataFormats]::UnicodeText)
        if ($null -ne $txt) {
            $formats += 'Text'
            $payloads['Text'] = $txt
            $meta['Length'] = $txt.Length
        }
    }

    # HTML
    if ($data.GetDataPresent([System.Windows.DataFormats]::Html)) {
        $html = [string]$data.GetData([System.Windows.DataFormats]::Html)
        if ($html) {
            $formats += 'Html'
            $payloads['Html'] = $html
        }
    }

    # RTF
    if ($data.GetDataPresent([System.Windows.DataFormats]::Rtf)) {
        $rtf = [string]$data.GetData([System.Windows.DataFormats]::Rtf)
        if ($rtf) {
            $formats += 'Rtf'
            $payloads['Rtf'] = $rtf
        }
    }

    # File list
    if ($data.GetDataPresent([System.Windows.DataFormats]::FileDrop)) {
        $files = $data.GetData([System.Windows.DataFormats]::FileDrop)
        if ($files -and $files.Count -gt 0) {
            $formats += 'FileDropList'
            $payloads['FileDropList'] = @($files)
            $meta['FileCount'] = $files.Count
        }
    }

    # Image → encode to PNG bytes
    if ($data.GetDataPresent([System.Windows.DataFormats]::Bitmap)) {
        $bmp = $data.GetData([System.Windows.DataFormats]::Bitmap)
        if ($bmp -is [System.Windows.Media.Imaging.BitmapSource]) {
            $img = [System.Windows.Media.Imaging.BitmapSource]$bmp
            $enc = [System.Windows.Media.Imaging.PngBitmapEncoder]::new()
            $enc.Frames.Add([System.Windows.Media.Imaging.BitmapFrame]::Create($img))
            $ms = New-Object System.IO.MemoryStream
            $enc.Save($ms)
            $bytes = $ms.ToArray()
            $ms.Dispose()

            $formats += 'Image'
            $payloads['Image'] = [Convert]::ToBase64String($bytes)
            $meta['Image'] = [ordered]@{ Width = $img.PixelWidth; Height = $img.PixelHeight }
        }
    }

    if (-not $formats) { return $null }

    [pscustomobject]@{
        Formats  = $formats
        Payloads = $payloads
        Meta     = $meta
    }
}

function Set-ClipboardSnapshot {
<#
.SYNOPSIS
  Restore a multi-format snapshot to the clipboard (Windows uses DataObject).
#>
    param(
        [Parameter(Mandatory)][pscustomobject]$Snapshot
    )

    if (-not $script:IsWindows) {
        if ($Snapshot.Payloads.ContainsKey('Text')) {
            Set-Clipboard -Value $Snapshot.Payloads['Text']
            return
        }
        throw "Non-Windows restore supports text only."
    }

    $obj = New-Object System.Windows.DataObject

    foreach ($fmt in $Snapshot.Formats) {
        switch ($fmt) {
            'Text' {
                $obj.SetData([System.Windows.DataFormats]::UnicodeText, $Snapshot.Payloads['Text'])
            }
            'Html' {
                # Store CF_HTML string as-is (includes header + fragment indices)
                $obj.SetData([System.Windows.DataFormats]::Html, $Snapshot.Payloads['Html'])
            }
            'Rtf' {
                $obj.SetData([System.Windows.DataFormats]::Rtf, $Snapshot.Payloads['Rtf'])
            }
            'FileDropList' {
                $coll = New-Object System.Collections.Specialized.StringCollection
                $Snapshot.Payloads['FileDropList'] | ForEach-Object { $null = $coll.Add($_) }
                $obj.SetFileDropList($coll)
            }
            'Image' {
                $bytes = [Convert]::FromBase64String($Snapshot.Payloads['Image'])
                $ms = New-Object System.IO.MemoryStream(,$bytes)
                $decoder = [System.Windows.Media.Imaging.PngBitmapDecoder]::new($ms,[System.Windows.Media.Imaging.BitmapCreateOptions]::PreservePixelFormat,[System.Windows.Media.Imaging.BitmapCacheOption]::OnLoad)
                $bmp = $decoder.Frames[0]
                $ms.Dispose()
                $obj.SetData([System.Windows.DataFormats]::Bitmap, $bmp)
            }
        }
    }

    [System.Windows.Clipboard]::SetDataObject($obj, $true)
}

# --- Replace Get-ClipboardText and hashing with multi-format versions ---

function Get-ClipboardHash([pscustomobject]$Snapshot) {
    # Stable hash over the formats + payloads
    $sb = [System.Text.StringBuilder]::new()
    foreach ($f in $Snapshot.Formats) {
        $null = $sb.Append($f).Append('|')
        switch ($f) {
            'Image'       { $null = $sb.Append($Snapshot.Payloads['Image'].Substring(0, [Math]::Min(2048, $Snapshot.Payloads['Image'].Length))) }
            'FileDropList'{ $null = $sb.Append(($Snapshot.Payloads['FileDropList'] -join ';')) }
            default       { $null = $sb.Append(($Snapshot.Payloads[$f] -as [string])) }
        }
        $null = $sb.Append('||')
    }
    $bytes = [Text.Encoding]::UTF8.GetBytes($sb.ToString())
    $sha1  = [System.Security.Cryptography.SHA1]::Create()
    ([System.BitConverter]::ToString($sha1.ComputeHash($bytes))) -replace '-'
}

function Add-ClipboardItem {
    $snap = Get-ClipboardSnapshot
    if ($null -eq $snap) { return }

    $hash = Get-ClipboardHash $snap
    $existing = $null

    # de-dupe by hash
    if ($script:State.Items.Count -gt 0) {
        $existing = $script:State.Items | Where-Object { $_.Hash -eq $hash } | Select-Object -First 1
    }
    if ($existing) {
        $existing.LastUsed = Get-Date
        $existing.UseCount++
        $others = $script:State.Items | Where-Object { $_.Id -ne $existing.Id }
        $script:State.Items = @($existing) + $others
    } else {
        $item = [pscustomobject]@{
            Id       = ([guid]::NewGuid()).Guid
            Hash     = $hash
            Formats  = $snap.Formats
            Payloads = $snap.Payloads
            Meta     = $snap.Meta
            Pinned   = $false
            Created  = Get-Date
            LastUsed = $null
            UseCount = 0
            # Legacy compatibility fields
            Text     = if ($snap.Payloads.ContainsKey('Text')) { $snap.Payloads['Text'] } else { '' }
            Length   = if ($snap.Payloads.ContainsKey('Text')) { ($snap.Payloads['Text']).Length } else { 0 }
        }

        # insert after pins
        $pins = $script:State.Items | Where-Object Pinned
        $rest = $script:State.Items | Where-Object { -not $_.Pinned }
        if ($pins) { $script:State.Items = @($pins + @($item) + $rest) } else { $script:State.Items = @($item) + $script:State.Items }

        # trim to MaxItems (keep pins)
        $pins = $script:State.Items | Where-Object Pinned
        $pinsCount = 0
        if ($pins) {
            $pinsCount = $pins.Count
        }
        $nonPins = $script:State.Items | Where-Object { -not $_.Pinned }
        $keep = [Math]::Max(0, $script:Cfg.MaxItems - $pinsCount)
        $script:State.Items = @($pins + ($nonPins | Select-Object -First $keep))
    }
    Save-ClipboardStore
}

function Set-ClipboardHistoryItem {
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$Id
    )
    process {
        $item = $script:State.Items | Where-Object Id -EQ $Id | Select-Object -First 1
        if (-not $item) { throw "No item with Id '$Id'." }
        Set-ClipboardSnapshot -Snapshot $item
        $item.LastUsed = Get-Date
        $item.UseCount++
        Save-ClipboardStore
        $item
    }
}

function Get-ClipboardHistory {
    param(
        [string]$Filter,
        [int]$Top = [int]::MaxValue,
        [switch]$IncludeText
    )
    Initialize-ClipboardStore
    $items = $script:State.Items
    if ($Filter) {
        $items = $items | Where-Object {
            $_.Formats -contains 'Text' -and $_.Text -like "*$Filter*"
        }
    }

    $items = $items | Select-Object Id, Pinned, Created, LastUsed, UseCount,
        @{n='Formats';e={ $_.Formats -join '+' }},
        @{n='Preview';e={
            if ($_.Formats -contains 'Image') {
                $dim = $_.Meta.Image
                "[IMG $($dim.Width)x$($dim.Height)]"
            } elseif ($_.Formats -contains 'FileDropList') {
                "[Files $($_.Meta.FileCount)] " + (($_.Payloads.FileDropList | Select-Object -First 1) ?? '')
            } elseif ($_.Formats -contains 'Html' -or $_.Formats -contains 'Rtf') {
                $t = ($_.Text -replace '\s+', ' ').Trim()
                "[FMT] " + $t.Substring(0, [Math]::Min(60, $t.Length))
            } else {
                $t = ($_.Text -replace '\s+', ' ').Trim()
                $t.Substring(0, [Math]::Min(80, $t.Length))
            }
        }}

    if ($IncludeText) {
        $items = $items | Select-Object *, @{n='Text';e={$_.Text}}
    }
    $items | Select-Object -First $Top
}

Stop-ClipboardHistory
Start-ClipboardHistory
'Test' | Set-Clipboard
start-sleep -Milliseconds 500
Get-ClipboardHistory
start-sleep -Seconds 1
Stop-ClipboardHistory