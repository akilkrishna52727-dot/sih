@echo off
REM connect_android_device.bat

echo ===========================================
echo   Android USB to Wireless Debugging Setup
echo ===========================================

REM Check if adb is installed
where adb >nul 2>nul
if errorlevel 1 (
    echo [ERROR] adb not found. Please install Android Platform Tools and add adb to your PATH.
    exit /b 1
)

REM List connected devices
echo [STEP 1] Listing connected Android devices...
adb devices
if errorlevel 1 (
    echo [ERROR] Failed to list devices. Is your device connected via USB and USB debugging enabled?
    exit /b 1
)

REM Enable TCP/IP debugging
echo [STEP 2] Enabling TCP/IP debugging on port 5555...
adb tcpip 5555
if errorlevel 1 (
    echo [ERROR] Failed to enable TCP/IP debugging. Make sure your device is connected and unlocked.
    exit /b 1
)

REM Wait for device to switch to TCP/IP mode
echo Waiting for device to switch to wireless mode...
timeout /t 5 >nul

REM Get laptop IP using PowerShell
echo [STEP 3] Detecting your laptop IP address...
FOR /F "usebackq tokens=*" %%i IN (`powershell -Profile -Command ^
    "$adapterPatterns = @('Wi-Fi','WiFi','Wireless','Hotspot','Ethernet'); ^
    $ip = $null; ^
    foreach ($pattern in $adapterPatterns) { ^
        $ipObj = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -like \"*$pattern*\" -and $_.IPAddress -notlike \"169.254*\" } | Select-Object -First 1; ^
        if ($ipObj) { $ip = $ipObj.IPAddress; break } ^
    }; ^
    if ($ip) { Write-Output $ip } else { Write-Output 'NO_IP_FOUND' }"`) DO (
    set LAPTOP_IP=%%i
)

if "%LAPTOP_IP%"=="NO_IP_FOUND" (
    echo [ERROR] Could not detect your laptop IP address. Check your network connection.
    exit /b 1
)

REM Display connection instructions
echo [STEP 4] Your laptop IP: %LAPTOP_IP%
echo [INFO] To connect your Android device wirelessly, ensure both devices are on the same WiFi network.
echo [INFO] On your device, run:
echo     adb connect %LAPTOP_IP%:5555

echo [STEP 5] Attempting to connect device wirelessly...
adb connect %LAPTOP_IP%:5555
if errorlevel 1 (
    echo [ERROR] Wireless connection failed. Try reconnecting USB and repeat the steps.
    exit /b 1
)

echo ===========================================
echo   Wireless debugging setup complete!
echo   You can now disconnect the USB cable.
echo ===========================================

REM Instructions for next steps
echo [NEXT STEPS] 
echo - Use 'adb devices' to verify wireless connection.
echo - If connection fails, reconnect USB and repeat.
