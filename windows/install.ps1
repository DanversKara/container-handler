# Registers ext+container:// links for the current user (no admin needed).
# Run from this folder:  powershell -ExecutionPolicy Bypass -File .\install.ps1

$ErrorActionPreference = 'Stop'
$dest = Join-Path $env:LOCALAPPDATA 'BraveContainerLinks'
New-Item -ItemType Directory -Force -Path $dest | Out-Null
Copy-Item -Force (Join-Path $PSScriptRoot 'brave-container-open.ps1') $dest
$script = Join-Path $dest 'brave-container-open.ps1'

$ps = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
$command = "`"$ps`" -NoProfile -NonInteractive -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$script`" `"%1`""

$key = 'HKCU:\Software\Classes\ext+container'
New-Item -Force -Path $key | Out-Null
Set-ItemProperty -Path $key -Name '(default)' -Value 'URL:Brave container link'
Set-ItemProperty -Path $key -Name 'URL Protocol' -Value ''
New-Item -Force -Path "$key\shell\open\command" | Out-Null
Set-ItemProperty -Path "$key\shell\open\command" -Name '(default)' -Value $command

Write-Host "Installed to $dest"
Write-Host "Test:  Start-Process 'ext+container://GOOGLE/https://claude.ai/new'"
