import json
import os
from typing import Optional, List
from fastapi import APIRouter, Depends, HTTPException, Query
from pydantic import BaseModel
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.models import (
    ExternalResource,
    ResourceCollection,
    UnitResourceLink,
    PublishedSnapshot,
    ResourceUsageLog,
)
from app.resources.pipeline import run_full_pipeline, SNAPSHOT_PATH

router = APIRouter(prefix="/api/resources", tags=["resources"])


class ResourceUsageIn(BaseModel):
    resource_id: str
    unit_id: Optional[str] = None
    event_type: str = "open"  # open, completed, bookmark, audio_play
    duration_seconds: int = 0
    user_id: str = "default_user"


@router.get("/sync/snapshot")
async def get_latest_snapshot(db: AsyncSession = Depends(get_db)):
    """
    Returns the latest published JSON snapshot for offline-first local synchronization.
    """
    res = await db.execute(
        select(PublishedSnapshot).order_by(PublishedSnapshot.created_at.desc())
    )
    latest = res.scalars().first()
    if latest:
        return json.loads(latest.snapshot_json)

    # Fallback to local snapshot file if DB record not found
    if os.path.exists(SNAPSHOT_PATH):
        with open(SNAPSHOT_PATH, "r", encoding="utf-8") as f:
            return json.load(f)

    raise HTTPException(status_code=404, detail="No published snapshot available")


@router.get("/collections")
async def list_collections(db: AsyncSession = Depends(get_db)):
    """
    Returns all curated resource collections.
    """
    res = await db.execute(
        select(ResourceCollection).order_by(ResourceCollection.order_index)
    )
    collections = res.scalars().all()
    return [
        {
            "id": c.id,
            "name": c.name,
            "description": c.description,
            "icon": c.icon,
            "color": c.color,
            "order_index": c.order_index,
        }
        for c in collections
    ]


@router.get("")
async def list_resources(
    collection_id: Optional[str] = None,
    skill: Optional[str] = None,
    domain: Optional[str] = None,
    level: Optional[str] = None,
    unit_id: Optional[str] = None,
    pack_id: Optional[str] = None,
    limit: int = Query(50, ge=1, le=200),
    db: AsyncSession = Depends(get_db),
):
    """
    Filtered query of published companion resources.
    """
    query = select(ExternalResource).filter(ExternalResource.status == "published")

    if collection_id:
        query = query.filter(ExternalResource.collection_id == collection_id)
    if skill:
        query = query.filter(ExternalResource.skill == skill)
    if domain:
        query = query.filter(ExternalResource.domain == domain)
    if level:
        query = query.filter(ExternalResource.level == level)

    if unit_id or pack_id:
        target_id = unit_id or pack_id
        target_type = "unit" if unit_id else "pack"
        subq = select(UnitResourceLink.resource_id).filter(
            UnitResourceLink.target_type == target_type,
            UnitResourceLink.target_id == target_id,
        )
        query = query.filter(ExternalResource.id.in_(subq))

    query = query.limit(limit)
    res = await db.execute(query)
    resources = res.scalars().all()

    return [
        {
            "id": r.id,
            "title": r.title,
            "original_url": r.original_url,
            "source_name": r.source_name,
            "resource_type": r.resource_type,
            "skill": r.skill,
            "domain": r.domain,
            "level": r.level,
            "tags": json.loads(r.tags) if r.tags else [],
            "transcript_available": r.transcript_available,
            "spanish_support": r.spanish_support,
            "estimated_minutes": r.estimated_minutes,
            "recommended_for": r.recommended_for,
            "spanish_notes": r.spanish_notes,
            "collection_id": r.collection_id,
        }
        for r in resources
    ]


@router.post("/pipeline/run")
async def trigger_pipeline(
    force_refresh: bool = False, db: AsyncSession = Depends(get_db)
):
    """
    Triggers the 5-phase curation and export pipeline.
    """
    try:
        result = await run_full_pipeline(db, force_refresh=force_refresh)
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Pipeline failed: {str(e)}")


@router.post("/usage")
async def log_resource_usage(
    payload: ResourceUsageIn, db: AsyncSession = Depends(get_db)
):
    """
    Logs user interaction telemetry with companion resources.
    """
    log = ResourceUsageLog(
        user_id=payload.user_id,
        resource_id=payload.resource_id,
        unit_id=payload.unit_id,
        event_type=payload.event_type,
        duration_seconds=payload.duration_seconds,
    )
    db.add(log)
    await db.commit()
    return {"status": "logged", "id": log.id}
