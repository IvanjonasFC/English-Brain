#requires -Version 5.1
<#
.SYNOPSIS
  Builds a release APK of English Brain preconfigured for the self-hosted
  backend and, optionally, installs it on a connected phone via ADB.

.DESCRIPTION
  The APK works over LAN, WireGuard and mobile data. Default backend URL is the
  public HTTPS domain (https://ingles.ivanjonasfc.dev); for LAN-only speed pass
  -BaseUrl http://192.168.0.200:8092.

  NOTE: this produces a PLAIN release APK (not updatable over-the-air). For an
  APK you can patch without reinstalling, use shorebird_release.bat (Shorebird);
  see SHOREBIRD.md.

  Pipeline: sync offline seeds (validates + regenerates the offline fallback)
  -> flutter pub get -> flutter build apk --release, with the backend URL baked
  in via --dart-define.

.PARAMETER BaseUrl
  Backend base URL baked into the APK. Default: https://ingles.ivanjonasfc.dev

.PARAMETER ApiKey
  Optional API key baked in as a fallback (matches API_KEY in docker-compose).
  Content endpoints are public, so this is only needed for user features.

.PARAMETER Install
  Install the built APK on the connected device (adb install -r).

.PARAMETER SkipSync
  Skip the offline-seed sync step.

.EXAMPLE
  .\build_apk.ps1
.EXAMPLE
  .\build_apk.ps1 -Install
.EXAMPLE
  .\build_apk.ps1 -BaseUrl "http://192.168.0.200:8000" -ApiKey "super-secret-key-123" -Install
#>
param(
  [string]$BaseUrl = "https://ingles.ivanjonasfc.dev",
  [string]$ApiKey  = "",
  [switch]$Install,
  [switch]$SkipSync
)

$ErrorActionPreference = "Stop"
$root = $PSScriptRoot
$app  = Join-Path $root "app"

function Need($cmd, $hint) {
  if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) {
    throw "'$cmd' was not found in PATH. $hint"
  }
}

Write-Host "== English Brain - APK build ==" -ForegroundColor Cyan
Write-Host ("Backend URL baked in : {0}" -f $BaseUrl)
Write-Host ("API key baked in     : {0}" -f $(if ($ApiKey) { "(set)" } else { "(none - set later in-app if needed)" }))

Need "flutter" "Install Flutter and add it to PATH."

# 1) Keep the offline fallback (assets + Dart const) in sync with backend seeds.
if (-not $SkipSync) {
  Need "python" "Install Python 3 (needed by tools/sync_offline_seeds.py)."
  Write-Host "`n[1/3] Syncing + validating offline seeds..." -ForegroundColor Yellow
  python (Join-Path $root "tools/sync_offline_seeds.py")
  if ($LASTEXITCODE -ne 0) {
    throw "Seed sync/validation failed (see above). Fix the backend seed JSON before building."
  }
} else {
  Write-Host "`n[1/3] Skipping seed sync (-SkipSync)."
}

Push-Location $app
try {
  Write-Host "`n[2/3] flutter pub get..." -ForegroundColor Yellow
  flutter pub get
  if ($LASTEXITCODE -ne 0) { throw "flutter pub get failed." }

  Write-Host "`n[3/3] flutter build apk --release..." -ForegroundColor Yellow
  $defines = @("--dart-define=BASE_URL=$BaseUrl")
  if ($ApiKey -ne "") { $defines += "--dart-define=API_KEY=$ApiKey" }
  # --no-tree-shake-icons: los iconos de los packs se cargan por codepoint desde
  # JSON (IconData dinamico), no se pueden tree-shakear. Coste: ~1MB de fuente.
  flutter build apk --release --no-tree-shake-icons @defines
  if ($LASTEXITCODE -ne 0) { throw "flutter build apk failed." }
}
finally {
  Pop-Location
}

$apk = Join-Path $app "build/app/outputs/flutter-apk/app-release.apk"
if (-not (Test-Path $apk)) { throw "APK not found at $apk" }
$size = "{0:N1} MB" -f ((Get-Item $apk).Length / 1MB)
Write-Host ("`nAPK ready: {0} ({1})" -f $apk, $size) -ForegroundColor Green

# Copia SIEMPRE al Escritorio (resuelve Escritorio redirigido a OneDrive).
$desktop = [Environment]::GetFolderPath('Desktop')
$dest = Join-Path $desktop 'English_Coach.apk'
Copy-Item $apk $dest -Force
Write-Host ("Copiado al Escritorio: {0}" -f $dest) -ForegroundColor Green

if ($Install) {
  Need "adb" "Install Android platform-tools (adb) and add it to PATH, or copy the APK to the phone manually."
  Write-Host "`nInstalling on the connected device..." -ForegroundColor Yellow
  adb install -r "$apk"
  if ($LASTEXITCODE -ne 0) { throw "adb install failed. Check 'adb devices' and that USB debugging is enabled." }
  Write-Host "Installed." -ForegroundColor Green
}

Write-Host "`nHow to test:" -ForegroundColor Cyan
Write-Host "  - LAN   : phone on the same network as the NAS (192.168.0.200)."
Write-Host "  - Remote: connect the 'Loredo' WireGuard tunnel; it routes 192.168.0.0/24,"
Write-Host "            so the same URL ($BaseUrl) reaches the backend."
Write-Host "  - If the app was configured earlier with another server, change it in"
Write-Host "    Settings (or reinstall) to: $BaseUrl"
Write-Host "  - Airplane mode still shows content: cache-first + bundled offline seeds."
