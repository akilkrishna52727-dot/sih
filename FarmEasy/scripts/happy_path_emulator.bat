@echo off
setlocal

REM --- Configurable paths ---
set "BACKEND_DIR=D:\newapp1\FarmEasy\backend_flask"
set "FRONTEND_DIR=D:\newapp1\FarmEasy\frontend_flutter"
set "SCRIPTS_DIR=D:\newapp1\FarmEasy\scripts"
set "PORT=5000"

REM --- 0) Pre-check: Is port in use? ---
echo Checking if port %PORT% is free...
for /f "tokens=5" %%p in ('netstat -ano ^| findstr :%PORT% ^| findstr LISTENING') do set "PID=%%p"
if defined PID (
  echo WARNING: Port %PORT% currently in use by PID %PID%.
  echo If this is not your Flask server, please free it and re-run. Continuing anyway...
  set "PID="
)

REM --- 1) Start Flask backend (SQLite, no MySQL needed) ---
echo 1) Starting Flask backend (SQLite override)...
start "Flask Backend" cmd /k "cd /d %BACKEND_DIR% ^&^& set SQLALCHEMY_DATABASE_URI=sqlite:///farmeasy.db ^&^& set FLASK_DEBUG=0 ^&^& .\venv\Scripts\python.exe run.py"

REM --- Wait for port to be listening ---
echo Waiting for port %PORT% to be listening (max 30s)...
powershell -NoLogo -NoProfile -Command "$max=30; $ok=$false; for($i=0;$i -lt $max; $i++){ if ((Test-NetConnection -ComputerName 127.0.0.1 -Port %PORT%).TcpTestSucceeded){ $ok=$true; break } Start-Sleep -Seconds 1 }; if($ok){ exit 0 } else { Write-Host 'Port not listening after timeout'; exit 1 }"
if errorlevel 1 (
  echo ERROR: Backend did not start listening on port %PORT% within 30s.
  echo Check the 'Flask Backend' window for errors and try again.
  goto :end
)

REM --- 2) Start Android emulator ---
echo 2) Starting Android emulator...
start "Android Emulator" cmd /k "cd /d %SCRIPTS_DIR% ^&^& run_emulator.bat"

REM --- Give emulator time to boot ---
echo Allowing emulator time to boot (20s)...
timeout /t 20 /nobreak >nul

REM --- 3) Run Flutter app on emulator ---
echo 3) Running Flutter app on emulator...
cd /d %FRONTEND_DIR%
flutter run

:end
endlocal
