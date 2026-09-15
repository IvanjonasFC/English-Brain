@echo off
chcp 65001 >nul
title English Brain — Previsualizar Contenido
set SCRIPT_DIR=%~dp0
python "%SCRIPT_DIR%gestor_contenido.py" --preview
echo.
pause
