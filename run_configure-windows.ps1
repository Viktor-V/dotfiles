$ErrorActionPreference = 'Stop'

$changed = $false

$advanced = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
$hideIcons = (Get-ItemProperty -Path $advanced -Name HideIcons -ErrorAction SilentlyContinue).HideIcons
if ($hideIcons -ne 1) {
  Set-ItemProperty -Path $advanced -Name HideIcons -Type DWord -Value 1
  $changed = $true
}

$stuckRects = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3'
$settings = (Get-ItemProperty -Path $stuckRects -Name Settings -ErrorAction SilentlyContinue).Settings
if ($null -ne $settings -and (($settings[8] -band 1) -eq 0)) {
  $settings[8] = [byte](($settings[8]) -bor 1)
  Set-ItemProperty -Path $stuckRects -Name Settings -Type Binary -Value $settings
  $changed = $true
}

if ($changed) {
  Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
  Start-Sleep -Seconds 1
  if (-not (Get-Process -Name explorer -ErrorAction SilentlyContinue)) {
    Start-Process explorer.exe
  }
}
