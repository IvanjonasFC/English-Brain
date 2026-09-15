# ============================================================================
#  Despliegue del backend al NAS (Docker) — robusto e idempotente.
#
#  Flujo por cada fichero:  repo local C:  ->  NAS (W:\App Ingles)  ->  contenedor
#  Así el contenedor SIEMPRE recibe la versión actual del repo local (no depende
#  de que W: estuviera al día). Al final: restart del contenedor.
#
#  Requisitos: clave SSH en %USERPROFILE%\.ssh\lifeos_nas y W: mapeado al NAS.
# ============================================================================
$ErrorActionPreference = 'Stop'

$key       = Join-Path $env:USERPROFILE '.ssh\lifeos_nas'
$hostIp    = 'vagabond@192.168.0.200'
$container = 'english_coach_backend'
$srcRoot   = 'C:\Users\IvN\Desktop\Ingles\backend'   # repo local (fuente de verdad)
$nasRoot   = 'W:\App Ingles\backend'                 # despliegue NAS (mapeado)
$nasDocker = '/volume1/docker/App Ingles/backend'    # ruta del NAS (para docker cp)

# Ficheros a desplegar (rutas relativas bajo backend/). Añade aquí lo que toques.
$files = @(
    'app/routers/ai.py',                 # <- streaming Free Talk (endpoint SSE)
    'app/providers/ollama_provider.py',  # <- streaming Free Talk (chat_stream)
    'app/services/llm.py',
    'app/services/tts.py',
    'app/routers/pronunciation.py'
)

foreach ($rel in $files) {
    $src = Join-Path $srcRoot ($rel -replace '/', '\')
    $dst = Join-Path $nasRoot ($rel -replace '/', '\')
    if (-not (Test-Path -LiteralPath $src)) {
        Write-Host "  [SKIP]  no existe en el repo local: $rel" -ForegroundColor Yellow
        continue
    }
    # 1) Copia repo local -> NAS (W:)
    Copy-Item -LiteralPath $src -Destination $dst -Force
    # 2) docker cp NAS -> contenedor  (comando remoto entre comillas para respetar el espacio de 'App Ingles')
    $remote = "/usr/local/bin/docker cp '$nasDocker/$rel' '${container}:/app/$rel'"
    ssh -i $key $hostIp $remote
    Write-Host "  [OK]    $rel  (C: -> NAS -> contenedor)" -ForegroundColor Green
}

# 3) Reinicio del backend para cargar el código nuevo
ssh -i $key $hostIp "/usr/local/bin/docker restart $container"
Write-Host ""
Write-Host "Despliegue y reinicio completado en el NAS." -ForegroundColor Cyan
Write-Host "Verifica con chequeo_65.bat -> /api/ai/status debe responder." -ForegroundColor Cyan
