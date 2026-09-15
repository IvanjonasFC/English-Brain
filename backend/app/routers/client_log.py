"""Router /api/client-log — recibe errores/eventos del cliente (movil) y los
persiste para depuracion remota (util cuando el PC esta apagado y no hay adb)."""
import logging
from typing import Optional, List, Union

from fastapi import APIRouter, Depends
from pydantic import BaseModel
from sqlalchemy import select, desc
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.models import ClientLog

logger = logging.getLogger("english_brain.client_log")
router = APIRouter(prefix="/client-log", tags=["client-log"])


class ClientLogIn(BaseModel):
    level: str = "error"          # error | warn | info | event
    tag: Optional[str] = None     # p.ej. recording, pronunciation, interview, save
    message: str
    context: Optional[str] = None  # JSON/texto libre (stack, payload)
    platform: Optional[str] = None
    app_version: Optional[str] = None
    user_id: Optional[str] = None


@router.post("")
async def create_client_log(body: Union[ClientLogIn, List[ClientLogIn]], db: AsyncSession = Depends(get_db)):
    items = body if isinstance(body, list) else [body]
    for it in items:
        db.add(ClientLog(
            level=(it.level or "error")[:16], tag=(it.tag or None) and it.tag[:64],
            message=(it.message or "")[:4000], context=(it.context or None) and it.context[:8000],
            platform=(it.platform or None) and it.platform[:32],
            app_version=(it.app_version or None) and it.app_version[:32],
            user_id=(it.user_id or "anon")[:64],
        ))
    try:
        await db.commit()
    except Exception as e:
        await db.rollback()
        logger.warning(f"No se pudo guardar client-log: {e}")
        return {"ok": False}
    return {"ok": True, "count": len(items)}


@router.get("")
async def list_client_logs(limit: int = 50, level: Optional[str] = None, tag: Optional[str] = None,
                           db: AsyncSession = Depends(get_db)):
    q = select(ClientLog).order_by(desc(ClientLog.id)).limit(min(limit, 500))
    if level:
        q = q.where(ClientLog.level == level)
    if tag:
        q = q.where(ClientLog.tag == tag)
    rows = (await db.execute(q)).scalars().all()
    return [{"id": r.id, "ts": r.created_at.isoformat() if r.created_at else None, "level": r.level,
             "tag": r.tag, "message": r.message, "context": r.context, "platform": r.platform,
             "app_version": r.app_version, "user_id": r.user_id} for r in rows]
