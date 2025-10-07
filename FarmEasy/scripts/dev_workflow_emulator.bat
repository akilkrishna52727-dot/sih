@echo off
setlocal

echo Starting FarmEasy development with emulator...

REM 1. Starting Flask backend
set "BACKEND_DIR=D:\newapp1\FarmEasy\backend_flask"
start cmd /k "cd /d %BACKEND_DIR% ^&^& .\venv\Scripts\activate ^&^& python run.py"

REM Wait a few seconds for backend to start
timeout /t 5 /nobreak >nul

REM 2. Starting Android emulator
set "SCRIPTS_DIR=D:\newapp1\FarmEasy\scripts"
start cmd /k "cd /d %SCRIPTS_DIR% ^&^& run_emulator.bat"

REM Give emulator time to boot
timeout /t 10 /nobreak >nul

REM 3. Running Flutter app on emulator
cd /d D:\newapp1\FarmEasy\frontend_flutter
flutter run

endlocal
