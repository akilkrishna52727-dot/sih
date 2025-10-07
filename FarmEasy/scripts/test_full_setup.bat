@echo off
setlocal

echo Testing FarmEasy complete setup...

REM Step 1: Starting Flask backend with SQLite
cd /d D:\newapp1\FarmEasy\backend_flask
start "Flask Backend" cmd /k "set SQLALCHEMY_DATABASE_URI=sqlite:///farmeasy.db ^&^& .\venv\Scripts\python.exe run.py"

echo Waiting for backend to listen on 5000 (max 30s)...
powershell -NoLogo -NoProfile -Command "$max=30; $ok=$false; for($i=0;$i -lt $max; $i++){ if ((Test-NetConnection -ComputerName 127.0.0.1 -Port 5000).TcpTestSucceeded){ $ok=$true; break } Start-Sleep -Seconds 1 }; if($ok){ exit 0 } else { Write-Host 'Port not listening after timeout'; exit 1 }"
if errorlevel 1 (
  echo Backend failed to start. Check the 'Flask Backend' window for errors.
  goto :end
)

REM Step 2: Testing backend health endpoint
powershell -NoLogo -NoProfile -Command "try { (Invoke-WebRequest -UseBasicParsing http://127.0.0.1:5000/api/health).StatusCode } catch { $_.Exception.Message }"

REM Step 3: Starting Android emulator (via Flutter tooling)
flutter emulators --launch Pixel_7_API_34

echo Allowing emulator to boot (15s)...
timeout /t 15 /nobreak >nul

REM Step 4: Running Flutter app on emulator
cd /d D:\newapp1\FarmEasy\frontend_flutter
flutter run

:end
endlocal
