@echo off
set LOGFILE=development.log
set GREEN=0A
set RED=0C

REM Kill existing ADB connections
adb disconnect >> %LOGFILE%
adb kill-server >> %LOGFILE%
call :colorEcho %GREEN% "[STEP] ADB server killed."

REM Restart ADB server
adb start-server >> %LOGFILE%
call :colorEcho %GREEN% "[STEP] ADB server restarted."

REM Re-establish USB debugging
adb usb >> %LOGFILE%
call :colorEcho %GREEN% "[STEP] USB debugging re-established."

REM Clear Flutter build cache
cd frontend_flutter
flutter clean >> %LOGFILE%
call :colorEcho %GREEN% "[STEP] Flutter build cache cleared."
cd ..

call :colorEcho %GREEN% "[INFO] Debug environment reset. Log: %LOGFILE%"
pause
exit /b

:colorEcho
setlocal
set "msg=%~2"
for /f "delims=" %%A in ('echo prompt $E ^| cmd') do set "ESC=%%A"
echo %ESC%[%~1m%msg%%ESC%[0m
endlocal
exit /b
