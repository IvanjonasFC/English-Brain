"""Status and registration for the optional GPU worker."""
from fastapi import APIRouter, Depends

from app.schemas import WorkerRegisterIn
from app.services.worker_health import worker_health
from app.routers.auth import get_current_user

router = APIRouter(prefix="/worker", tags=["worker"])


@router.get("/status")
async def worker_status():
    """Current availability of the GPU accelerator (fast vs standard engine)."""
    return await worker_health.status()


@router.post("/register")
async def worker_register(body: WorkerRegisterIn):
    """Called by the GPU worker on startup so the NAS knows it is available."""
    worker_health.register(body.url)
    return {"ok": True, "registered_url": body.url}
