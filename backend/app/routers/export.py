import os
from fastapi import APIRouter, Depends, HTTPException, BackgroundTasks
from fastapi.responses import FileResponse
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.database import get_db
from app.models import Card, Mistake
from app.services.anki import anki_service
from app.routers.auth import get_current_user

router = APIRouter(prefix="/export", tags=["export"])

def cleanup_file(path: str):
    if os.path.exists(path):
        try:
            os.remove(path)
        except OSError:
            pass

@router.get("/apkg")
async def export_apkg(
    background_tasks: BackgroundTasks,
    db: AsyncSession = Depends(get_db),
    current_user: str = Depends(get_current_user)
):
    # Fetch cards with mistake details
    result = await db.execute(
        select(Card, Mistake).join(Mistake, Card.mistake_id == Mistake.id, isouter=True)
    )
    rows = result.all()

    if not rows:
        # If no cards yet, provide a sample introductory card in the exported deck
        cards_data = [{
            "front": "Tell me about yourself (Opening Hook)",
            "back": "I specialize in backend architecture and mobile systems with Flutter and Python.",
            "category": "Sample"
        }]
    else:
        cards_data = []
        for card, mistake in rows:
            category = mistake.category if mistake else "Vocabulary"
            cards_data.append({
                "front": card.front,
                "back": card.back,
                "category": category
            })

    try:
        file_path = anki_service.generate_apkg(cards_data)
        background_tasks.add_task(cleanup_file, file_path)
        return FileResponse(
            path=file_path,
            filename="EnglishCoach_Interview_Deck.apkg",
            media_type="application/octet-stream"
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to generate Anki package: {str(e)}")

@router.post("/ankiconnect")
async def sync_ankiconnect(
    db: AsyncSession = Depends(get_db),
    current_user: str = Depends(get_current_user)
):
    result = await db.execute(
        select(Card, Mistake).join(Mistake, Card.mistake_id == Mistake.id, isouter=True)
    )
    rows = result.all()
    cards_data = []
    for card, mistake in rows:
        category = mistake.category if mistake else "Vocabulary"
        cards_data.append({
            "front": card.front,
            "back": card.back,
            "category": category
        })

    sync_result = await anki_service.sync_to_ankiconnect(cards_data)
    return sync_result
