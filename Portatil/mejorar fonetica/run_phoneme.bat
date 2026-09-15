@echo off
REM Worker de fonemas (wav2vec2 IPA) en la GPU -> puerto 8100
call conda activate fonetica
echo Iniciando phoneme worker (wav2vec2) en http://0.0.0.0:8100 ...
uvicorn phoneme_server:app --host 0.0.0.0 --port 8100
