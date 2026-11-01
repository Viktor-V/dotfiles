#!/usr/bin/env bash
set -uo pipefail

log_file="${XDG_CACHE_HOME:-$HOME/.cache}/opencode-web.log"

if [[ -z "${OPENCODE_SERVER_PASSWORD:-}" ]] && command -v powershell.exe >/dev/null 2>&1; then
  OPENCODE_SERVER_PASSWORD="$(powershell.exe -NoProfile -Command '$v = [Environment]::GetEnvironmentVariable("OPENCODE_SERVER_PASSWORD", "User"); if (-not $v) { $v = [Environment]::GetEnvironmentVariable("OPENCODE_SERVER_PASSWORD", "Machine") }; $v' 2>/dev/null | tr -d '\r\n')"
fi

if [[ -z "${OPENCODE_SERVER_PASSWORD:-}" ]]; then
  printf 'OPENCODE_SERVER_PASSWORD is not set in WSL or Windows\n' >&2
  exec fish
fi

export OPENCODE_SERVER_PASSWORD

if [[ -z "${OPENCODE_SERVER_USERNAME:-}" ]] && command -v powershell.exe >/dev/null 2>&1; then
  OPENCODE_SERVER_USERNAME="$(powershell.exe -NoProfile -Command '$v = [Environment]::GetEnvironmentVariable("OPENCODE_SERVER_USERNAME", "User"); if (-not $v) { $v = [Environment]::GetEnvironmentVariable("OPENCODE_SERVER_USERNAME", "Machine") }; $v' 2>/dev/null | tr -d '\r\n')"
fi

if [[ -n "${OPENCODE_SERVER_USERNAME:-}" ]]; then
  export OPENCODE_SERVER_USERNAME
fi

server_ready() {
  curl -sS --max-time 1 -o /dev/null "http://127.0.0.1:4096" 2>/dev/null
}

if ! server_ready; then
  mkdir -p "$(dirname "$log_file")"
  nohup opencode web --port 4096 --hostname 0.0.0.0 >>"$log_file" 2>&1 &
  disown || true

  for _ in {1..50}; do
    server_ready && break
    sleep 0.2
  done
fi

if ! server_ready; then
  printf 'opencode web failed to start; see %s\n' "$log_file" >&2
  exec fish
fi

opencode attach http://localhost:4096
exec fish
