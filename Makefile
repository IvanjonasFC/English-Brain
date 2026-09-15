.PHONY: help run-app run-app-web run-app-windows run-backend nas-up nas-down nas-logs nas-ps test test-backend test-app analyze-app sync-api build-release-apk

help:
	@echo "English Brain - Comandos disponibles:"
	@echo "  make run-app          - Levanta la app Flutter en Chrome (Web Preview)"
	@echo "  make run-app-windows  - Levanta la app Flutter en Windows Desktop"
	@echo "  make run-backend      - Inicia el servidor FastAPI en local (puerto 8000)"
	@echo "  make nas-up           - Levanta los contenedores en el NAS (Ollama, Speaches, Backend)"
	@echo "  make nas-down         - Detiene los contenedores del NAS"
	@echo "  make nas-logs         - Muestra los logs en vivo del NAS"
	@echo "  make test             - Ejecuta todos los tests (backend + app)"
	@echo "  make build-release-apk- Compila el APK Android ofuscado tradicional"
	@echo "  make shorebird-patch  - Sincroniza seeds y envía un parche OTA a la app"
	@echo "  make shorebird-release- Compila un nuevo release base parcheable con Shorebird"

run-app:
	cd app && flutter run -d chrome

run-app-web: run-app

run-app-windows:
	cd app && flutter run -d windows

run-backend:
	uvicorn app.main:app --app-dir backend --reload --host 0.0.0.0 --port 8000

nas-up:
	cd nas && docker compose up -d

nas-down:
	cd nas && docker compose down

nas-logs:
	cd nas && docker compose logs -f

nas-ps:
	cd nas && docker compose ps

generate-openapi:
	python -c "import json; import sys; sys.path.insert(0, 'backend'); from app.main import app; open('backend/openapi.json', 'w', encoding='utf-8').write(json.dumps(app.openapi(), indent=2))"

generate-api:
	python scripts/generate_dart_models.py

sync-api: generate-openapi generate-api

test-backend:
	pytest backend/tests -v

test-app:
	cd app && flutter test

test: test-backend test-app

analyze-app:
	cd app && dart analyze .

build-release-apk:
	cd app && flutter build apk --release --obfuscate --split-debug-info=./build/symbols

shorebird-patch:
	cmd /c shorebird_patch.bat

shorebird-release:
	cmd /c shorebird_release.bat

