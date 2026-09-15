# English Brain — AI Interview Coach

Sistema de entrenamiento para entrevistas técnicas en inglés, 100% privado y autoalojado con IA local (Ollama + Speaches), repetición espaciada con la librería oficial `py-fsrs` y frontend Flutter multiplataforma (Android, Web y Desktop).

---

## 📁 Estructura del Proyecto

El repositorio está organizado en 3 bloques independientes y desacoplados:

```
Ingles/
├── backend/            # 1. ORQUESTADOR FASTAPI
│   ├── app/            # Código fuente (Auth JWT, FSRS, LLM, STT/TTS, Logging)
│   ├── tests/          # Suite de tests automáticos (pytest)
│   ├── Dockerfile      # Imagen Docker para el NAS
│   └── requirements.txt# Dependencias pineadas y auditadas
│
├── nas/                # 2. INFRAESTRUCTURA & DESPLIEGUE EN NAS
│   ├── docker-compose.yml # Orquestación Docker (Ollama, Speaches, Backend, Caddy)
│   ├── Caddyfile       # Reverse Proxy con SSL automático y headers de seguridad
│   ├── .env.example    # Plantilla de variables de entorno para producción
│   └── README.md       # Manual paso a paso de despliegue y mantenimiento en NAS
│
├── app/                # 3. CLIENTE FLUTTER (Android, Web & Windows)
│   ├── lib/            # Código fuente Dart (M3 Theme, Riverpod, Drift, GoRouter)
│   ├── android/        # Proyecto Android (Network Security Config LAN/WireGuard)
│   ├── web/            # Soporte Web para previsualización inmediata
│   ├── test/           # Tests de widgets y lógica offline
│   └── pubspec.yaml    # Dependencias de Flutter
│
├── docs/               # Documentación y diagramas Mermaid
├── scripts/            # Generador de modelos Dart desde OpenAPI
└── Makefile            # Atajos rápidos de desarrollo y despliegue
```

---

## 🚀 1. Cómo Levantar la App (Previsualización Visual)

Para ver la aplicación funcionando en pantalla con su diseño **Material 3 (Negro profundo `#000000` + Naranja pastel `#F2A65A`)**, tienes varias opciones:

### Opción A: Web en Google Chrome (La más rápida y directa)
Abre la app al instante en tu navegador sin necesidad de emuladores ni teléfonos conectados:
```bash
cd app
flutter run -d chrome
```
*O usando el atajo:*
```bash
make run-app
```

### Opción B: Windows Desktop Nativo
Ejecuta la app como ventana de escritorio nativa en Windows:
```bash
cd app
flutter run -d windows
```
*O con el atajo:*
```bash
make run-app-windows
```

### Opción C: Emulador Android
Si tienes configurado el emulador de Android Studio:
```bash
flutter emulators --launch Medium_Phone_API_36.1
cd app
flutter run
```

### Opción D: Compilación y Actualizaciones OTA en Móvil (Shorebird)
La aplicación cuenta con soporte de **actualizaciones en caliente (Code Push / OTA)** con Shorebird, lo que permite enviar parches de código y assets sin reinstalar el APK en el móvil:

- **Instalación Inicial en el Móvil:**
  Ejecuta `shorebird_release.bat` para compilar el APK parcheable. El archivo generado se copia automáticamente a tu Escritorio como `English_Coach.apk` (~80 MB).
- **Actualizaciones Posteriores (Sin Reinstalar):**
  Ejecuta `shorebird_patch.bat` (doble clic) tras realizar cambios en Dart o sincronizar seeds. El móvil descarga el parche por internet y lo aplica al reabrir la app.
- Para más información y flujo con el backend, consulta [`SHOREBIRD.md`](SHOREBIRD.md).

### Opción E: Compilación Tradicional Offline (Sin Shorebird)
Si deseas generar un APK independiente clásico sin servicio OTA:
```bash
make build-release-apk
# O directamente:
cd app && flutter build apk --release --obfuscate --split-debug-info=./build/symbols
```
El APK se genera en: `app/build/app/outputs/flutter-apk/app-release.apk`.

---

## ⚙️ 2. Cómo Levantar el Backend (Local)

Para probar la API y los endpoints en tu máquina de desarrollo:

```bash
# 1. Activar entorno virtual
.\.venv\Scripts\activate      # Windows
# source .venv/bin/activate    # Linux / macOS

# 2. Ejecutar tests
pytest backend/tests -v

# 3. Iniciar servidor FastAPI con recarga en vivo
uvicorn app.main:app --app-dir backend --reload --host 0.0.0.0 --port 8000
```
- **Documentación Swagger:** [http://localhost:8000/docs](http://localhost:8000/docs)
- **Health Check & Diagnóstico:** [http://localhost:8000/api/health](http://localhost:8000/api/health)

---

## 🏠 3. Cómo Desplegar en el NAS

Todo lo relativo al servidor NAS está centralizado en la carpeta [`nas/`](nas/):

```bash
# 1. Entrar en la carpeta del NAS
cd nas

# 2. Copiar y configurar el archivo de variables de entorno
cp .env.example .env

# 3. Levantar los contenedores (Ollama + Speaches + Backend)
docker compose up -d

# 4. Descargar el modelo de lenguaje en Ollama (solo la primera vez)
docker compose exec ollama ollama pull qwen2.5:7b

# 5. Comprobar estado de salud
docker compose ps
```

Consulta [`nas/README.md`](nas/README.md) para detalles sobre WireGuard, IPs de LAN y certificados SSL con Caddy.

---

## 📚 4. Índice de Documentación (`docs/`)

| Documento | Descripción |
|---|---|
| [`docs/SHOREBIRD.md`](docs/SHOREBIRD.md) | Guía de actualizaciones en caliente (OTA) con Shorebird y scripts batch |
| [`docs/GUIA_CONTENIDO.md`](docs/GUIA_CONTENIDO.md) | Guía de creación, etiquetado CEFR y sincronización de contenidos |
| [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) | Arquitectura general del sistema, bucle de entrevista y FSRS |
| [`docs/FRONTEND_ARCHITECTURE.md`](docs/FRONTEND_ARCHITECTURE.md) | Arquitectura UI Flutter (M3 Glassmorphism, Riverpod, Drift, Router) |
| [`docs/PEDAGOGY.md`](docs/PEDAGOGY.md) | Motor pedagógico adaptativo, rutas funcionales y FSRS transversal |
| [`docs/NAS_DEPLOYMENT.md`](docs/NAS_DEPLOYMENT.md) | Manual de despliegue en servidor NAS personal con Docker y Caddy |

---

## 🛠️ Comandos Rápidos (`make`)

| Comando | Acción |
|---|---|
| `make run-app` | Levanta la App en Chrome (Web) |
| `make run-app-windows` | Levanta la App en ventana nativa Windows |
| `make run-backend` | Inicia el servidor FastAPI local |
| `make nas-up` | Levanta los contenedores en el NAS |
| `make nas-down` | Detiene los contenedores del NAS |
| `make nas-logs` | Muestra logs en vivo de los contenedores |
| `make test` | Ejecuta todos los tests (backend + app) |
| `make build-release-apk` | Compila el APK Android ofuscado tradicional |
| `make shorebird-patch` | Sincroniza seeds y envía un parche OTA a la app instalada |
| `make shorebird-release` | Compila y publica un nuevo release base parcheable con Shorebird |

