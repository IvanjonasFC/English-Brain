@echo off
chcp 65001 >nul
title English Brain — Ingestor de Datasets Externos
set SCRIPT_DIR=%~dp0

:menu_ingest
cls
echo ==============================================================================
echo   🌐 ENGLISH BRAIN — INGESTOR AUTOMÁTICO DE DATASETS EXTERNOS
echo ==============================================================================
echo.
echo   [1] 📥 Descargar e Ingestar Muestra del Dataset Abierto CEFR-J
echo   [2] 📄 Ingestar un archivo CSV local de Vocabulario
echo   [3] ↩️ Volver al Menú Principal
echo.
echo ==============================================================================
set /p opt="Selecciona una opción (1-3): "

if "%opt%"=="1" (
    cls
    python "%SCRIPT_DIR%ingestar_fuente_externa.py" --descargar-cefrj
    echo.
    pause
    goto menu_ingest
)
if "%opt%"=="2" (
    cls
    echo Arrastra o escribe la ruta de tu archivo CSV (ej. C:\datos\vocab.csv):
    set /p csvfile="Ruta: "
    set /p packid="ID del Pack (ej. mi_pack): "
    set /p packtitle="Título del Pack: "
    set /p cefrlevel="Nivel CEFR (A1-A2 / B1-B2 / B2-C1 / C1): "
    echo.
    python "%SCRIPT_DIR%ingestar_fuente_externa.py" --tipo vocab_csv --archivo %csvfile% --pack-id %packid% --pack-titulo "%packtitle%" --nivel %cefrlevel%
    echo.
    pause
    goto menu_ingest
)
if "%opt%"=="3" (
    call "%SCRIPT_DIR%MENU_CONTENIDO.bat"
    exit /b 0
)

echo Opción no válida.
pause
goto menu_ingest
