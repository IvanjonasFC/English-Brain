# ============================================================================
#  Despliegue del backend al NAS (Docker) — robusto e idempotente.
#
#  Flujo por cada fichero:  repo local  ->  NAS (unidad mapeada)  ->  contenedor
#  Así el contenedor SIEMPRE recibe la versión actual del repo local (no depende
#  de que la unidad estuviera al día). Al final: restart del contenedor.
#
#  Config por variables de entorno (o edita los valores por defecto de abajo):
#    NAS_SSH       usuario@host del NAS         (ej. usuario@TU_NAS_IP)
#    NAS_SSH_KEY   ruta a la clave SSH privada
#    NAS_CONTAINER nombre del contenedor Docker del backend
#    NAS_DRIVE     backend en la unidad mapeada (ej. W:\App Ingles\backend)
#    NAS_DOCKER    ruta del backend dentro del NAS (para docker cp)
# ============================================================================
$ErrorActionPreference = 'Stop'

$key       = if ($env:NAS_SSH_KEY)   { $env:NAS_SSH_KEY }   else { Join-Path $env:USERPROFILE '.ssh\id_nas' }
$hostIp    = if ($env:NAS_SSH)       { $env:NAS_SSH }       else { 'usuario@TU_NAS_IP' }
$container = if ($env:NAS_CONTAINER) { $env:NAS_CONTAINER } else { 'english_coach_backend' }
$srcRoot   = Join-Path $PSScriptRoot 'backend'   # repo local (fuente de verdad)
$nasRoot   = if ($env:NAS_DRIVE)     { $env:NAS_DRIVE }     else { 'W:\App Ingles\backend' }  # unidad mapeada
$nasDocker = if ($env:NAS_DOCKER)    { $env:NAS_DOCKER }    else { '/volume1/docker/App Ingles/backend' }  # ruta NAS (docker cp)

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
