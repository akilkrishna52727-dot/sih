@echo off
REM Detect laptop IP address
for /f "tokens=2 delims=: " %%a in ('ipconfig ^| findstr /i "IPv4"') do set LAPTOP_IP=%%a
setx LAPTOP_IP %LAPTOP_IP%
echo Laptop IP: %LAPTOP_IP%
REM Start Flask backend
start cmd /k "cd backend_flask && venv\Scripts\activate && python run.py"
REM Connect to Android device
call connect_device.bat
REM Launch Flutter app on device
start cmd /k "cd frontend_flutter && flutter run -d android"
pause
