@echo off
REM Check if Android device is connected
adb devices | findstr /R /C:"device$" >nul
if %errorlevel% neq 0 (
    echo No Android device detected. Please connect via USB.
    pause
    exit /b 1
)
REM Enable wireless debugging
adb tcpip 5555
REM Get device IP from user
set /p DEVICE_IP=Enter your Android device IP:
adb connect %DEVICE_IP%:5555
REM Detect and export laptop IP
for /f "tokens=2 delims=: " %%a in ('ipconfig ^| findstr /i "IPv4"') do set LAPTOP_IP=%%a
setx LAPTOP_IP %LAPTOP_IP%
echo Laptop IP: %LAPTOP_IP%
REM Start Flask backend
start cmd /k "cd backend_flask && venv\Scripts\activate && python run.py"
REM Build and deploy Flutter app
start cmd /k "cd frontend_flutter && flutter run -d android"
REM Open VS Code
code .
pause
