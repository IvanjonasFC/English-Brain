# CLAUDE.md - App Ingles

Sistema de aprendizaje de ingles con frontend Flutter y backend FastAPI/Python en NAS.

## Arquitectura y Rutas Clave
- **Frontend / App Movil (Flutter):** `C:\Users\IvN\Desktop\Ingles\app`
- **Backend (Desarrollo local):** `C:\Users\IvN\Desktop\Ingles\backend`
- **Backend en Vivo (NAS):** `W:\App Ingles\backend`
- **Infraestructura NAS (Docker, Caddy):** `W:\App Ingles` y `C:\Users\IvN\Desktop\Ingles\deploy-nas`

## Reglas de Ejecucion y Permisos
- Tienes **PERMISOS TOTALES** para leer, crear, modificar y ajustar archivos tanto en `C:\Users\IvN\Desktop\Ingles` como en `W:\App Ingles`.
- Si se te pide modificar o corregir el backend, puedes editar directamente en `W:\App Ingles\backend` o en la copia local y sincronizar.
- Todas las operaciones de IA se registran y coordinan con el orquestador local Ollama y `project-ops`.
