@echo off
adb kill-server
adb start-server
adb devices
adb tcpip 5555
REM Replace with your device IP below
adb connect 192.168.1.100:5555
adb devices
pause
