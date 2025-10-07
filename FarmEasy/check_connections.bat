@echo off
set LOGFILE=development.log
set GREEN=0A
set RED=0C

REM Verify ADB device connection
adb devices | findstr /R /C:"device$" >nul
if %errorlevel%==0 (
    call :colorEcho %GREEN% "[SUCCESS] Android device connected."
    echo [SUCCESS] Android device connected. >> %LOGFILE%
) else (
    call :colorEcho %RED% "[ERROR] No Android device detected."
    echo [ERROR] No Android device detected. >> %LOGFILE%
)

REM Test network connectivity to laptop IP
set LAPTOP_IP=
for /f "tokens=*" %%i in (frontend_flutter\.env) do (
    for /f "tokens=2 delims==" %%a in ("%%i") do set LAPTOP_IP=%%a
)
ping %LAPTOP_IP% -n 2 >nul
if %errorlevel%==0 (
    call :colorEcho %GREEN% "[SUCCESS] Network connectivity to %LAPTOP_IP%."
    echo [SUCCESS] Network connectivity to %LAPTOP_IP%. >> %LOGFILE%
) else (
    call :colorEcho %RED% "[ERROR] Cannot reach %LAPTOP_IP%."
    echo [ERROR] Cannot reach %LAPTOP_IP%. >> %LOGFILE%
)

REM Check if Flask backend is running
powershell -Command "try { $r = Invoke-WebRequest -Uri http://%LAPTOP_IP%:5000/api -UseBasicParsing -TimeoutSec 5; $true } catch { $false }" >nul
if %errorlevel%==0 (
    call :colorEcho %GREEN% "[SUCCESS] Flask backend is running."
    echo [SUCCESS] Flask backend is running. >> %LOGFILE%
) else (
    call :colorEcho %RED% "[ERROR] Flask backend not accessible."
    echo [ERROR] Flask backend not accessible. >> %LOGFILE%
)

call :colorEcho %GREEN% "[INFO] Connection status summary logged to %LOGFILE%."
pause
exit /b

:colorEcho
setlocal
set "msg=%~2"
for /f "delims=" %%A in ('echo prompt $E ^| cmd') do set "ESC=%%A"
echo %ESC%[%~1m%msg%%ESC%[0m
endlocal
exit /b
