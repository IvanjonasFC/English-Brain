"""
Router /api/content — pipeline de contenido con procedencia, revisión y snapshots.

Estados: raw -> normalized -> reviewed -> published (o rejected).
Endpoints:
  POST /api/content/ingest        — ingesta batch (CSV/JSON o salida del LLM) a 'normalized'
  GET  /api/content/pending       — items 'normalized' pendientes de revisión
  POST /api/content/{id}/review   — aprobar/editar CEFR/rechazar (gate humano)
  POST /api/content/publish       — publica 'reviewed' en un snapshot versionado
  GET  /api/content/latest        — último snapshot publicado (manifest + items)
  GET  /api/content/delta?since=vN— delta para sincronización offline
"""
import json
import logging
from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.models import ContentItem
from app.routers.auth import get_current_user
from app.content_pipeline import (
    BatchIngestIn,
    ContentItemOut,
    ContentItemReviewIn,
    ContentWorkflowService,
)

logger = logging.getLogger("english_brain.content")
router = APIRouter(prefix="/content", tags=["content"])


def _to_out(it: ContentItem) -> ContentItemOut:
    return ContentItemOut(
        id=it.id,
        content_type=it.content_type,
        status=it.status,
        cefr=it.cefr,
        scenario=it.scenario,
        objective=it.objective,
        difficulty=it.difficulty,
        source_type=it.source_type,
        payload=json.loads(it.payload_json) if it.payload_json else {},
        source_origin=it.source_origin,
        source_url=it.source_url,
        license=it.license,
        imported_at=it.imported_at,
        reviewed_by=it.reviewed_by,
        review_notes=it.review_notes,
        reviewed_at=it.reviewed_at,
        snapshot_version=it.snapshot_version,
        created_at=it.created_at,
        updated_at=it.updated_at,
    )


@router.post("/ingest")
async def ingest_content(
    batch: BatchIngestIn,
    db: AsyncSession = Depends(get_db),
    current_user: str = Depends(get_current_user),
):
    """Ingesta un batch a estado 'normalized' (nunca directo a published)."""
    svc = ContentWorkflowService(db)
    result = await svc.ingest_batch(batch)
    return result


@router.get("/pending", response_model=list[ContentItemOut])
async def pending_content(
    content_type: Optional[str] = Query(None),
    scenario: Optional[str] = Query(None),
    db: AsyncSession = Depends(get_db),
    current_user: str = Depends(get_current_user),
):
    """Lista los items 'normalized' esperando revisión humana."""
    svc = ContentWorkflowService(db)
    items = await svc.list_pending(content_type=content_type, scenario=scenario)
    return [_to_out(it) for it in items]


@router.post("/{item_id}/review", response_model=ContentItemOut)
async def review_content(
    item_id: str,
    review: ContentItemReviewIn,
    db: AsyncSession = Depends(get_db),
    current_user: str = Depends(get_current_user),
):
    """Gate humano: aprobar (exige CEFR), editar o rechazar un item."""
    svc = ContentWorkflowService(db)
    ok, error, item = await svc.review_item(item_id, review)
    if not ok or item is None:
        raise HTTPException(status_code=400, detail=error or "Review failed")
    return _to_out(item)


@router.post("/publish")
async def publish_content(
    bump_type: str = Query("minor", description="major | minor | patch"),
    custom_version: Optional[str] = Query(None),
    db: AsyncSession = Depends(get_db),
    current_user: str = Depends(get_current_user),
):
    """Publica todos los 'reviewed' en un snapshot versionado."""
    svc = ContentWorkflowService(db)
    snapshot, manifest = await svc.publish_snapshot(
        bump_type=bump_type, custom_version=custom_version
    )
    return {"version": snapshot.version, "manifest": manifest}


@router.get("/latest")
async def latest_content(
    db: AsyncSession = Depends(get_db),
    current_user: str = Depends(get_current_user),
):
    """Último snapshot publicado: manifest + items (para primera carga)."""
    svc = ContentWorkflowService(db)
    latest = await svc.get_latest_snapshot()
    if not latest:
        return {"version": None, "manifest": None, "items": []}
    snapshot, manifest, items = latest
    return {"version": snapshot.version, "manifest": manifest, "items": items}


@router.get("/delta")
async def delta_content(
    since: Optional[str] = Query(None, description="Versión local del cliente, p.ej. v1.0.0"),
    db: AsyncSession = Depends(get_db),
    current_user: str = Depends(get_current_user),
):
    """Delta entre la versión local del cliente y el último snapshot."""
    svc = ContentWorkflowService(db)
    return await svc.get_delta(since)

@router.post("/bootstrap")
async def bootstrap_from_questions(
    db: AsyncSession = Depends(get_db),
    current_user: str = Depends(get_current_user),
):
    """Carga las preguntas de entrevista existentes al pipeline (como contenido
    propio ya revisado) y publica un primer snapshot. Idempotente."""
    from datetime import datetime, timezone
    from sqlalchemy import select
    from app.models import Question

    res = await db.execute(select(Question))
    questions = res.scalars().all()
    cefr_map = {"junior": "B1", "mid": "B2", "senior": "C1"}
    created = 0
    for q in questions:
        cid = f"q_{q.id}"
        exists = await db.execute(select(ContentItem).where(ContentItem.id == cid))
        if exists.scalar_one_or_none():
            continue
        item = ContentItem(
            id=cid,
            content_type="interview_question",
            status="reviewed",
            cefr=(q.difficulty_band or cefr_map.get((q.difficulty or "mid").lower(), "B2")),
            scenario=(q.scenario or q.category),
            objective=q.objective_id,
            difficulty=q.difficulty or "mid",
            source_type="interview",
            payload_json=json.dumps({
                "title": q.title,
                "prompt": q.text,
                "model_answer": q.model_answer,
                "tips": q.tips,
            }),
            source_origin="original",
            license="own",
            reviewed_by=current_user,
            review_notes="bootstrap import",
            reviewed_at=datetime.now(timezone.utc),
        )
        db.add(item)
        created += 1

    await db.commit()

    if created == 0:
        return {"created": 0, "note": "Ya estaba bootstrapeado (sin nuevos)."}

    try:
        svc = ContentWorkflowService(db)
        snapshot, manifest = await svc.publish_snapshot(bump_type="minor")
        return {"created": created, "published_version": snapshot.version, "manifest": manifest}
    except Exception as exc:  # noqa: BLE001
        logger.warning("bootstrap publish failed: %s", exc)
        return {"created": created, "published_version": None, "error": str(exc)}

