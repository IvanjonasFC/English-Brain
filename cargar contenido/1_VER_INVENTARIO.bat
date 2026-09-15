@echo off
chcp 65001 >nul
title English Brain — Inventario de Contenido
set SCRIPT_DIR=%~dp0
python "%SCRIPT_DIR%gestor_contenido.py" --status
echo.
pause
