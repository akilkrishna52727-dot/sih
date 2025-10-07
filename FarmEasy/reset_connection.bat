@echo off
adb kill-server
adb start-server
adb devices
pause
