$ErrorActionPreference = 'Stop'

$programFiles = if ($env:ProgramW6432) { $env:ProgramW6432 } else { $env:ProgramFiles }
$cli = Join-Path $programFiles 'glzr.io\GlazeWM\cli\glazewm.exe'
if (-not (Test-Path -LiteralPath $cli)) {
  $cli = (Get-Command glazewm.exe -ErrorAction SilentlyContinue).Source
}
if (-not $cli) { exit 1 }

$focused = (& $cli query focused | ConvertFrom-Json).data.focused
if ($null -eq $focused -or $focused.type -ne 'window') { exit 0 }

$workspace = (& $cli query workspaces | ConvertFrom-Json).data.workspaces |
  Where-Object { $_.hasFocus } |
  Select-Object -First 1
if ($null -eq $workspace) { exit 0 }

$isMaximized = ($focused.state.type -eq 'floating') -and `
  ([math]::Abs($focused.x - $workspace.x) -le 2) -and `
  ([math]::Abs($focused.y - $workspace.y) -le 2) -and `
  ([math]::Abs($focused.width - $workspace.width) -le 2) -and `
  ([math]::Abs($focused.height - $workspace.height) -le 2)

if ($isMaximized) {
  & $cli command --id $focused.id toggle-tiling | Out-Null
} else {
  & $cli command --id $focused.id set-floating --centered=false | Out-Null
  & $cli command --id $focused.id size --width "$($workspace.width)px" --height "$($workspace.height)px" | Out-Null
  & $cli command --id $focused.id position --x-pos $workspace.x --y-pos $workspace.y | Out-Null
}
