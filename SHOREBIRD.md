# Actualizaciones OTA sin reinstalar (Shorebird) + Flujo Offline

Guía de referencia para el sistema de actualizaciones en caliente (**Code Push / OTA**) con **Shorebird** en **English Brain**.

---

## 📌 Estado de la Configuración Activa

| Parámetro | Valor |
|---|---|
| **App ID en Shorebird** | `da1527cf-2245-414f-bffb-0d4a68c3155d` (definido en `app/shorebird.yaml`) |
| **Cuenta vinculada** | `tu-cuenta@ejemplo.com` |
| **Release Base Activa** | `1.0.0+1` (generada y publicada) |
| **APK Parcheable** | `English_Coach.apk` (~80.2 MB, copiado al Escritorio) |
| **Endpoints inyectados** | `BASE_URL=https://ingles.tudominio.dev`, `API_KEY=CHANGE_ME_api_key` |

> [!IMPORTANT]
> **Para recibir actualizaciones OTA**: Debes tener instalado en el móvil el APK parcheable (`English_Coach.apk` generado por Shorebird). Si tenías instalada una versión anterior generada con `flutter build apk` o `build_apk.bat`, desinstálala o instala `English_Coach.apk` encima.

---

## 🚀 Flujo Diario de Trabajo

### Caso 1: Solo añades contenido nuevo al Backend (¡Sin tocar el APK ni Shorebird!)
La app está diseñada con arquitectura **Local-First con revalidación en background**:
1. Editas los JSON en `backend/app/seed/*.json`.
2. Haces rebuild del backend en el NAS / local.
3. Abres la app en el móvil y haces **pull-to-refresh** (deslizar hacia abajo).
4. El contenido nuevo se descarga y queda **cacheado automáticamente en SharedPreferences** para uso offline.

### Caso 2: Cambios de código Dart o refresco de seeds offline empaquetados (OTA)
Cuando modifiques código Flutter (pantallas, lógica, temas) o quieras que la copia base de los assets offline (`app/assets/seed/`) esté al día desde el minuto cero:
1. Ejecuta con doble clic:
   ```cmd
   shorebird_patch.bat
   ```
2. El script realiza dos pasos automáticamente:
   - **Paso 1**: Sincroniza `backend/app/seed/*.json` -> `app/assets/seed/*.json` (`python tools\sync_offline_seeds.py`).
   - **Paso 2**: Envía el parche OTA a los servidores de Shorebird.
3. **En el móvil**: El parche se descarga silenciosamente en segundo plano la próxima vez que se abra la app, y se **aplica automáticamente en el siguiente arranque**.

### Caso 3: Cambios nativos de Android (Requiere nuevo Release)
Solo es necesario generar un nuevo Release e instalar el nuevo APK si:
- Añades o cambias plugins nativos con código Java/Kotlin/C++ en `pubspec.yaml`.
- Modificas permisos o configuraciones en `AndroidManifest.xml`.
- Cambias el icono de la app, el Splash Screen nativo o la versión de Flutter.

Para este caso:
```cmd
shorebird_release.bat
```
Generará el nuevo APK base parcheable, lo publicará en Shorebird y dejará `English_Coach.apk` en el Escritorio para instalarlo en el dispositivo.

---

## 🛠️ Resumen de Scripts Disponibles

| Script | Propósito | Cuándo usarlo |
|---|---|---|
| `shorebird_patch.bat` | Sincroniza seeds offline y publica parche OTA | **Día a día** tras editar código Dart o querer hornear seeds |
| `shorebird_release.bat` | Genera versión base completa y copia APK al Escritorio | Solo al cambiar dependencias nativas o versión mayor |
| `shorebird_setup.bat` | Instalación inicial del CLI, login y doctor | Una sola vez en una máquina nueva |

---

## 🔍 Incidencias Resueltas y Detalles Técnicos

### 1. Wrapper de Windows (`shorebird.bat` vs `shorebird.ps1`)
- **Problema**: En sistemas Windows, el archivo por lotes intermediario `shorebird.bat` descartaba el delimitador `--` necesario para pasar argumentos de compilación a Flutter (`--dart-define`, `--no-tree-shake-icons`).
- **Solución implementada**: Los scripts `.bat` del proyecto llaman directamente a PowerShell ejecutando el script oficial `%USERPROFILE%\.shorebird\bin\shorebird.ps1`.

### 2. Error en compilación "failed to strip debug symbols"
- **Problema**: Al compilar para Android, Shorebird requiere las herramientas de línea de comandos de Android SDK para optimizar los binarios nativos.
- **Solución implementada**: Instalado el componente `cmdline-tools/latest` en el Android SDK.

### 3. Imports faltantes en `profile_screen.dart`
- **Problema**: Faltaban `dart:async` y `package:flutter/services.dart` para operaciones de UI/portapapeles.
- **Solución implementada**: Corregidos en `app/lib/features/profile/profile_screen.dart`. Verificación con `dart analyze .` completada con 0 errores.

---

## 📋 Tabla Resumen: ¿Qué requiere cada cambio?

| Tipo de Cambio | Pull-to-Refresh | `shorebird_patch.bat` (OTA) | `shorebird_release.bat` (Reinstalar) |
|---|:---:|:---:|:---:|
| Contenido en Backend (`seed/*.json`) | ✅ **Inmediato** | Opcional (para offline base) | ❌ |
| Pantallas, Widgets, Temas Dart | ❌ | ✅ **Automático** | ❌ |
| Algoritmos de Pedagogía / FSRS en Dart | ❌ | ✅ **Automático** | ❌ |
| Assets locales / Iconos SVG / Seeds en App | ❌ | ✅ **Automático** | ❌ |
| Nuevos paquetes nativos / Permisos Android | ❌ | ❌ | ✅ **Requerido** |

---

## ℹ️ Comandos Útiles de Diagnóstico

Si necesitas comprobar el estado del entorno o de los parches desde la terminal:
```bash
# Diagnóstico de herramientas Shorebird y Flutter
shorebird doctor

# Ver información de la app y releases registrados
cd app
shorebird info
```
