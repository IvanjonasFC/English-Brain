# Actualizaciones OTA sin reinstalar (Shorebird) + Flujo Offline

Guía de referencia para el sistema de actualizaciones en caliente (**Code Push / OTA**) con **Shorebird** en **English Brain**.

Todos los comandos usan el CLI oficial `shorebird`. El `BASE_URL` y el `API_KEY`
se inyectan con `--dart-define`; expórtalos como variables de entorno o pásalos
en línea (usa **tus** valores reales, nunca los subas al repo).

---

## 📌 Estado de la configuración

| Parámetro | Valor |
|---|---|
| **App ID en Shorebird** | definido en `app/shorebird.yaml` |
| **Cuenta vinculada** | tu cuenta de Shorebird |
| **Release base** | la que publiques con `shorebird release` |
| **Endpoints inyectados** | `BASE_URL` + `API_KEY` vía `--dart-define` (placeholders en el repo) |

> [!IMPORTANT]
> **Para recibir actualizaciones OTA** el móvil debe tener instalado el APK
> **parcheable** generado por `shorebird release`. Si tenías una versión hecha
> con `flutter build apk`, desinstálala o instala el APK de Shorebird encima.

---

## 🚀 Flujo diario de trabajo

### Caso 1: Solo añades contenido nuevo al backend (sin tocar el APK ni Shorebird)
La app usa arquitectura **local-first con revalidación en background**:
1. Editas los JSON en `backend/app/seed/*.json`.
2. Rebuild del backend (NAS o local).
3. En el móvil, **pull-to-refresh** (deslizar hacia abajo).
4. El contenido nuevo se descarga y queda **cacheado** para uso offline.

### Caso 2: Cambios de código Dart o refresco de seeds offline empaquetados (OTA)
Cuando cambies código Flutter (pantallas, lógica, temas) o quieras hornear la
copia base de los assets offline (`app/assets/seed/`):

```bash
# 1) Sincroniza los seeds offline (backend -> assets)
python tools/sync_offline_seeds.py

# 2) Publica el parche OTA
cd app
shorebird patch android -- --no-tree-shake-icons \
  --dart-define=BASE_URL="$BASE_URL" --dart-define=API_KEY="$API_KEY"
```

O con el atajo del Makefile (desde la raíz): `make shorebird-patch`.

El parche se descarga en segundo plano y se **aplica en el siguiente arranque**
de la app.

### Caso 3: Cambios nativos de Android (requiere nuevo release)
Solo hace falta un nuevo release + reinstalar el APK si:
- Añades/cambias plugins nativos con código Java/Kotlin/C++.
- Modificas permisos o `AndroidManifest.xml`.
- Cambias el icono, el splash nativo o la versión de Flutter.

```bash
python tools/sync_offline_seeds.py
cd app
shorebird release android --artifact apk -- --no-tree-shake-icons \
  --dart-define=BASE_URL="$BASE_URL" --dart-define=API_KEY="$API_KEY"
```

O con el atajo: `make shorebird-release`. Instala ese APK en el móvil **una vez**;
después actualiza con `shorebird patch`.

> [!NOTE]
> En Windows, si el wrapper `shorebird.bat` descarta el delimitador `--`, llama
> directamente al script de PowerShell:
> `& "$env:USERPROFILE\.shorebird\bin\shorebird.ps1" patch android '--' ...`.

---

## 📋 ¿Qué requiere cada cambio?

| Tipo de cambio | Pull-to-Refresh | `shorebird patch` (OTA) | `shorebird release` (reinstalar) |
|---|:---:|:---:|:---:|
| Contenido en backend (`seed/*.json`) | ✅ **Inmediato** | Opcional (para offline base) | ❌ |
| Pantallas, widgets, temas Dart | ❌ | ✅ **Automático** | ❌ |
| Algoritmos de pedagogía / FSRS en Dart | ❌ | ✅ **Automático** | ❌ |
| Assets locales / iconos / seeds en la app | ❌ | ✅ **Automático** | ❌ |
| Nuevos paquetes nativos / permisos Android | ❌ | ❌ | ✅ **Requerido** |

---

## ℹ️ Comandos útiles de diagnóstico

```bash
# Puesta en marcha en una máquina nueva (una sola vez)
shorebird login
shorebird doctor

# Diagnóstico e info de la app / releases
cd app
shorebird doctor
shorebird info
```

### Notas técnicas
- **"failed to strip debug symbols"**: Shorebird necesita las command-line tools
  del Android SDK; instala el componente `cmdline-tools/latest`.
- **`--no-tree-shake-icons`** es necesario porque los iconos de los packs se
  cargan por codepoint (IconData dinámico) y no se pueden tree-shakear.
