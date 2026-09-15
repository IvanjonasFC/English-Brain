"""Sistema genérico y extensible de medidas de voz del usuario.

Registra CUALQUIER métrica de voz (pronunciación, speaking, y a futuro pitch/F0,
fluidez, etc.) en cualquier zona (vocabulario, gramática, comprensión, entrevista,
o zonas nuevas) y mantiene un snapshot de baseline por (usuario, zona, target, métrica):
Día 1 (baseline), último (hoy) y mejor marca, para la comparación 'Día 1 vs Hoy'.

Extensibilidad: añadir una métrica nueva = pasar un metric_key nuevo (opcionalmente
registrarlo en METRIC_HIGHER_IS_BETTER si 'menos es mejor'). No requiere migración.
"""
import json
import logging
from typing import Optional

from fastapi import APIRouter, Depends
from pydantic import BaseModel
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.models import UserVoiceMeasurement, UserVoiceBaseline, utc_now

logger = logging.getLogger("english_brain.measurements")
router = APIRouter(prefix="/measurements", tags=["measurements"])

# Métricas donde una nota MÁS ALTA es mejor. Para una futura donde 'menos es mejor'
# (p.ej. error_ms, reaction_ms), regístrala aquí con False y todo lo demás funciona igual.
METRIC_HIGHER_IS_BETTER = {
    "pronunciation_gop": True,
    "speaking_score": True,
    "pitch_similarity": True,
    "fluency_score": True,
}


def _higher_is_better(metric_key: str) -> bool:
    return METRIC_HIGHER_IS_BETTER.get(metric_key, True)


def _baseline_id(user_id: str, zone: str, target_id: str, metric_key: str) -> str:
    return f"{user_id}:{zone}:{target_id}:{metric_key}"


class MeasurementIn(BaseModel):
    user_id: str
    zone: str
    target_id: str
    metric_key: str = "pronunciation_gop"
    value: float
    target_type: str = "word"
    audio_path: Optional[str] = None  # ruta relativa servida en /audio/... (opcional)
    label: Optional[str] = None
    extra: Optional[dict] = None


def _comparison_payload(row: UserVoiceBaseline) -> dict:
    delta = round((row.latest_value or 0.0) - (row.baseline_value or 0.0), 1)
    return {
        "has_baseline": True,
        "id": row.id,
        "zone": row.zone,
        "target_type": row.target_type,
        "target_id": row.target_id,
        "metric_key": row.metric_key,
        "label": row.label,
        "attempts": row.attempts or 0,
        "baseline_value": row.baseline_value,
        "baseline_audio_url": row.baseline_audio_path,
        "baseline_created_at": row.baseline_created_at.isoformat() if row.baseline_created_at else None,
        "latest_value": row.latest_value,
        "latest_audio_url": row.latest_audio_path,
        "latest_updated_at": row.latest_updated_at.isoformat() if row.latest_updated_at else None,
        "best_value": row.best_value,
        "best_audio_url": row.best_audio_path,
        "delta_value": delta,
    }


@router.post("")
async def record_measurement(body: MeasurementIn, db: AsyncSession = Depends(get_db)):
    """Registra una medida (historial append-only) y actualiza el snapshot de baseline."""
    now = utc_now()
    extra_str = json.dumps(body.extra) if body.extra else None

    # 1) Historial completo (soporta evolución continua y métricas futuras)
    db.add(UserVoiceMeasurement(
        user_id=body.user_id, zone=body.zone, target_type=body.target_type,
        target_id=body.target_id, metric_key=body.metric_key, value=body.value,
        audio_path=body.audio_path, extra_json=extra_str, created_at=now,
    ))

    # 2) Snapshot baseline (Día 1 / Hoy / mejor)
    bid = _baseline_id(body.user_id, body.zone, body.target_id, body.metric_key)
    row = (await db.execute(
        select(UserVoiceBaseline).where(UserVoiceBaseline.id == bid)
    )).scalar_one_or_none()
    hib = _higher_is_better(body.metric_key)

    try:
        if row is None:
            row = UserVoiceBaseline(
                id=bid, user_id=body.user_id, zone=body.zone, target_type=body.target_type,
                target_id=body.target_id, metric_key=body.metric_key, label=body.label,
                baseline_value=body.value, baseline_audio_path=body.audio_path, baseline_created_at=now,
                latest_value=body.value, latest_audio_path=body.audio_path, latest_updated_at=now,
                best_value=body.value, best_audio_path=body.audio_path, best_updated_at=now,
                attempts=1, extra_json=extra_str,
            )
            db.add(row)
            await db.commit()
            payload = _comparison_payload(row)
            payload["is_initial"] = True
            return payload

        row.latest_value = body.value
        row.latest_audio_path = body.audio_path
        row.latest_updated_at = now
        row.attempts = (row.attempts or 0) + 1
        if body.label and not row.label:
            row.label = body.label
        is_best = (row.best_value is None) or (
            body.value > row.best_value if hib else body.value < row.best_value
        )
        if is_best:
            row.best_value = body.value
            row.best_audio_path = body.audio_path
            row.best_updated_at = now
        await db.commit()
        payload = _comparison_payload(row)
        payload["is_initial"] = False
        return payload
    except Exception as e:
        await db.rollback()
        logger.warning(f"No se pudo registrar la medida: {e}")
        return {"has_baseline": False, "is_initial": False, "delta_value": 0.0, "error": True}


@router.get("/baseline")
async def get_baseline(
    user_id: str, zone: str, target_id: str,
    metric_key: str = "pronunciation_gop",
    db: AsyncSession = Depends(get_db),
):
    """Comparación 'Día 1 vs Hoy' de un ítem concreto."""
    bid = _baseline_id(user_id, zone, target_id, metric_key)
    row = (await db.execute(
        select(UserVoiceBaseline).where(UserVoiceBaseline.id == bid)
    )).scalar_one_or_none()
    if not row:
        return {"has_baseline": False}
    return _comparison_payload(row)


@router.get("/profile/{user_id}")
async def get_profile(user_id: str, db: AsyncSession = Depends(get_db)):
    """Resumen para el perfil: por zona y métrica, media actual, delta media y mejores mejoras."""
    rows = (await db.execute(
        select(UserVoiceBaseline).where(UserVoiceBaseline.user_id == user_id)
    )).scalars().all()

    zones: dict = {}
    for r in rows:
        z = zones.setdefault(r.zone, {})
        m = z.setdefault(r.metric_key, {"count": 0, "sum_latest": 0.0, "sum_delta": 0.0, "items": []})
        m["count"] += 1
        m["sum_latest"] += (r.latest_value or 0.0)
        m["sum_delta"] += round((r.latest_value or 0.0) - (r.baseline_value or 0.0), 1)
        m["items"].append(_comparison_payload(r))

    summary = []
    for zone, metrics in zones.items():
        for metric_key, m in metrics.items():
            cnt = m["count"] or 1
            items_sorted = sorted(m["items"], key=lambda x: x["delta_value"], reverse=True)
            summary.append({
                "zone": zone,
                "metric_key": metric_key,
                "targets": m["count"],
                "avg_latest": round(m["sum_latest"] / cnt, 1),
                "avg_delta": round(m["sum_delta"] / cnt, 1),
                "top_improvements": items_sorted[:5],
            })
    summary.sort(key=lambda x: (x["zone"], x["metric_key"]))
    return {"user_id": user_id, "summary": summary}
