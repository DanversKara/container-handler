# Removes the ext+container:// handler for the current user.
Remove-Item -Recurse -Force -ErrorAction SilentlyContinue 'HKCU:\Software\Classes\ext+container'
Remove-Item -Recurse -Force -ErrorAction SilentlyContinue (Join-Path $env:LOCALAPPDATA 'BraveContainerLinks')
Write-Host 'Removed.'
