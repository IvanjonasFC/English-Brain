from typing import List, Optional
from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.database import get_db
from app.models import Mistake
from app.schemas import MistakeOut
from app.routers.auth import get_current_user

router = APIRouter(prefix="/mistakes", tags=["mistakes"])

@router.get("", response_model=List[MistakeOut])
async def list_mistakes(
    group: Optional[str] = Query(None, description="Filter by category (grammar, vocabulary, pronunciation)"),
    db: AsyncSession = Depends(get_db),
    current_user: str = Depends(get_current_user)
):
    query = select(Mistake).order_by(Mistake.timestamp.desc())
    if group:
        query = query.where(Mistake.category == group.lower())

    result = await db.execute(query)
    return result.scalars().all()
