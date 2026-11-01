$ErrorActionPreference = 'Stop'

$programFiles = if ($env:ProgramW6432) { $env:ProgramW6432 } else { $env:ProgramFiles }
$cli = Join-Path $programFiles 'glzr.io\GlazeWM\cli\glazewm.exe'
if (-not (Test-Path -LiteralPath $cli)) {
  $cli = (Get-Command glazewm.exe -ErrorAction SilentlyContinue).Source
}
if (-not $cli) { exit 1 }

$lockPath = Join-Path $env:TEMP 'glazewm-workspace-close.lock'
try {
  $lock = [System.IO.File]::Open($lockPath, [System.IO.FileMode]::OpenOrCreate, [System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::None)
} catch {
  exit 0
}

function Get-WorkspaceSnapshot {
  (& $cli query workspaces | ConvertFrom-Json).data.workspaces
}

function Focus-RecentIfEmpty {
  Start-Sleep -Milliseconds 100
  $workspaces = @(Get-WorkspaceSnapshot)
  $focused = $workspaces | Where-Object { $_.hasFocus } | Select-Object -First 1
  if ($null -eq $focused) { return }
  if ($focused.children -and @($focused.children).Count -gt 0) { return }
  & $cli command focus --recent-workspace | Out-Null
}

while ($true) {
  & $cli sub -e window_unmanaged | ForEach-Object {
    try {
      $event = $_ | ConvertFrom-Json
      if ($event.data.eventType -eq 'window_unmanaged') { Focus-RecentIfEmpty }
    } catch {
    }
  }

  Start-Sleep -Seconds 1
}
