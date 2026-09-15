@echo off
setlocal EnableExtensions
REM ==========================================================================
REM  Shorebird PATCH - empuja los cambios (Dart + assets, incl. seeds offline)
REM  a la app instalada por internet. NO reinstala; se aplica al reabrir la app.
REM  Sincroniza los seeds antes, para que el parche lleve el offline al dia.
REM  Mismos flags que el release para que el parche sea compatible.
REM ==========================================================================
cd /d "%~dp0"
echo [1/2] Sincronizando seeds offline (backend -> assets)...
python tools\sync_offline_seeds.py
if errorlevel 1 ( echo. & echo *** SYNC FALLIDO *** & pause & exit /b 1 )
cd /d "%~dp0app"
echo.
echo [2/2] Shorebird patch (OTA, sin reinstalar)...
powershell -NoProfile -ExecutionPolicy Bypass -Command "& '%USERPROFILE%\.shorebird\bin\shorebird.ps1' patch android '--' --no-tree-shake-icons --dart-define=BASE_URL=https://ingles.ivanjonasfc.dev --dart-define=API_KEY=super-secret-key-123"
if errorlevel 1 ( echo. & echo *** PATCH FALLIDO *** & pause & exit /b 1 )
echo.
echo Patch enviado. El movil lo descarga y aplica al reabrir la app.
pause
