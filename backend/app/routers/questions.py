from typing import List, Optional
from fastapi import APIRouter, Depends, Query, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.database import get_db
from app.models import Question
from app.schemas import QuestionOut
from app.routers.auth import get_current_user

router = APIRouter(prefix="/questions", tags=["questions"])

CATEGORY_ALIASES = {
    "general": "hr",
    "daily": "teamwork",
    "workplace": "portfolio",
    "tech": "technical",
    "systems_design": "system_design",
    "systemsdesign": "system_design",
    "ai": "ai_ml",
    "aiml": "ai_ml",
    "cloud": "cloud_arch",
    "cloudarch": "cloud_arch",
}

DIFFICULTY_ALIASES = {
    "strategic": "senior",
    "staff": "senior",
    "lead": "senior",
    "entry": "junior",
}

@router.get("", response_model=List[QuestionOut])
async def list_questions(
    category: Optional[str] = Query(None, description="Filter by category (hr, tech, vocab)"),
    difficulty: Optional[str] = Query(None, description="Filter by difficulty (junior, mid, senior)"),
    db: AsyncSession = Depends(get_db),
    current_user: str = Depends(get_current_user)
):
    norm_cat = None
    if category:
        c_low = category.lower().strip()
        norm_cat = CATEGORY_ALIASES.get(c_low, c_low)

    norm_diff = None
    if difficulty:
        d_low = difficulty.lower().strip()
        norm_diff = DIFFICULTY_ALIASES.get(d_low, d_low)

    query = select(Question)
    if norm_cat:
        query = query.where(Question.category == norm_cat)
    if norm_diff:
        query = query.where(Question.difficulty == norm_diff)

    result = await db.execute(query)
    questions = result.scalars().all()

    # Si no hay resultados con la dificultad exacta, intentar solo por categoría
    if not questions and norm_cat:
        fallback_query = select(Question).where(Question.category == norm_cat)
        result = await db.execute(fallback_query)
        questions = result.scalars().all()

    # Si la categoría no existe, devolver todas las preguntas
    if not questions:
        all_query = select(Question)
        result = await db.execute(all_query)
        questions = result.scalars().all()

    return questions

@router.get("/{question_id}", response_model=QuestionOut)
async def get_question(
    question_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: str = Depends(get_current_user)
):
    query = select(Question).where(Question.id == question_id)
    result = await db.execute(query)
    q = result.scalar_one_or_none()
    if not q:
        raise HTTPException(status_code=404, detail="Question not found")
    return q
