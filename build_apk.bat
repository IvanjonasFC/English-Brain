@echo off
setlocal EnableExtensions
REM ==========================================================================
REM  English Brain - genera el APK release y lo deja en el Escritorio.
REM  Doble clic. La copia al Escritorio (incl. OneDrive) la hace build_apk.ps1.
REM ==========================================================================
REM  Configura tu backend aqui, o exporta BASE_URL / API_KEY como variables de
REM  entorno antes de ejecutar (estas lineas respetan lo que ya este definido).
if not defined BASE_URL set "BASE_URL=https://ingles.tudominio.dev"
REM  Alternativa LAN (requiere Caddy arriba):  set "BASE_URL=http://TU_NAS_IP:8092"
if not defined API_KEY set "API_KEY=CHANGE_ME_api_key"

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
