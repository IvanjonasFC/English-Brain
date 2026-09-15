@echo off
chcp 65001 >nul
title English Brain — Gestor de Contenido
set SCRIPT_DIR=%~dp0

:menu
cls
echo ==============================================================================
echo   🎓 ENGLISH BRAIN — PANEL DE GESTIÓN Y CARGA DE CONTENIDO
echo ==============================================================================
echo.
echo   [1] 📊 Ver Inventario Actual (Recuento de temarios por nivel y ventana)
echo   [2] 🔍 Previsualizar Borradores (Valida archivos antes de importarlos)
echo   [3] ⚡ Importar y Sincronizar (Fusiona contenido con Backend, NAS y Offline)
echo   [4] 🌐 Ingestar Datasets Externos (CEFR-J, CSV, Tatoeba, etc.)
echo   [5] 🔄 Solo Sincronizar Offline (Ejecuta sync_offline_seeds)
echo   [6] 📂 Abrir las carpetas de contenido en el explorador
echo   [7] ❌ Salir
echo.
echo ==============================================================================
set /p opt="Selecciona una opción (1-7): "

if "%opt%"=="1" (
    cls
    python "%SCRIPT_DIR%gestor_contenido.py" --status
    echo.
    pause
    goto menu
)
if "%opt%"=="2" (
    cls
    python "%SCRIPT_DIR%gestor_contenido.py" --preview
    echo.
    pause
    goto menu
)
if "%opt%"=="3" (
    cls
    python "%SCRIPT_DIR%gestor_contenido.py" --all
    echo.
    pause
    goto menu
)
if "%opt%"=="4" (
    call "%SCRIPT_DIR%4_INGESTAR_DATASET_EXTERNO.bat"
    goto menu
)
if "%opt%"=="5" (
    cls
    python "%SCRIPT_DIR%gestor_contenido.py" --sync
    echo.
    pause
    goto menu
)
if "%opt%"=="6" (
    explorer "%SCRIPT_DIR%"
    goto menu
)
if "%opt%"=="7" (
    exit /b 0
)

echo Opción no válida.
pause
goto menu
