@echo off
setlocal EnableExtensions
REM ==========================================================================
REM  Shorebird RELEASE (apk parcheable). Sincroniza los seeds offline, compila
REM  el APK y lo deja en el Escritorio. Instala ESE APK en el movil UNA vez;
REM  despues actualiza con shorebird_patch.bat (sin reinstalar).
REM  NOTA: llamamos a shorebird.ps1 directamente porque el wrapper shorebird.bat
REM  descarta el separador "--" en Windows.
REM ==========================================================================
cd /d "%~dp0"
echo [1/2] Sincronizando seeds offline (backend -> assets)...
python tools\sync_offline_seeds.py
if errorlevel 1 ( echo. & echo *** SYNC FALLIDO *** & pause & exit /b 1 )
cd /d "%~dp0app"
echo.
echo [2/2] Shorebird release (apk)...
powershell -NoProfile -ExecutionPolicy Bypass -Command "& '%USERPROFILE%\.shorebird\bin\shorebird.ps1' release android --artifact apk '--' --no-tree-shake-icons --dart-define=BASE_URL=https://ingles.ivanjonasfc.dev --dart-define=API_KEY=super-secret-key-123"
if errorlevel 1 ( echo. & echo *** RELEASE FALLIDO *** & pause & exit /b 1 )
powershell -NoProfile -Command "$apk=Get-ChildItem -Recurse -Filter app-release.apk build\app\outputs 2>$null | Select-Object -First 1; if($apk){Copy-Item $apk.FullName (Join-Path ([Environment]::GetFolderPath('Desktop')) 'English_Coach.apk') -Force; Write-Host ('APK copiado al Escritorio: English_Coach.apk (' + ('{0:N1} MB' -f ($apk.Length/1MB)) + ')')}"
echo.
echo Instala English_Coach.apk en el movil (solo esta vez). Updates -> shorebird_patch.bat
pause
