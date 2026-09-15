#!/usr/bin/env bash
# ==============================================================================
# English Brain - Obfuscated Production Release Build Script
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
APP_DIR="$ROOT_DIR/app"
SYMBOLS_DIR="$APP_DIR/build/symbols"

echo "==> Preparing build environment for obfuscated release APK..."
mkdir -p "$SYMBOLS_DIR"

cd "$APP_DIR"

echo "==> Running Flutter Release Build (with obfuscation and split debug info)..."
flutter build apk --release \
  --obfuscate \
  --split-debug-info="$SYMBOLS_DIR"

echo "=============================================================================="
echo " BUILD SUCCESSFUL!"
echo " APK output:     app/build/app/outputs/flutter-apk/app-release.apk"
echo " Crash symbols:  app/build/symbols/"
echo ""
echo " IMPORTANT: Archive 'app/build/symbols/' alongside the APK for each release."
echo " To de-obfuscate a crash stack trace:"
echo " flutter symbolize -i <crash_stack.txt> -d app/build/symbols/arm64-v8a"
echo "=============================================================================="
