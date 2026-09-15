from datetime import datetime, timezone
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.database import get_db
from app.models import Card
from app.schemas import CardOut, CardReviewIn, CardIngestIn
from app.services.fsrs_service import fsrs_service
from app.routers.auth import get_current_user

router = APIRouter(prefix="/cards", tags=["cards"])

@router.post("/ingest", response_model=CardOut)
async def ingest_card(
    body: CardIngestIn,
    db: AsyncSession = Depends(get_db),
    current_user: str = Depends(get_current_user)
):
    """Create an FSRS card from any source (vocabulary, grammar, listening, interview)."""
    now = datetime.now(timezone.utc)
    card = Card(
        front=body.front,
        back=body.back,
        state=0,
        difficulty=0.0,
        stability=0.0,
        due_date=now,
        reps=0,
        lapses=0,
        user_id=current_user,
        source_type=body.source_type,
        item_type=body.item_type,
        unit_id=body.unit_or_pack_id,
        skill=body.skill,
    )
    db.add(card)
    await db.commit()
    await db.refresh(card)
    return card

@router.get("", response_model=List[CardOut])
async def list_cards(
    due_only: bool = Query(False, description="Filter only cards due for review now"),
    limit: int = Query(50, ge=1, le=200),
    db: AsyncSession = Depends(get_db),
    current_user: str = Depends(get_current_user)
):
    query = select(Card).where(Card.user_id == current_user).order_by(Card.due_date.asc())
    if due_only:
        now = datetime.now(timezone.utc)
        query = query.where(Card.due_date <= now)

    query = query.limit(limit)
    result = await db.execute(query)
    return result.scalars().all()

@router.post("/{card_id}/review", response_model=CardOut)
async def review_card(
    card_id: int,
    review_in: CardReviewIn,
    db: AsyncSession = Depends(get_db),
    current_user: str = Depends(get_current_user)
):
    res = await db.execute(select(Card).where(Card.id == card_id))
    card = res.scalar_one_or_none()
    if not card:
        raise HTTPException(status_code=404, detail="Card not found")

    # Execute FSRS Spaced Repetition calculation
    fsrs_result = fsrs_service.schedule_review(
        current_state=card.state or 0,
        difficulty=card.difficulty or 0.0,
        stability=card.stability or 0.0,
        reps=card.reps or 0,
        lapses=card.lapses or 0,
        last_review=card.last_review,
        rating=review_in.rating
    )

    card.state = fsrs_result["state"]
    card.difficulty = fsrs_result["difficulty"]
    card.stability = fsrs_result["stability"]
    card.due_date = fsrs_result["due_date"]
    card.reps = fsrs_result["reps"]
    card.lapses = fsrs_result["lapses"]
    card.last_review = fsrs_result["last_review"]

    await db.commit()
    await db.refresh(card)
    return card
