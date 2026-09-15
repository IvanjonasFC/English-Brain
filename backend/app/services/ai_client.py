"""
Cliente HTTP compartido con Connection Pooling y Semaforo GPU para microservicios de IA.
Evita saturacion de sockets TCP y protege la GPU RTX 2060 contra picos de concurrencia.
"""
import asyncio
import httpx

# Pool de conexiones reutilizables para no saturar sockets TCP
limits = httpx.Limits(max_keepalive_connections=20, max_connections=50)
ai_client = httpx.AsyncClient(
    limits=limits,
    timeout=httpx.Timeout(6.0, connect=1.5),
)

# Semaforo para no saturar la GPU si multiples usuarios envian audios al mismo milisegundo
gpu_semaphore = asyncio.Semaphore(4)  # Maximo 4 peticiones pesadas simultaneas a la RTX 2060
