param(
  [string]$AvdName,
  [switch]$BuildRelease
)

$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptDir

function Get-AndroidSdkPath {
  if ($env:ANDROID_SDK_ROOT) { return $env:ANDROID_SDK_ROOT }
  if ($env:ANDROID_HOME) { return $env:ANDROID_HOME }
  # Common locations
  $candidates = @(
    "$env:LOCALAPPDATA\Android\Sdk",
    "$env:ProgramFiles(x86)\Android\android-sdk",
    "$env:ProgramFiles\Android\android-sdk"
  )
  foreach ($p in $candidates) { if (Test-Path -LiteralPath $p) { return $p } }
  return $null
}

function Wait-For-Emulator {
  param([int]$TimeoutSec = 120)
  $deadline = (Get-Date).AddSeconds($TimeoutSec)
  while ((Get-Date) -lt $deadline) {
    $devices = & $script:adbExe devices 2>$null | Select-String 'emulator-\d+\s+device'
    if ($devices) { return $true }
    Start-Sleep -Seconds 2
  }
  return $false
}

# Resolve adb/emulator
$script:adbExe = $null
$sdk = Get-AndroidSdkPath
if (Get-Command adb -ErrorAction SilentlyContinue) {
  $script:adbExe = (Get-Command adb).Source
} elseif ($sdk) {
  $cand = Join-Path $sdk 'platform-tools/adb.exe'
  if (Test-Path -LiteralPath $cand) { $script:adbExe = $cand }
}
if (-not $script:adbExe) { throw "adb not found. Set ANDROID_SDK_ROOT or add platform-tools to PATH." }

$emulatorExe = $null
if ($sdk) {
  $emuCand = Join-Path $sdk 'emulator/emulator.exe'
  if (Test-Path -LiteralPath $emuCand) { $emulatorExe = $emuCand }
}

if ($AvdName) {
  if (-not $emulatorExe) { throw "emulator.exe not found. Set ANDROID_SDK_ROOT or ensure Android SDK is installed." }
  Start-Process -FilePath $emulatorExe -ArgumentList @('-avd', $AvdName) -WindowStyle Minimized
}

# Wait for a device
if (-not (Wait-For-Emulator -TimeoutSec 180)) { throw "Emulator failed to boot within timeout." }

# Pick first emulator device id
$deviceId = (& $script:adbExe devices | Select-String '^(emulator-\d+)\s+device').Matches.Groups[1].Value | Select-Object -First 1
if (-not $deviceId) { throw "No running emulator device found." }

# Ensure flutter is available
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) { throw "flutter not found on PATH." }

# Run flutter app
$flutterArgs = @('run', '-d', $deviceId)
if ($BuildRelease) { $flutterArgs += @('--release') }

Start-Process -FilePath flutter -ArgumentList $flutterArgs -NoNewWindow
