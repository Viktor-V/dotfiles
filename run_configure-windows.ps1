$ErrorActionPreference = 'Stop'

$changed = $false

$advanced = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
$hideIcons = (Get-ItemProperty -Path $advanced -Name HideIcons -ErrorAction SilentlyContinue).HideIcons
if ($hideIcons -ne 1) {
  Set-ItemProperty -Path $advanced -Name HideIcons -Type DWord -Value 1
  $changed = $true
}

if ($changed) {
  Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
  Start-Sleep -Seconds 1
  if (-not (Get-Process -Name explorer -ErrorAction SilentlyContinue)) {
    Start-Process explorer.exe
  }
}
