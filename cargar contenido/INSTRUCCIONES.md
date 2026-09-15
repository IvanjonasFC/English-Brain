# 📦 Centro de Carga y Gestión de Contenido — English Brain

Este directorio es tu **mesa de trabajo y control de calidad** para añadir, previsualizar, validar y sincronizar nuevo contenido en la aplicación y en el servidor NAS de forma 100% ordenada y sin riesgo de romper nada.

---

## 📂 Estructura de Carpetas

| Carpeta | Qué va aquí | Formato |
|---------|-------------|---------|
| `01_vocabulario/` | Packs temáticos de palabras (10-15 términos por pack) | JSON / Plantilla |
| `02_gramatica/` | Unidades de gramática con reglas, comparativas y 4 preguntas | JSON / Plantilla |
| `03_inmersion/` | Historias de lectura y listening con audio y preguntas de comprensión | JSON / Plantilla |
| `04_entrevistas/` | Preguntas STAR de entrevista técnica/conductual con respuestas modelo | JSON / Plantilla |

---

## ⚡ Comandos del Gestor de Contenido (`gestor_contenido.py`)

Desde esta carpeta (o desde la raíz del proyecto), puedes ejecutar:

### 1. Ver el Inventario Actual de la App
```powershell
python "cargar contenido\gestor_contenido.py" --status
```
*Muestra un panel visual con el recuento exacto de unidades por ventana, por track (General / Tech) y por nivel CEFR (`A1-A2`, `B1-B2`, `B2-C1`, `C1 Executive`).*

### 2. Previsualizar qué se va a cargar (Sin modificar nada)
```powershell
python "cargar contenido\gestor_contenido.py" --preview
```
*Analiza todos los archivos nuevos colocados en `01_vocabulario`, `02_gramatica`, etc., verifica que cumplan las reglas CEFR y avisa si hay IDs repetidos o campos faltantes.*

### 3. Importar y Sincronizar Todo
```powershell
python "cargar contenido\gestor_contenido.py" --import --sync
```
*Fusiona el nuevo contenido de forma ordenada en `backend/app/seed/`, en `deploy-nas/backend/app/seed/` y actualiza los assets offline de la app.*

---

## 🚀 Despliegue hacia la NAS y la App Móvil

Una vez ejecutado `--import --sync`:

1. **En la NAS (Docker)**:
   El contenido del backend se actualiza reconstruyendo la imagen:
   ```bash
   DOCKER_BUILDKIT=0 docker build --network=host -t english_coach_backend:local ./backend
   docker compose up -d
   ```
   *Cualquier usuario con la app instalada verá el nuevo contenido de inmediato haciendo **pull-to-refresh** (deslizar hacia abajo).*

2. **En la App Móvil (Línea base Offline / Shorebird OTA)**:
   Para que el contenido nuevo también quede grabado en la memoria offline de la app sin reinstalar APK:
   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -Command "& '$env:USERPROFILE\.shorebird\bin\shorebird.ps1' patch android --allow-asset-diffs --release-version=1.0.0+1 '--' --no-tree-shake-icons --dart-define=BASE_URL=https://ingles.ivanjonasfc.dev --dart-define=API_KEY=super-secret-key-123"
   ```

---

## 🎯 Regla de Oro para el Nivel CEFR
Usa SIEMPRE una de las 4 bandas exactas en el campo de nivel:
- `A1-A2` (Junior / Foundations)
- `B1-B2` (Mid / Systems)
- `B2-C1` (Senior / Architecture)
- `C1` (Strategic / Staff / Executive)
