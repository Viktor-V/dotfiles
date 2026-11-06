param(
    [Parameter(Mandatory = $true)]
    [int]$ProcessId,
    [string]$DesktopName = '',
    [switch]$Switch,
    [string]$VirtualDesktopExe = "$env:LOCALAPPDATA\Programs\VirtualDesktop\VirtualDesktop.exe"
)

$ErrorActionPreference = 'Stop'
$logDir = Join-Path $env:LOCALAPPDATA 'VirtualDesktop'
$logFile = Join-Path $logDir 'wezterm-desktop.log'
New-Item -ItemType Directory -Path $logDir -Force | Out-Null

function Write-Log([string]$Message) {
    "$([datetime]::Now.ToString('s')) $Message" | Add-Content -LiteralPath $logFile -Encoding UTF8
}

function Read-Name([string]$FileName) {
    $path = Join-Path $PSScriptRoot $FileName
    if (Test-Path -LiteralPath $path) {
        return [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8).Trim()
    }
    return ''
}

try {
    if ([string]::IsNullOrEmpty($DesktopName)) {
        $DesktopName = Read-Name 'desktop-name.txt'
        if ([string]::IsNullOrEmpty($DesktopName)) {
            $fallback = Join-Path (Split-Path -Parent $VirtualDesktopExe) 'desktop-name.txt'
            if (Test-Path -LiteralPath $fallback) {
                $DesktopName = [System.IO.File]::ReadAllText($fallback, [System.Text.Encoding]::UTF8).Trim()
            }
        }
    }

    if ([string]::IsNullOrEmpty($DesktopName)) {
        Write-Log 'Desktop name is empty'
        exit 1
    }

    if (-not (Test-Path -LiteralPath $VirtualDesktopExe)) {
        Write-Log "VirtualDesktop.exe not found: $VirtualDesktopExe"
        exit 1
    }

    $hwnd = [int64]0
    for ($i = 0; $i -lt 60; $i++) {
        $process = Get-Process -Id $ProcessId -ErrorAction SilentlyContinue
        if (-not $process) {
            Write-Log "Process $ProcessId exited before a window appeared"
            exit 1
        }
        $process.Refresh()
        if ($process.MainWindowHandle -ne 0) {
            $hwnd = [int64]$process.MainWindowHandle
            break
        }
        Start-Sleep -Milliseconds 250
    }

    if ($hwnd -eq 0) {
        Write-Log "No window handle for process $ProcessId"
        exit 1
    }

    & $VirtualDesktopExe /Quiet /GetDesktop:$DesktopName 2>$null
    if ($LASTEXITCODE -lt 0) {
        Write-Log "Desktop '$DesktopName' not found; preparing desktops"
        $mainName = Read-Name 'main-desktop-name.txt'

        & $VirtualDesktopExe /Quiet /Count 2>$null
        $count = $LASTEXITCODE

        if ($count -le 1 -and -not [string]::IsNullOrEmpty($mainName)) {
            & $VirtualDesktopExe /Quiet /GetDesktop:0 /Name:$mainName 2>$null
            & $VirtualDesktopExe /Quiet /New 2>$null
            $newIndex = $LASTEXITCODE
            if ($newIndex -ge 0) {
                & $VirtualDesktopExe /Quiet /GetDesktop:$newIndex /Name:$DesktopName 2>$null
            }
            else {
                & $VirtualDesktopExe /Quiet '/GetDesktop:*last*' /Name:$DesktopName 2>$null
            }
        }
        else {
            & $VirtualDesktopExe /Quiet '/GetDesktop:*last*' /Name:$DesktopName 2>$null
        }
    }

    & $VirtualDesktopExe /Quiet /GetDesktop:$DesktopName /MoveWindowHandle:$hwnd 2>$null
    $moveExit = $LASTEXITCODE
    Write-Log "Moved hwnd $hwnd (pid $ProcessId) to desktop '$DesktopName' (exit $moveExit)"

    if ($Switch) {
        & $VirtualDesktopExe /Quiet /Switch:$DesktopName 2>$null
        Write-Log "Switched to desktop '$DesktopName' (exit $LASTEXITCODE)"
    }

    exit $moveExit
}
catch {
    Write-Log "ERROR: $($_.Exception.Message)"
    exit 1
}
