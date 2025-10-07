@echo off
adb tcpip 5555
set /p DEVICE_IP=Enter your Android device IP:
adb connect %DEVICE_IP%:5555
adb devices
pause
