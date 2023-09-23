function Import-HTML {
    param (
        $file
    )
    process {
        $html = New-Object -COM "HTMLFile"
        $content = Get-Content $file -Raw
        $src = [System.Text.Encoding]::Unicode.GetBytes($content)
        $html.write($src)
        return $html
    }
    
}