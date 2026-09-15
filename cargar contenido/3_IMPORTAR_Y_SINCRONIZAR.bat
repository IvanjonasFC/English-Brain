@echo off
chcp 65001 >nul
title English Brain — Importar y Sincronizar
set SCRIPT_DIR=%~dp0
python "%SCRIPT_DIR%gestor_contenido.py" --all
echo.
pause
