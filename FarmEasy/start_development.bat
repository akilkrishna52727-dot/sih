@echo off
REM Logging setup
set LOGFILE=development.log

REM Color codes
set GREEN=0A
set RED=0C

REM Execute PowerShell IP detection
powershell -ExecutionPolicy Bypass -File get_laptop_ip.ps1 >> %LOGFILE%

REM Start Flask backend
call :colorEcho %GREEN% "[STEP] Starting Flask backend..."
start cmd /k "cd backend_flask && venv\Scripts\activate && python run.py --host=0.0.0.0" >> %LOGFILE%

REM Check Android device connection
call :colorEcho %GREEN% "[STEP] Checking Android device connection..."
adb devices >> %LOGFILE%

REM Launch Flutter app
call :colorEcho %GREEN% "[STEP] Launching Flutter app on device..."
start cmd /k "cd frontend_flutter && flutter run -d android" >> %LOGFILE%

REM Open VS Code
call :colorEcho %GREEN% "[STEP] Opening VS Code..."
code . >> %LOGFILE%

pause
exit /b

:colorEcho
setlocal
set "msg=%~2"
for /f "delims=" %%A in ('echo prompt $E ^| cmd') do set "ESC=%%A"
echo %ESC%[%~1m%msg%%ESC%[0m
endlocal
exit /b
