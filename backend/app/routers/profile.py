from datetime import datetime, timezone, timedelta
import json
import hashlib
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, Body
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
from app.database import get_db
from app.models import (
    UserProfile, UserAchievement, UserDailyActivity,
    Session, Turn, Mistake, Card
)
from app.schemas import (
    UserProfileOut, UserProfileIn, SkillScoresOut,
    AchievementOut, DailyActivityOut, ProfileSummaryOut
)
from app.routers.auth import get_current_user

router = APIRouter(prefix="/api/profile", tags=["profile"])

DEFAULT_ACHIEVEMENTS = [
    {
        "badge_key": "first_interview",
        "title": "Primer Paso STAR",
        "description": "Completaste tu primera respuesta en mock interview",
        "icon_name": "mic",
        "category": "interview",
        "progress": 1.0,
        "is_unlocked": True,
    },
    {
        "badge_key": "streak_7",
        "title": "Racha de Fuego",
        "description": "Mantén 7 días consecutivos de práctica activa",
        "icon_name": "local_fire_department",
        "category": "streak",
        "progress": 0.71,
        "is_unlocked": False,
    },
    {
        "badge_key": "fsrs_veteran",
        "title": "Maestro de la Memoria",
        "description": "50 repasos espaciados con algoritmo FSRS",
        "icon_name": "style",
        "category": "fsrs",
        "progress": 0.44,
        "is_unlocked": False,
    },
    {
        "badge_key": "grammar_ace",
        "title": "Arquitecto Gramatical",
        "description": "Supera 10 lecciones de gramática sin errores mayores",
        "icon_name": "spellcheck",
        "category": "grammar",
        "progress": 0.60,
        "is_unlocked": False,
    },
    {
        "badge_key": "vocab_master",
        "title": "Léxico de Producción",
        "description": "Domina 100 términos técnicos en tu mazo activo",
        "icon_name": "auto_stories",
        "category": "vocab",
        "progress": 0.52,
        "is_unlocked": False,
    },
    {
        "badge_key": "speech_clarity",
        "title": "Claridad Técnica 90+",
        "description": "Obtén un 90%+ en fonética y fluidez en una sesión",
        "icon_name": "record_voice_over",
        "category": "speaking",
        "progress": 0.92,
        "is_unlocked": True,
    },
]

async def ensure_default_users(db: AsyncSession):
    """Seed initial user Ivan at 0 progress if not present."""
    existing = await db.execute(select(UserProfile).where(UserProfile.id == "user-ivan"))
    if existing.scalars().first():
        return

    now = datetime.now(timezone.utc)
    ivan = UserProfile(
        id="user-ivan",
        display_name="Iván",
        email="ivan@dev.local",
        avatar_url="https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&auto=format&fit=crop&q=80",
        target_level="B2",
        role_title="Senior Tech & Cloud Engineer",
        learning_goal="interview_prep",
        daily_goal_minutes=20,
        total_xp=0,
        streak_days=0,
        last_active_date=None,
        created_at=now,
    )
    db.add(ivan)
    
    # Add achievements at 0 progress
    for ach in DEFAULT_ACHIEVEMENTS:
        db.add(UserAchievement(
            user_id="user-ivan",
            badge_key=ach["badge_key"],
            title=ach["title"],
            description=ach["description"],
            icon_name=ach["icon_name"],
            category=ach["category"],
            progress=0.0,
            is_unlocked=False,
            unlocked_at=None,
        ))

    await db.commit()


@router.post("/reset")
async def reset_user_progress(
    user_id: Optional[str] = Query(None),
    db: AsyncSession = Depends(get_db)
):
    """Reset user progress (XP, streaks, daily activities, achievements) to fresh zero start."""
    target_id = user_id or "user-ivan"
    user_res = await db.execute(select(UserProfile).where(UserProfile.id == target_id))
    user = user_res.scalar_one_or_none()
    if user:
        user.total_xp = 0
        user.streak_days = 0
        user.last_active_date = None
        db.add(user)

    # Delete all daily activities
    await db.execute(
        UserDailyActivity.__table__.delete().where(UserDailyActivity.user_id == target_id)
    )

    # Reset achievements
    ach_res = await db.execute(select(UserAchievement).where(UserAchievement.user_id == target_id))
    for ach in ach_res.scalars().all():
        ach.progress = 0.0
        ach.is_unlocked = False
        ach.unlocked_at = None
        db.add(ach)

    await db.commit()
    return {"status": "ok", "message": f"User {target_id} progress reset to zero successfully"}


@router.get("/users", response_model=List[UserProfileOut])
async def list_users(db: AsyncSession = Depends(get_db)):
    await ensure_default_users(db)
    res = await db.execute(select(UserProfile).order_by(UserProfile.created_at.asc()))
    users = list(res.scalars().all())
    # Sincronizar XP real computado de actividad / turnos para cada perfil
    updated = False
    for u in users:
        turns_cnt = (await db.execute(
            select(func.count(Turn.id))
            .join(Session, Turn.session_id == Session.id)
            .where(Session.user_id == u.id)
        )).scalar() or 0
        cards_cnt = (await db.execute(select(func.count(Card.id)).where(Card.user_id == u.id))).scalar() or 0
        act_res = await db.execute(
            select(UserDailyActivity).where(UserDailyActivity.user_id == u.id)
        )
        total_act_xp = sum(a.xp_earned for a in act_res.scalars().all())
        computed_xp = max(u.total_xp or 0, (turns_cnt * 20) + (cards_cnt * 10) + total_act_xp)
        if computed_xp > (u.total_xp or 0):
            u.total_xp = computed_xp
            db.add(u)
            updated = True
    if updated:
        try:
            await db.commit()
        except Exception:
            await db.rollback()
    return users


@router.post("/users", response_model=UserProfileOut)
async def create_user(
    body: UserProfileIn,
    db: AsyncSession = Depends(get_db)
):
    now = datetime.now(timezone.utc)
    user_id = body.id or f"user-{body.display_name.lower().replace(' ', '-')}"
    
    existing = await db.execute(select(UserProfile).where(UserProfile.id == user_id))
    if existing.scalar_one_or_none():
        raise HTTPException(status_code=400, detail="User already exists")

    new_user = UserProfile(
        id=user_id,
        display_name=body.display_name,
        avatar_url=body.avatar_url,
        target_level=body.target_level,
        role_title=body.role_title,
        learning_goal=body.learning_goal,
        daily_goal_minutes=body.daily_goal_minutes,
        total_xp=0,
        streak_days=0,
        pin_hash=hashlib.sha256(body.pin.strip().encode()).hexdigest() if body.pin else None,
        last_active_date=now,
        created_at=now,
    )
    db.add(new_user)
    
    for ach in DEFAULT_ACHIEVEMENTS:
        db.add(UserAchievement(
            user_id=new_user.id,
            badge_key=ach["badge_key"],
            title=ach["title"],
            description=ach["description"],
            icon_name=ach["icon_name"],
            category=ach["category"],
            progress=0.0,
            is_unlocked=False,
            unlocked_at=None,
        ))

    await db.commit()
    await db.refresh(new_user)
    return new_user


@router.post("/users/{user_id}/pin")
async def set_user_pin(
    user_id: str,
    body: dict = Body(...),
    db: AsyncSession = Depends(get_db)
):
    """Establece o actualiza el PIN de acceso de un perfil en el servidor."""
    pin = str(body.get("pin", "")).strip()
    if len(pin) < 4:
        raise HTTPException(status_code=400, detail="El PIN debe tener al menos 4 dígitos")
    user = (await db.execute(select(UserProfile).where(UserProfile.id == user_id))).scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")
    user.pin_hash = hashlib.sha256(pin.encode()).hexdigest()
    db.add(user)
    await db.commit()
    return {"status": "ok", "has_pin": True}


@router.post("/users/{user_id}/verify-pin")
async def verify_user_pin(
    user_id: str,
    body: dict = Body(...),
    db: AsyncSession = Depends(get_db)
):
    """Verifica si el PIN introducido coincide con el configurado en el servidor."""
    pin = str(body.get("pin", "")).strip()
    user = (await db.execute(select(UserProfile).where(UserProfile.id == user_id))).scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")
    if not user.pin_hash:
        return {"valid": False, "has_pin": False}
    is_valid = (user.pin_hash == hashlib.sha256(pin.encode()).hexdigest())
    return {"valid": is_valid, "has_pin": True}


@router.get("/summary", response_model=ProfileSummaryOut)
async def get_profile_summary(
    user_id: Optional[str] = Query(None, description="Target user ID"),
    db: AsyncSession = Depends(get_db),
    current_auth_user: str = Depends(get_current_user)
):
    await ensure_default_users(db)
    target_id = user_id or "user-ivan"

    # 1. Fetch user
    user_res = await db.execute(select(UserProfile).where(UserProfile.id == target_id))
    user = user_res.scalar_one_or_none()
    if not user:
        fallback_res = await db.execute(select(UserProfile).order_by(UserProfile.created_at.asc()))
        user = fallback_res.scalars().first()
        if not user:
            raise HTTPException(status_code=404, detail="No user profile found")
        target_id = user.id

    now = datetime.now(timezone.utc)
    today_start = datetime(now.year, now.month, now.day, tzinfo=timezone.utc)

    # 2. Query actual turns, sessions, and cards for this user
    user_sessions_count = (await db.execute(
        select(func.count(Session.id)).where(Session.user_id == target_id)
    )).scalar() or 0

    user_turns_count = (await db.execute(
        select(func.count(Turn.id))
        .join(Session, Turn.session_id == Session.id)
        .where(Session.user_id == target_id)
    )).scalar() or 0

    user_mistakes_count = (await db.execute(
        select(func.count(Mistake.id))
        .join(Turn, Mistake.turn_id == Turn.id)
        .join(Session, Turn.session_id == Session.id)
        .where(Session.user_id == target_id)
    )).scalar() or 0

    user_cards_count = (await db.execute(select(func.count(Card.id)))).scalar() or 0

    # 3. Sum daily activities
    act_res = await db.execute(
        select(UserDailyActivity)
        .where(UserDailyActivity.user_id == target_id)
        .order_by(UserDailyActivity.activity_date.desc())
        .limit(30)
    )
    activities_30d = act_res.scalars().all()

    total_activity_xp = sum(a.xp_earned for a in activities_30d)
    total_activity_mins = sum(a.minutes_spent for a in activities_30d)
    
    computed_xp = (user_turns_count * 20) + (user_cards_count * 10) + total_activity_xp
    if computed_xp < (user.total_xp or 0):
        computed_xp = user.total_xp or 0
    elif computed_xp > (user.total_xp or 0):
        user.total_xp = computed_xp
        db.add(user)
        try:
            await db.commit()
        except Exception:
            await db.rollback()

    # 4. Weekly activity & XP
    weekly_activity = []
    weekly_xp = 0
    for i in range(6, -1, -1):
        day_date = today_start - timedelta(days=i)
        day_str = day_date.strftime("%Y-%m-%d")
        act_entry = next((a for a in activities_30d if a.activity_date == day_str), None)
        turns = act_entry.sessions_count if act_entry else 0
        day_xp = act_entry.xp_earned if act_entry else 0
        weekly_xp += day_xp
        weekly_activity.append({
            "date": day_str,
            "day": day_date.strftime("%a"),
            "turns": turns,
            "xp": day_xp,
            "minutes": act_entry.minutes_spent if act_entry else 0,
        })

    # 5. Skills computation (grounded in actual data, 0 baseline)
    grammar_score = max(0, min(100, 85 - (user_mistakes_count * 2))) if user_turns_count > 0 or user_mistakes_count > 0 else 0
    vocab_score = max(0, min(100, (user_cards_count * 2))) if user_cards_count > 0 else 0
    speaking_score = 80 if user_turns_count > 0 else 0
    listening_score = 80 if user_turns_count > 0 else 0

    skills = SkillScoresOut(
        grammar_score=grammar_score,
        vocabulary_score=vocab_score,
        listening_score=listening_score,
        speaking_score=speaking_score,
        grammar_level=user.target_level,
        vocabulary_level=user.target_level,
        listening_level="B2",
        speaking_level=user.target_level,
    )

    # 6. Achievements
    ach_res = await db.execute(
        select(UserAchievement)
        .where(UserAchievement.user_id == target_id)
        .order_by(UserAchievement.is_unlocked.desc(), UserAchievement.progress.desc())
    )
    achievements = [AchievementOut.model_validate(a) for a in ach_res.scalars().all()]

    # 7. Format 30d activity
    daily_items = [
        DailyActivityOut(
            date=a.activity_date,
            xp_earned=a.xp_earned,
            minutes_spent=a.minutes_spent,
            sessions_count=a.sessions_count,
            words_practiced=a.words_practiced,
            grammar_drills_count=a.grammar_drills_count,
        )
        for a in reversed(activities_30d)
    ]

    return ProfileSummaryOut(
        profile=UserProfileOut.model_validate(user),
        total_xp=computed_xp,
        weekly_xp=weekly_xp,
        streak_days=user.streak_days,
        total_minutes=total_activity_mins,
        total_sessions=user_sessions_count,
        completed_units=0,
        mastered_words=user_cards_count,
        speaking_clarity_score=speaking_score,
        listening_score=listening_score,
        skills=skills,
        achievements=achievements,
        activity_30d=daily_items,
        weekly_activity=weekly_activity,
        sync_status="synced",
    )


@router.get("/skills", response_model=SkillScoresOut)
async def get_skills(
    user_id: Optional[str] = Query(None),
    db: AsyncSession = Depends(get_db)
):
    summary = await get_profile_summary(user_id=user_id, db=db, current_auth_user="dev_user")
    return summary.skills


@router.get("/achievements", response_model=List[AchievementOut])
async def get_achievements(
    user_id: Optional[str] = Query(None),
    db: AsyncSession = Depends(get_db)
):
    summary = await get_profile_summary(user_id=user_id, db=db, current_auth_user="dev_user")
    return summary.achievements


@router.get("/activity", response_model=List[DailyActivityOut])
async def get_activity(
    user_id: Optional[str] = Query(None),
    db: AsyncSession = Depends(get_db)
):
    summary = await get_profile_summary(user_id=user_id, db=db, current_auth_user="dev_user")
    return summary.activity_30d
