@echo off
setlocal enabledelayedexpansion
chcp 65001 >NUL
title Chequeo Cluster IA (.65) + Backend NAS
color 0B

set P65=192.168.0.65
set NAS=192.168.0.200:8092

echo ============================================================
echo    CHEQUEO CLUSTER IA  -  portatil .65 + Backend NAS
echo ============================================================
echo.
echo [ Workers nativos GPU en el portatil %P65% ]
echo.

call :check  "LLM  Ollama            (:11434)"  "http://%P65%:11434/api/tags"
call :check  "Speaches STT/TTS Kokoro (:8001)"  "http://%P65%:8001/v1/models"
call :checkup "Worker Fonemas wav2vec2 (:8100)"  "http://%P65%:8100/health"
call :checkup "Worker MFA align        (:8200)"  "http://%P65%:8200/health"

echo.
echo [ Prueba de VOZ real (Kokoro am_michael) ]
for /f %%C in ('curl -s -m 25 -o "%TEMP%\voz65.mp3" -w "%%{http_code}" -X POST http://%P65%:8001/v1/audio/speech -H "Content-Type: application/json" -d "{\"model\":\"speaches-ai/Kokoro-82M-v1.0-ONNX\",\"voice\":\"am_michael\",\"input\":\"hello there, this is a pronunciation test\",\"response_format\":\"mp3\"}"') do set VCODE=%%C
if "!VCODE!"=="200" (
  for %%A in ("%TEMP%\voz65.mp3") do echo   [ OK ] Audio sintetizado: %%~zA bytes   ^(%TEMP%\voz65.mp3^)
) else (
  echo   [FALLO] TTS devolvio HTTP !VCODE!  ^(revisa Speaches en el .65^)
)

echo.
echo [ Backend en el NAS %NAS% ]
call :check "Backend salud   (/api/health)"  "http://%NAS%/api/health"
echo.
echo   Estado LLM segun el backend (ai/status):
curl -s -m 8 http://%NAS%/api/ai/status
echo.

echo.
echo [ Prueba de VOZ a traves del backend (voz de la app) ]
for /f %%C in ('curl -s -m 25 -o "%TEMP%\voz_app.mp3" -w "%%{http_code}" "http://%NAS%/api/tts?text=hello%%20there&voice=am_michael&rate=%%2B0%%25"') do set ACODE=%%C
if "!ACODE!"=="200" (
  for %%A in ("%TEMP%\voz_app.mp3") do echo   [ OK ] Audio de la app: %%~zA bytes
) else (
  echo   [FALLO] TTS backend HTTP !ACODE!
)

echo.
echo ============================================================
echo    Fin del chequeo. Todo debe poner [ OK ].
echo    Puedes escuchar: %TEMP%\voz65.mp3  y  %TEMP%\voz_app.mp3
echo ============================================================
echo.
pause
exit /b

:check
for /f %%C in ('curl -s -m 8 -o NUL -w "%%{http_code}" %~2') do set CODE=%%C
if "!CODE!"=="200" ( echo   [ OK ] %~1 ) else ( echo   [FALLO] %~1  HTTP !CODE! )
exit /b

:checkup
for /f %%C in ('curl -s -m 8 -o NUL -w "%%{http_code}" %~2') do set CODE=%%C
if "!CODE!"=="000" ( echo   [FALLO] %~1  sin respuesta ) else ( echo   [ OK ] %~1  responde ^(HTTP !CODE!^) )
exit /b
