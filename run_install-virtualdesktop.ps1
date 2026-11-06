$ErrorActionPreference = 'Stop'
$dir = Join-Path $env:LOCALAPPDATA 'Programs\VirtualDesktop'
$exe = Join-Path $dir 'VirtualDesktop.exe'

if (Test-Path -LiteralPath $exe) {
    exit 0
}

try {
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
    $url = 'https://github.com/MScholtes/VirtualDesktop/releases/download/V1.21/VirtualDesktop11-24H2.exe'
    Invoke-WebRequest -Uri $url -OutFile $exe -UseBasicParsing
}
catch {
    Write-Warning "Could not install VirtualDesktop.exe: $($_.Exception.Message)"
}
