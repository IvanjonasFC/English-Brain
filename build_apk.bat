@echo off
setlocal EnableExtensions
REM ==========================================================================
REM  English Brain - genera el APK release y lo deja en el Escritorio.
REM  Doble clic. La copia al Escritorio (incl. OneDrive) la hace build_apk.ps1.
REM ==========================================================================
set "BASE_URL=https://ingles.ivanjonasfc.dev"
REM  Alternativa publica (LAN + datos moviles, requiere Caddy arriba):
REM  set "BASE_URL=http://192.168.0.200:8092"
set "API_KEY=super-secret-key-123"

cd /d "%~dp0"
echo == English Brain - build APK ==
echo Backend: %BASE_URL%
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0build_apk.ps1" -BaseUrl "%BASE_URL%" -ApiKey "%API_KEY%"
if errorlevel 1 (
  echo.
  echo *** BUILD FALLIDO - revisa el error de arriba ***
  pause
  exit /b 1
)
echo.
echo Listo. APK en el Escritorio como English_Coach.apk
REM Abre el Escritorio para verlo:
powershell -NoProfile -Command "explorer ([Environment]::GetFolderPath('Desktop'))"
pause
