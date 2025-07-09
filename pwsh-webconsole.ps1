Add-Type -AssemblyName System.Net.HttpListener

$html = @"
<!DOCTYPE html>
<html>
<head>
  <title>PowerShell Web Host</title>
  <meta charset="UTF-8">
  <style>
    body { font-family: monospace; background: #222; color: #ddd; }
    #cmd { width: 90%; font-family: monospace; font-size: 1em; background: #222; color: #fff; border: 1px solid #444; border-radius: 4px; padding: 0.5em;}
    #run { font-size: 1em; background: #444; color: #fff; border: none; border-radius: 4px; padding: 0.5em 1em; margin-left: 0.5em;}
    #output { white-space: pre-wrap; background: #111; color: #0f0; padding: 1em; border-radius: 6px; margin-top: 1em; min-height: 4em; }
    #output.error { color: #fff; background: #330000; border: 1px solid #800; }
    #container { max-width: 700px; margin: auto; margin-top: 3em; }
    .token.operator { color: #ffcb6b; }
    .token.keyword { color: #82aaff; }
    .token.string { color: #c3e88d; }
    .token.number { color: #f78c6c; }
    .token.comment { color: #616161; font-style: italic; }
    code[class*="language-"], pre[class*="language-"] {
      background: none !important;
      color: inherit;
      font-family: inherit;
      font-size: 1em;
      line-height: inherit;
    }
  </style>
  <link href="https://cdn.jsdelivr.net/npm/prismjs@1.29.0/themes/prism-tomorrow.min.css" rel="stylesheet"/>
</head>
<body>
  <div id="container">
    <h2>PowerShell Web Host</h2>
    <input id="cmd" type="text" autocomplete="off" autofocus placeholder="Enter PowerShell command">
    <button id="run">Run</button>
    <pre><code id="preview" class="language-powershell"></code></pre>
    <div id="output"></div>
  </div>
  <script src="https://cdn.jsdelivr.net/npm/prismjs@1.29.0/prism.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/prismjs@1.29.0/components/prism-powershell.min.js"></script>
  <script>
    const cmdBox = document.getElementById('cmd');
    const outputBox = document.getElementById('output');
    const previewBox = document.getElementById('preview');
    const runBtn = document.getElementById('run');

    function updatePreview() {
      previewBox.textContent = cmdBox.value;
      Prism.highlightElement(previewBox);
    }
    cmdBox.addEventListener('input', updatePreview);
    updatePreview();

    function runCmd() {
      outputBox.className = "";
      outputBox.textContent = "Running...";
      fetch("/", {
        method: "POST",
        headers: { "Content-Type": "text/plain" },
        body: cmdBox.value
      })
      .then(r => r.json())
      .then(obj => {
        if (obj.error) {
          outputBox.className = "error";
          outputBox.textContent = obj.error;
        } else {
          outputBox.className = "";
          outputBox.textContent = obj.output;
        }
      })
      .catch(e => {
        outputBox.className = "error";
        outputBox.textContent = "Error: " + e;
      });
    }
    runBtn.onclick = runCmd;
    cmdBox.addEventListener("keydown", function(e) {
      if (e.key === "Enter") runCmd();
    });
  </script>
</body>
</html>
"@

$listener = [System.Net.HttpListener]::new()
$listener.Prefixes.Add("http://localhost:8080/")
$listener.Start()
Write-Host "Listening on http://localhost:8080/..."

function Send-JsonResponse {
    param($response, $data, $status = 200)
    $json = ConvertTo-Json $data -Compress
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($json)
    $response.StatusCode = $status
    $response.ContentType = "application/json"
    $response.OutputStream.Write($bytes, 0, $bytes.Length)
}

try {
    while ($true) {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response

        if ($request.HttpMethod -eq 'GET') {
            $bytes = [System.Text.Encoding]::UTF8.GetBytes($html)
            $response.ContentType = "text/html"
            $response.StatusCode = 200
            $response.OutputStream.Write($bytes, 0, $bytes.Length)
        }
        elseif ($request.HttpMethod -eq 'POST') {
            $reader = New-Object IO.StreamReader $request.InputStream, $request.ContentEncoding
            $command = $reader.ReadToEnd()
            $reader.Close()
            try {
                $ps = [PowerShell]::Create()
                $ps.AddScript($command) | Out-Null
                $result = $ps.Invoke()

                # Collect output, errors, and info messages
                $output = ($result | Out-String)
                $errMsgs = ($ps.Streams.Error | ForEach-Object { $_.ToString() }) -join "`n"
                if ($errMsgs) {
                    Write-Host "Error in command: $command" -ForegroundColor Red
                    Write-Host $errMsgs -ForegroundColor Red
                    Send-JsonResponse $response @{ error = $errMsgs }
                }
                else {
                    Write-Host "Successfully ran command: $command" -ForegroundColor Green
                    Send-JsonResponse $response @{ output = $output }
                }
            }
            catch {
                $err = $_ | Out-String
                Send-JsonResponse $response @{ error = $err } 500
            }
        }
        else {
            $response.StatusCode = 405
        }
        $response.OutputStream.Close()
    }
}
finally {
    $listener.Stop()
}
