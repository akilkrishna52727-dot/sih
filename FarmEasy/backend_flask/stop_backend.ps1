param(
  [int]$Port = 5000,
  [string]$PidFile = ".backend.pid",
  [switch]$Quiet
)

$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$pidPath = Join-Path $scriptDir $PidFile

# Collect candidate PIDs without using the reserved $PID variable name
$ids = New-Object 'System.Collections.Generic.HashSet[int]'

# 1) From PID file (if present)
if (Test-Path -LiteralPath $pidPath) {
  try {
    $text = Get-Content -LiteralPath $pidPath -ErrorAction Stop | Select-Object -First 1
    if ($text -match '^\s*(\d+)\s*$') {
      [void]$ids.Add([int]$Matches[1])
    }
  } catch {}
}

# 2) From listeners on the specified port
try {
  $conns = Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue
  if ($conns) {
    foreach ($c in $conns) {
      if ($c.OwningProcess) { [void]$ids.Add([int]$c.OwningProcess) }
    }
  }
} catch {}

# 3) Fallback using netstat (in case Get-NetTCPConnection is unavailable)
if ($ids.Count -eq 0) {
  try {
    $netstat = netstat -ano | Select-String -Pattern "LISTENING.*:$Port\s"
    foreach ($line in $netstat) {
      $parts = $line.ToString().Trim() -split '\s+'
      $last = $parts[-1]
      if ($last -match '^\d+$') { [void]$ids.Add([int]$last) }
    }
  } catch {}
}

$currentProcessId = $PID
$stopped = @()
$failed = @()
foreach ($procId in $ids) {
  if ($procId -eq $currentProcessId) { continue }
  try {
    Stop-Process -Id $procId -Force -ErrorAction Stop
    $stopped += $procId
  } catch {
    $failed += ('PID ' + $procId + ' failed to stop')
  }
}

# Wait until the port is free (best effort)
$maxWaitMs = 15000
$intervalMs = 300
$elapsed = 0
while ($true) {
  try {
    $conn = Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue
    if (-not $conn) { break }
  } catch {}
  Start-Sleep -Milliseconds $intervalMs
  $elapsed += $intervalMs
  if ($elapsed -ge $maxWaitMs) { break }
}

# Remove PID file
if (Test-Path -LiteralPath $pidPath) {
  try { Remove-Item -LiteralPath $pidPath -Force -ErrorAction Stop } catch {}
}

if (-not $Quiet) {
  if ($stopped.Count -gt 0) { Write-Host ('Stopped processes on port ' + $Port + ' - ' + ($stopped -join ', ')) -ForegroundColor Green }
  elseif ($ids.Count -eq 0) { Write-Host ('No process found using port ' + $Port + '.') -ForegroundColor Yellow }
  else { Write-Host ('Attempted to stop PIDs [' + ($ids -join ', ') + ']') -ForegroundColor Yellow }
  if ($failed.Count -gt 0) { Write-Warning ('Failed to stop some PIDs: ' + ($failed -join '; ')) }
  $conn2 = Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue
  if (-not $conn2) { Write-Host ('Port ' + $Port + ' is free.') -ForegroundColor Green } else { Write-Warning ('Port ' + $Port + ' is still in use.') }
}

exit 0
