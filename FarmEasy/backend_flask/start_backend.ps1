param(
  [int]$Port = 5000,
  [string]$PidFile = ".backend.pid",
  [switch]$UseSQLite,
  [switch]$Quiet
)

$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$pidPath = Join-Path $scriptDir $PidFile

# Ensure we're in backend folder for relative paths
Set-Location $scriptDir

# Stop anything on the port first
& "$scriptDir\stop_backend.ps1" -Port $Port -PidFile $PidFile -Quiet

# Resolve Python
$venvPy = Join-Path $scriptDir "venv\Scripts\python.exe"
$pythonExe = $null
if (Test-Path -LiteralPath $venvPy) { $pythonExe = $venvPy }
elseif (Get-Command py -ErrorAction SilentlyContinue) { $pythonExe = "py" }
elseif (Get-Command python -ErrorAction SilentlyContinue) { $pythonExe = "python" }
else { throw "Python not found. Ensure venv exists or 'py'/'python' is on PATH." }

# Configure environment for child process (inherited)
$prevDb = $env:SQLALCHEMY_DATABASE_URI
$prevDebug = $env:FLASK_DEBUG
if ($UseSQLite -or -not $env:SQLALCHEMY_DATABASE_URI) { $env:SQLALCHEMY_DATABASE_URI = 'sqlite:///farmeasy.db' }
$env:FLASK_DEBUG = '0'

# Prepare logs directory
$logsDir = Join-Path $scriptDir 'logs'
if (-not (Test-Path -LiteralPath $logsDir)) { New-Item -ItemType Directory -Path $logsDir | Out-Null }
$outLog = Join-Path $logsDir 'backend.out.log'
$errLog = Join-Path $logsDir 'backend.err.log'

# Start Flask app (run.py) detached with output redirection
$arguments = @('run.py')

$startInfo = @{
  FilePath = $pythonExe
  ArgumentList = $arguments
  WorkingDirectory = $scriptDir
  PassThru = $true
  RedirectStandardOutput = $outLog
  RedirectStandardError = $errLog
  WindowStyle = 'Hidden'
}

$proc = Start-Process @startInfo
if (-not $proc -or -not $proc.Id) { throw "Failed to start backend (python run.py)." }

# Write PID file
Set-Content -LiteralPath $pidPath -Value $proc.Id -Encoding ASCII

# Wait for health endpoint
$baseUrl = "http://127.0.0.1:$Port"
$healthUrl = "$baseUrl/api/health"

$maxWaitSec = 45
$intervalMs = 500
$deadline = (Get-Date).AddSeconds($maxWaitSec)
$ready = $false

while ((Get-Date) -lt $deadline) {
  Start-Sleep -Milliseconds $intervalMs
  if ($proc.HasExited) {
    break
  }
  try {
    $resp = Invoke-WebRequest -UseBasicParsing -Uri $healthUrl -Method GET -TimeoutSec 2 -ErrorAction Stop
    if ($resp.StatusCode -ge 200 -and $resp.StatusCode -lt 300) { $ready = $true; break }
  } catch {
    # keep trying
  }
}

# Restore env vars in current session
if ($UseSQLite) { $env:SQLALCHEMY_DATABASE_URI = $prevDb }
$env:FLASK_DEBUG = $prevDebug

if (-not $Quiet) {
  if ($ready) {
    Write-Host ("Backend is ready at {0} (PID {1})." -f $baseUrl, $proc.Id) -ForegroundColor Green
  } else {
    if ($proc.HasExited) {
      Write-Warning ("Backend process exited with code {0}. Showing last 50 lines of logs:" -f $proc.ExitCode)
    } else {
      Write-Warning ("Backend did not become healthy within {0} seconds. Showing last 50 lines of logs:" -f $maxWaitSec)
    }
    if (Test-Path -LiteralPath $outLog) {
      Write-Host "===== STDOUT =====" -ForegroundColor Yellow
      Get-Content -LiteralPath $outLog -Tail 50 | ForEach-Object { Write-Host $_ }
    }
    if (Test-Path -LiteralPath $errLog) {
      Write-Host "===== STDERR =====" -ForegroundColor Yellow
      Get-Content -LiteralPath $errLog -Tail 50 | ForEach-Object { Write-Host $_ }
    }
  }
}

exit 0
