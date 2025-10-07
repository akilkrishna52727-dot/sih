@echo off
for /f "tokens=2 delims=: " %%a in ('ipconfig ^| findstr /i "IPv4"') do set LAPTOP_IP=%%a
setx LAPTOP_IP %LAPTOP_IP%
echo Laptop IP exported as LAPTOP_IP=%LAPTOP_IP%
