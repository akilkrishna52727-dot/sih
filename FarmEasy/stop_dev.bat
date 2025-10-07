@echo off
REM Stop Flask backend
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :5000') do taskkill /PID %%a /F
REM Kill Flutter process
taskkill /IM dart.exe /F
REM Kill ADB server
adb kill-server
echo All services stopped.
pause
