@echo off
REM Worker MFA (alineacion forzada) -> puerto 8200
call conda activate fonetica
echo Iniciando MFA worker en http://0.0.0.0:8200 ...
uvicorn mfa_server:app --host 0.0.0.0 --port 8200
