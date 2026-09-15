@echo off
setlocal EnableExtensions
REM ==========================================================================
REM  Shorebird - PUESTA EN MARCHA (una sola vez). Requiere internet y una
REM  cuenta Shorebird (gratis). Empuja cambios de Dart+assets a la app YA
REM  instalada, por internet, SIN reinstalar el APK entero.
REM ==========================================================================
echo [1/4] Instalando Shorebird CLI...
powershell -NoProfile -ExecutionPolicy Bypass -Command "iwr -useb https://raw.githubusercontent.com/shorebirdtech/install/main/install.ps1 | iex"
echo.
echo   Si luego 'shorebird' no se reconoce, CIERRA y reabre esta ventana (PATH).
echo.
echo [2/4] Login (abre el navegador)...
shorebird login
echo [3/4] Diagnostico del entorno...
shorebird doctor
echo [4/4] Inicializando el proyecto (crea app/shorebird.yaml + app id)...
cd /d "%~dp0app"
shorebird init
echo.
echo === Listo ===
echo  1) La PRIMERA vez ejecuta shorebird_release.bat e instala ese APK en el movil.
echo  2) Para cada cambio posterior: shorebird_patch.bat (la app se actualiza sola).
pause
