@echo off
REM Test connectivity to emulator and laptop IP
ping 10.0.2.2 -n 2
ping %LAPTOP_IP% -n 2
pause
