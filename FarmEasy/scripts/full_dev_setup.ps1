$ErrorActionPreference = "Stop"

# Paths
$repoRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$backendDir = Join-Path $repoRoot 'backend_flask'
$frontendDir = Join-Path $repoRoot 'frontend_flutter'

# 1) Stop any existing backend on 5000
& (Join-Path $backendDir 'stop_backend.ps1') -Port 5000 -Quiet

# 2) Start backend (SQLite by default)
& (Join-Path $backendDir 'start_backend.ps1') -Port 5000 -UseSQLite

# 3) Launch emulator and run app (if an AVD name is desired, set $env:FARMEASY_AVD)
$runEmu = Join-Path $frontendDir 'run_emulator.ps1'
if ($env:FARMEASY_AVD) {
  & $runEmu -AvdName $env:FARMEASY_AVD
} else {
  & $runEmu
}
