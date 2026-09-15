# Seguridad

> Estado: pendiente

## Secretos
Donde viven (gestor de credenciales / .env ignorado). Nunca en Git, Vault
compartido ni logs.

## Autenticacion / autorizacion
Como se protege el acceso.

## Amenazas
Modelo de amenazas resumido.

## Limites de la IA
La IA local solo escribe en las rutas de project-ai.json > safety.localAiCanWrite.
Prohibido: leer .env/secretos, commit/push/deploy automaticos, operaciones destructivas.
