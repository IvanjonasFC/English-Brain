@echo off
REM Lanza los dos workers en ventanas separadas
start "Phoneme wav2vec2 :8100" cmd /k run_phoneme.bat
start "MFA :8200" cmd /k run_mfa.bat
echo Workers lanzados. Comprueba:
echo   http://localhost:8100/health   (device: cuda)
echo   http://localhost:8200/health   (mfa: true)
