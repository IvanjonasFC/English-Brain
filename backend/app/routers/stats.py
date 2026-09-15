from datetime import datetime, timezone, timedelta
from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
from app.database import get_db
from app.models import Session, Turn, Mistake, Card
from app.schemas import StatsOut, WeeklyReportOut
from app.routers.auth import get_current_user

router = APIRouter(prefix="/stats", tags=["stats"])

@router.get("", response_model=StatsOut)
async def get_stats(
    db: AsyncSession = Depends(get_db),
    current_user: str = Depends(get_current_user)
):
    now = datetime.now(timezone.utc)
    today_start = datetime(now.year, now.month, now.day, tzinfo=timezone.utc)

    # 1. Counts
    total_sessions = (await db.execute(select(func.count(Session.id)))).scalar() or 0
    total_turns = (await db.execute(select(func.count(Turn.id)))).scalar() or 0
    total_mistakes = (await db.execute(select(func.count(Mistake.id)))).scalar() or 0
    total_cards = (await db.execute(select(func.count(Card.id)))).scalar() or 0

    cards_due_today = (await db.execute(
        select(func.count(Card.id)).where(Card.due_date <= now)
    )).scalar() or 0

    # 2. Mistakes by category
    cat_res = await db.execute(
        select(Mistake.category, func.count(Mistake.id)).group_by(Mistake.category)
    )
    mistakes_by_category = {row[0]: row[1] for row in cat_res.all()}
    if not mistakes_by_category:
        mistakes_by_category = {"grammar": 0, "vocabulary": 0, "pronunciation": 0}

    # 3. Weekly activity (past 7 days)
    weekly_activity = []
    for i in range(6, -1, -1):
        day_date = (today_start - timedelta(days=i))
        next_day = day_date + timedelta(days=1)
        
        turn_count = (await db.execute(
            select(func.count(Turn.id)).where(Turn.created_at >= day_date, Turn.created_at < next_day)
        )).scalar() or 0

        weekly_activity.append({
            "date": day_date.strftime("%Y-%m-%d"),
            "day": day_date.strftime("%a"),
            "turns": turn_count
        })

    # 4. Streak calculation (consecutive active days up to today)
    streak_days = 0
    check_date = today_start
    while True:
        next_date = check_date + timedelta(days=1)
        count = (await db.execute(
            select(func.count(Turn.id)).where(Turn.created_at >= check_date, Turn.created_at < next_date)
        )).scalar() or 0
        if count > 0:
            streak_days += 1
            check_date -= timedelta(days=1)
        else:
            if check_date == today_start:
                # User might not have practiced yet today, check yesterday
                check_date -= timedelta(days=1)
                yesterday_next = check_date + timedelta(days=1)
                y_count = (await db.execute(
                    select(func.count(Turn.id)).where(Turn.created_at >= check_date, Turn.created_at < yesterday_next)
                )).scalar() or 0
                if y_count > 0:
                    streak_days = 1
                    check_date -= timedelta(days=1)
                    continue
            break

    return StatsOut(
        total_sessions=total_sessions,
        total_turns=total_turns,
        total_mistakes=total_mistakes,
        cards_due_today=cards_due_today,
        total_cards=total_cards,
        streak_days=streak_days,
        mistakes_by_category=mistakes_by_category,
        weekly_activity=weekly_activity
    )

@router.get("/weekly-report", response_model=WeeklyReportOut)
async def get_weekly_report(
    db: AsyncSession = Depends(get_db),
    current_user: str = Depends(get_current_user)
):
    now = datetime.now(timezone.utc)
    week_start = now - timedelta(days=7)
    prev_week_start = now - timedelta(days=14)
    week_range = f"{week_start.strftime('%d %b %Y')} - {now.strftime('%d %b %Y')}"

    # Counts in the last 7 days
    sess_count = (await db.execute(
        select(func.count(Session.id)).where(Session.started_at >= week_start)
    )).scalar() or 0

    turns_res = await db.execute(
        select(Turn).where(Turn.created_at >= week_start)
    )
    turns = turns_res.scalars().all()
    turn_count = len(turns)

    mistakes_res = await db.execute(
        select(Mistake).where(Mistake.timestamp >= week_start).order_by(Mistake.timestamp.desc())
    )
    mistakes = mistakes_res.scalars().all()
    mistakes_this_week = len(mistakes)

    # Mistakes previous week (7 to 14 days ago)
    prev_mistakes_res = await db.execute(
        select(func.count(Mistake.id)).where(
            Mistake.timestamp >= prev_week_start,
            Mistake.timestamp < week_start
        )
    )
    mistakes_last_week = prev_mistakes_res.scalar() or 0

    # Delta comparison
    diff = mistakes_this_week - mistakes_last_week
    if mistakes_last_week == 0:
        comparison_text = f"{mistakes_this_week} errores esta semana (línea base nueva)"
    elif diff < 0:
        comparison_text = f"🟢 Reducción de {abs(diff)} errores respecto a la semana previa ({mistakes_this_week} vs {mistakes_last_week})"
    elif diff > 0:
        comparison_text = f"🟡 Aumento de {diff} errores respecto a la semana previa ({mistakes_this_week} vs {mistakes_last_week})"
    else:
        comparison_text = f"⚪ Mismo nivel de errores que la semana anterior ({mistakes_this_week})"

    # Categories breakdown
    cats: dict[str, int] = {}
    for m in mistakes:
        cats[m.category] = cats.get(m.category, 0) + 1

    # Mistakes sample
    mistake_lines = []
    for m in mistakes[:8]:
        mistake_lines.append(f"- **Error:** *\"{m.original}\"*  \n  **Corrección:** `{m.correction}`  \n  **Regla:** {m.explanation}")

    mistakes_md = "\n".join(mistake_lines) if mistake_lines else "- *¡Sin errores registrados esta semana! Excelente trabajo.*"

    md_report = f"""# 📊 Informe Semanal de Progreso - English Brain
**Período:** {week_range}  
**Generado:** {now.strftime('%Y-%m-%d %H:%M:%S UTC')}  

---

## 🎯 Resumen Ejecutivo
- **Sesiones de entrevista completadas:** {sess_count}
- **Respuestas orales grabadas (Turns):** {turn_count}
- **Errores detectados esta semana:** {mistakes_this_week}
- **Comparativa con semana anterior:** {comparison_text}
- **Desglose de áreas a reforzar:** {', '.join([f'{k.capitalize()}: {v}' for k, v in cats.items()]) if cats else 'N/A'}

---

## 📝 Puntos Clave & Errores Frecuentes
{mistakes_md}

---

## 🚀 Próximos Pasos (Semana Siguiente)
1. Repasar las tarjetas pendientes del mazo **FSRS** para consolidar la curva del olvido.
2. Enfocar las próximas respuestas en expandir respuestas usando el método **STAR** (Situation, Task, Action, Result).
3. Mantener la racha diaria de al menos 15 minutos de práctica hablada.
"""

    return WeeklyReportOut(
        week_range=week_range,
        generated_at=now,
        total_sessions=sess_count,
        total_turns=turn_count,
        total_mistakes=mistakes_this_week,
        mistakes_this_week=mistakes_this_week,
        mistakes_last_week=mistakes_last_week,
        markdown_report=md_report.strip()
    )
