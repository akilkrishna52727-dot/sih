@echo off
setlocal ENABLEDELAYEDEXPANSION

REM Determine project root (parent of the scripts folder)
set SCRIPT_DIR=%~dp0
for %%I in ("%SCRIPT_DIR%..") do set ROOT=%%~fI

echo Project root: %ROOT%

REM Clean Android build using gradle wrapper if present, else skip
set GRADLEW=%ROOT%\frontend_flutter\android\gradlew.bat
if exist "%GRADLEW%" (
  echo Cleaning Android build...
  pushd "%ROOT%\frontend_flutter\android"
  call gradlew.bat clean
  popd
) else (
  echo gradlew.bat not found under frontend_flutter\android. Skipping Gradle clean.
)

REM Run Flutter on the specified Android device
pushd "%ROOT%\frontend_flutter"
flutter run -d R9WR5035NDJ
popd

endlocal
