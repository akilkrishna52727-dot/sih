@echo off
REM Device connection verification
adb devices
REM Network connectivity test
ping 10.0.2.2 -n 2
ping %LAPTOP_IP% -n 2
REM Common error resolution
if not exist "%ANDROID_HOME%" (
    echo ANDROID_HOME not set. Please set ANDROID_HOME environment variable.
)
adb reconnect
adb usb
pause
