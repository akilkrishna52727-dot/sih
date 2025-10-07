@echo off
REM Automatic ADB device detection and connection
adb kill-server
adb start-server
adb devices
REM Setup wireless debugging
adb tcpip 5555
REM Get device IP from user
set /p DEVICE_IP=Enter your Android device IP:
adb connect %DEVICE_IP%:5555
adb devices
pause
