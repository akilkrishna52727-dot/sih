@echo off
setlocal

echo Starting Android emulator...
if not defined ANDROID_HOME (
  echo ANDROID_HOME is not set. Trying to use default Android SDK location...
)

REM Attempt to change to emulator directory using ANDROID_HOME, fall back to common paths
if defined ANDROID_HOME (
  if exist "%ANDROID_HOME%\emulator" (
    cd /d "%ANDROID_HOME%\emulator"
  ) else if exist "%ANDROID_HOME%\..\emulator" (
    cd /d "%ANDROID_HOME%\..\emulator"
  )
) else (
  if exist "%LOCALAPPDATA%\Android\Sdk\emulator" cd /d "%LOCALAPPDATA%\Android\Sdk\emulator"
)

REM Launch the AVD; change the name if your AVD differs
emulator -avd Pixel_7_API_34 -netdelay none -netspeed full

endlocal
