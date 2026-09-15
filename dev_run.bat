@echo off
REM ============================================================
REM  English Brain - Desarrollo con HOT RELOAD (sin reinstalar)
REM  Los cambios de codigo Dart se aplican al instante.
REM  Requisitos: movil con Depuracion USB activada, conectado
REM  por USB (o wireless: adb tcpip 5555 && adb connect IP:5555).
REM  Teclas: r = hot reload, R = restart, q = salir.
REM ============================================================
cd /d "%~dp0app"
echo Dispositivos detectados:
flutter devices
echo.
echo Iniciando en modo hot-reload contra el backend HTTPS...
flutter run --dart-define=BASE_URL=https://ingles.ivanjonasfc.dev --dart-define=API_KEY=super-secret-key-123
pause
