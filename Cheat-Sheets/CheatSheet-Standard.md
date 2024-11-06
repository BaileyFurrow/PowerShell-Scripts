# PowerShell Cheat Sheet - Standard

## **Basic Commands**

- **Get-Help** – Displays information about commands.

  ```powershell
  Get-Help <Command> -Full
  ```

- **Get-Command** – Lists available cmdlets, functions, workflows, aliases.

  ```powershell
  Get-Command -Name <Pattern> -Module <ModuleName>
  ```

- **Get-Alias** – Lists aliases for cmdlets.

  ```powershell
  Get-Alias
  ```

## **Core Cmdlets**

- **Get-Process** – Displays running processes.

  ```powershell
  Get-Process | Where-Object {$_.CPU -gt 100}
  ```

- **Get-Service** – Lists system services.

  ```powershell
  Get-Service | Where-Object {$_.Status -eq 'Stopped'}
  ```

- **Get-EventLog** – Retrieves event logs.

  ```powershell
  Get-EventLog -LogName Application -Newest 10
  ```

- **Test-Connection** – Network connectivity check (similar to ping).

  ```powershell
  Test-Connection -ComputerName 'hostname' -Count 2
  ```

## **Data Manipulation**

- **Where-Object** – Filters objects based on condition.

  ```powershell
  Get-Process | Where-Object {$_.CPU -gt 100}
  ```

- **Select-Object** – Selects specific properties.

  ```powershell
  Get-Service | Select-Object -Property Name, Status
  ```

- **Sort-Object** – Sorts objects by property.

  ```powershell
  Get-Process | Sort-Object CPU -Descending
  ```

- **Group-Object** – Groups objects by property.

  ```powershell
  Get-EventLog -LogName System | Group-Object -Property Source
  ```

- **Measure-Object** – Calculates statistical data.

  ```powershell
  Get-Process | Measure-Object -Property CPU -Sum
  ```

## **File & Directory Operations**

- **Get-ChildItem (ls, dir, gci)** – Lists files/directories.

  ```powershell
  Get-ChildItem -Path C:\ -Recurse -Filter "*.log"
  ```

- **New-Item** – Creates files or directories.

  ```powershell
  New-Item -Path 'C:\Logs' -ItemType Directory
  ```

- **Remove-Item** – Deletes files or directories.

  ```powershell
  Remove-Item -Path 'C:\Logs\old.log' -Force
  ```

- **Copy-Item** – Copies files or directories.

  ```powershell
  Copy-Item -Path 'C:\source.txt' -Destination 'C:\backup\'
  ```

- **Move-Item** – Moves files or directories.

  ```powershell
  Move-Item -Path 'C:\temp\file.txt' -Destination 'C:\archive\'
  ```

## **Text & String Manipulation**

- **Select-String** – Searches for text patterns.

  ```powershell
  Get-Content 'C:\Logs\log.txt' | Select-String -Pattern 'Error'
  ```

- **-replace** – Replaces text within strings.

  ```powershell
  "Hello World" -replace "World", "PowerShell"
  ```

- **-match** / **-notmatch** – Regex pattern matching.

  ```powershell
  $text -match '\d{3}-\d{2}-\d{4}'
  ```

## **Variables & Objects**

- **New-Variable** – Creates variables.

  ```powershell
  New-Variable -Name 'MyVar' -Value 'Hello'
  ```

- **Remove-Variable** – Deletes variables.

  ```powershell
  Remove-Variable -Name 'MyVar'
  ```

- **Select-Object -ExpandProperty** – Accesses properties.

  ```powershell
  $object | Select-Object -ExpandProperty Name
  ```

## **Scripting & Automation**

- **ForEach-Object** – Iterates through items.

  ```powershell
  Get-Process | ForEach-Object { $_.Name }
  ```

- **If/Else Statements** – Conditional execution.

  ```powershell
  if ($var -eq 10) { "Equal" } else { "Not equal" }
  ```

- **Switch Statement** – Simplifies conditional logic.

  ```powershell
  switch ($value) {
    1 { "One" }
    2 { "Two" }
    Default { "Other" }
  }
  ```

- **Try/Catch/Finally** – Error handling.

  ```powershell
  try {
    Get-Content 'file.txt'
  } catch {
    Write-Output "Error!"
  } finally {
    Write-Output "Done"
  }
  ```

- **Function Creation** – Defines reusable code blocks.

  ```powershell
  function Get-CustomProcess {
    param($Name)
    Get-Process -Name $Name
  }
  ```

## **Advanced Functions**

- **CmdletBinding** – Advanced function with pipeline support.

  ```powershell
  function Get-SampleProcess {
      [CmdletBinding()]
      param([Parameter(Mandatory=$true, ValueFromPipeline=$true)] $Name)
      process { Get-Process -Name $Name }
  }
  ```

- **Dynamic Parameters** – Define parameters at runtime.

  ```powershell
  function Test-DynamicParam {
      param()
      dynamicparam {
          # Code to create dynamic parameter
      }
  }
  ```

## **Modules & Importing**

- **Import-Module** – Loads a module into the session.

  ```powershell
  Import-Module ActiveDirectory
  ```

- **Get-Module** – Lists loaded modules.

  ```powershell
  Get-Module
  ```

## **Remote Management**

- **Enter-PSSession** – Starts an interactive session on a remote computer.

  ```powershell
  Enter-PSSession -ComputerName 'RemotePC'
  ```

- **Invoke-Command** – Runs commands on a remote computer.

  ```powershell
  Invoke-Command -ComputerName 'RemotePC' -ScriptBlock { Get-Service }
  ```

- **New-PSSession** – Creates a persistent remote session.

  ```powershell
  $session = New-PSSession -ComputerName 'RemotePC'
  ```

- **Import-PSSession** – Imports commands from a remote session.

  ```powershell
  Import-PSSession -Session $session
  ```

## **Error Handling**

- **$ErrorActionPreference** – Controls error action.

  ```powershell
  $ErrorActionPreference = "Stop"
  ```

- **Try/Catch** – Structured error handling.

  ```powershell
  try {
      # Command that may fail
  } catch {
      Write-Output "Caught error"
  }
  ```
