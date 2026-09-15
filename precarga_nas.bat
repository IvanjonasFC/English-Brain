@echo off
chcp 65001 >NUL
title Precarga definitiva de audio en el NAS
color 0A
echo ============================================================
echo   PRECARGA DEFINITIVA DE AUDIO EN EL NAS  (voz am_michael)
echo ============================================================
echo.
echo Esto recorre el contenido de la app y pre-genera todo el
echo audio en el NAS con la mejor voz. Puede tardar unos minutos
echo la primera vez (el .65 tiene que estar encendido).
echo.
python "%~dp0precarga_nas.py"
echo.
pause
