import json
import hashlib
from datetime import datetime, timezone
from typing import List, Dict, Any, Optional, Tuple
from sqlalchemy import select, update, or_
from sqlalchemy.ext.asyncio import AsyncSession

from app.models import ContentItem, ContentSnapshot
from .schemas import (
    ContentItemIn,
    ContentItemReviewIn,
    BatchIngestIn,
    BatchIngestResult,
    ContentManifest,
    ContentDeltaResponse,
)
from .validator import ContentValidator


def utc_now():
    return datetime.now(timezone.utc)


class ContentWorkflowService:
    """
    Orchestrates the 5-state pipeline:
    source -> raw -> normalized -> reviewed -> published
    """

    def __init__(self, db: AsyncSession):
        self.db = db

    async def ingest_batch(self, batch: BatchIngestIn) -> BatchIngestResult:
        """
        Ingests items into state 'normalized'. Never directly to 'published'.
        """
        errors = []
        normalized_count = 0

        for item in batch.items:
            try:
                origin = item.origin
                source_origin = origin.source if origin else "generated"
                source_url = origin.sourceUrl if origin else None
                license_val = origin.license if origin else "own"
                imported_at = datetime.fromisoformat(origin.importedAt) if origin and origin.importedAt else utc_now()
                reviewed_by = origin.reviewedBy if origin else None
                review_notes = origin.reviewNotes if origin else None

                # Pre-validate license
                lic_res = ContentValidator.validate_license(license_val, item.payload, source_url)
                if not lic_res.is_valid:
                    errors.append(f"Item '{item.id}': {'; '.join(lic_res.errors)}")
                    continue

                # Check if exists
                stmt = select(ContentItem).where(ContentItem.id == item.id)
                res = await self.db.execute(stmt)
                existing = res.scalars().first()

                if existing:
                    # Update normalized payload if not already published
                    if existing.status in {"raw", "normalized", "rejected"}:
                        existing.content_type = item.type
                        existing.cefr = item.cefr
                        existing.scenario = item.scenario
                        existing.objective = item.objective
                        existing.difficulty = item.difficulty
                        existing.source_type = item.source_type
                        existing.payload_json = json.dumps(item.payload, ensure_ascii=False)
                        existing.source_origin = source_origin
                        existing.source_url = source_url
                        existing.license = license_val
                        existing.status = "normalized"
                        existing.updated_at = utc_now()
                        normalized_count += 1
                else:
                    new_item = ContentItem(
                        id=item.id,
                        content_type=item.type,
                        status="normalized",
                        cefr=item.cefr,
                        scenario=item.scenario,
                        objective=item.objective,
                        difficulty=item.difficulty,
                        source_type=item.source_type,
                        payload_json=json.dumps(item.payload, ensure_ascii=False),
                        source_origin=source_origin,
                        source_url=source_url,
                        license=license_val,
                        imported_at=imported_at,
                        reviewed_by=reviewed_by,
                        review_notes=review_notes,
                        created_at=utc_now(),
                        updated_at=utc_now(),
                    )
                    self.db.add(new_item)
                    normalized_count += 1

            except Exception as e:
                errors.append(f"Item '{item.id}': {str(e)}")

        await self.db.commit()
        return BatchIngestResult(
            total_received=len(batch.items),
            normalized_count=normalized_count,
            errors=errors,
        )

    async def list_pending(
        self, content_type: Optional[str] = None, scenario: Optional[str] = None
    ) -> List[ContentItem]:
        """
        Lists items waiting in 'normalized' status for review.
        """
        stmt = select(ContentItem).where(ContentItem.status == "normalized")
        if content_type:
            stmt = stmt.where(ContentItem.content_type == content_type)
        if scenario:
            stmt = stmt.where(ContentItem.scenario == scenario)
        stmt = stmt.order_by(ContentItem.imported_at.asc())
        res = await self.db.execute(stmt)
        return list(res.scalars().all())

    async def review_item(self, item_id: str, review: ContentItemReviewIn) -> Tuple[bool, Optional[str], Optional[ContentItem]]:
        """
        Human Review Gate:
        - Must pass CEFR validation to approve.
        - Sets reviewedBy, timestamp, and transitions state to 'reviewed' or 'rejected'.
        """
        stmt = select(ContentItem).where(ContentItem.id == item_id)
        res = await self.db.execute(stmt)
        item = res.scalars().first()
        if not item:
            return False, f"ContentItem '{item_id}' not found.", None

        if review.action == "reject":
            item.status = "rejected"
            item.reviewed_by = review.reviewed_by
            item.review_notes = review.review_notes or "Rejected during review."
            item.reviewed_at = utc_now()
            item.updated_at = utc_now()
            await self.db.commit()
            return True, None, item

        if review.action == "approve":
            target_cefr = review.cefr or item.cefr
            cefr_res = ContentValidator.validate_cefr(target_cefr, strict=True)
            if not cefr_res.is_valid:
                return False, f"Cannot approve without valid CEFR level: {'; '.join(cefr_res.errors)}", item

            item.cefr = target_cefr.strip().upper()
            if review.scenario:
                item.scenario = review.scenario
            if review.difficulty:
                item.difficulty = review.difficulty
            if review.edited_payload:
                item.payload_json = json.dumps(review.edited_payload, ensure_ascii=False)

            item.status = "reviewed"
            item.reviewed_by = review.reviewed_by
            item.review_notes = review.review_notes
            item.reviewed_at = utc_now()
            item.updated_at = utc_now()
            await self.db.commit()
            return True, None, item

        return False, f"Unknown action '{review.action}'. Must be 'approve' or 'reject'.", item

    async def publish_snapshot(self, bump_type: str = "minor", custom_version: Optional[str] = None) -> Tuple[ContentSnapshot, ContentManifest]:
        """
        Transitions all 'reviewed' items into 'published' and packages them into a versioned snapshot.
        """
        # Find latest snapshot version
        latest_stmt = select(ContentSnapshot).order_by(ContentSnapshot.created_at.desc())
        latest_res = await self.db.execute(latest_stmt)
        latest_snap = latest_res.scalars().first()

        new_version = custom_version or self._bump_version(latest_snap.version if latest_snap else "v1.0.0", bump_type)

        # Update reviewed items to published with this snapshot version
        update_stmt = (
            update(ContentItem)
            .where(ContentItem.status == "reviewed")
            .values(status="published", snapshot_version=new_version, updated_at=utc_now())
        )
        await self.db.execute(update_stmt)
        await self.db.commit()

        # Collect all published items
        all_published_stmt = select(ContentItem).where(ContentItem.status == "published").order_by(ContentItem.id.asc())
        pub_res = await self.db.execute(all_published_stmt)
        all_published = list(pub_res.scalars().all())

        # Build payload array
        snapshot_list = []
        counts: Dict[str, int] = {}
        for it in all_published:
            counts[it.content_type] = counts.get(it.content_type, 0) + 1
            payload = json.loads(it.payload_json)
            snapshot_list.append({
                "id": it.id,
                "type": it.content_type,
                "cefr": it.cefr,
                "scenario": it.scenario,
                "objective": it.objective,
                "difficulty": it.difficulty,
                "sourceType": it.source_type,
                "payload": payload,
                "origin": {
                    "source": it.source_origin,
                    "sourceUrl": it.source_url,
                    "license": it.license,
                    "importedAt": it.imported_at.isoformat() if it.imported_at else None,
                    "reviewedBy": it.reviewed_by,
                    "reviewNotes": it.review_notes,
                },
                "snapshotVersion": it.snapshot_version,
                "updatedAt": it.updated_at.isoformat() if it.updated_at else None,
            })

        snapshot_str = json.dumps(snapshot_list, ensure_ascii=False, sort_keys=True)
        sha256_hash = hashlib.sha256(snapshot_str.encode("utf-8")).hexdigest()

        manifest = ContentManifest(
            version=new_version,
            created_at=utc_now().isoformat(),
            sha256_hash=sha256_hash,
            item_counts=counts,
            total_items=len(snapshot_list),
        )

        snapshot_record = ContentSnapshot(
            id=f"snap_{new_version}",
            version=new_version,
            sha256_hash=sha256_hash,
            manifest_json=manifest.model_dump_json(),
            snapshot_json=snapshot_str,
            item_count=len(snapshot_list),
            created_at=utc_now(),
        )
        self.db.add(snapshot_record)
        await self.db.commit()

        return snapshot_record, manifest

    async def get_latest_snapshot(self) -> Optional[Tuple[ContentSnapshot, ContentManifest, List[Dict[str, Any]]]]:
        stmt = select(ContentSnapshot).order_by(ContentSnapshot.created_at.desc())
        res = await self.db.execute(stmt)
        snap = res.scalars().first()
        if not snap:
            return None

        manifest = ContentManifest.model_validate_json(snap.manifest_json)
        items = json.loads(snap.snapshot_json)
        return snap, manifest, items

    async def get_delta(self, since_version: Optional[str]) -> ContentDeltaResponse:
        """
        Calculates delta between client's `since_version` and current latest snapshot.
        """
        latest = await self.get_latest_snapshot()
        if not latest:
            empty_manifest = ContentManifest(
                version="v0.0.0",
                created_at=utc_now().isoformat(),
                sha256_hash="",
                item_counts={},
                total_items=0,
            )
            return ContentDeltaResponse(
                current_version="v0.0.0",
                since_version=since_version,
                has_update=False,
                manifest=empty_manifest,
                added=[],
                updated=[],
                removed_ids=[],
            )

        snap, manifest, latest_items = latest

        if not since_version:
            # First sync: all latest items are 'added'
            return ContentDeltaResponse(
                current_version=manifest.version,
                since_version=None,
                has_update=True,
                manifest=manifest,
                added=latest_items,
                updated=[],
                removed_ids=[],
            )

        if since_version == manifest.version:
            # Client already on current version
            return ContentDeltaResponse(
                current_version=manifest.version,
                since_version=since_version,
                has_update=False,
                manifest=manifest,
                added=[],
                updated=[],
                removed_ids=[],
            )

        # Retrieve client's snapshot to perform delta diff
        stmt_since = select(ContentSnapshot).where(ContentSnapshot.version == since_version)
        res_since = await self.db.execute(stmt_since)
        since_snap = res_since.scalars().first()

        old_items_dict: Dict[str, Dict[str, Any]] = {}
        if since_snap:
            for it in json.loads(since_snap.snapshot_json):
                old_items_dict[it["id"]] = it

        latest_items_dict = {it["id"]: it for it in latest_items}

        added = []
        updated = []
        for item_id, item in latest_items_dict.items():
            if item_id not in old_items_dict:
                added.append(item)
            elif old_items_dict[item_id] != item:
                updated.append(item)

        removed_ids = [item_id for item_id in old_items_dict if item_id not in latest_items_dict]

        return ContentDeltaResponse(
            current_version=manifest.version,
            since_version=since_version,
            has_update=bool(added or updated or removed_ids),
            manifest=manifest,
            added=added,
            updated=updated,
            removed_ids=removed_ids,
        )

    def _bump_version(self, current: str, bump_type: str = "minor") -> str:
        clean = current.lstrip("v")
        parts = clean.split(".")
        major = int(parts[0]) if len(parts) > 0 and parts[0].isdigit() else 1
        minor = int(parts[1]) if len(parts) > 1 and parts[1].isdigit() else 0
        patch = int(parts[2]) if len(parts) > 2 and parts[2].isdigit() else 0

        if bump_type == "major":
            major += 1
            minor = 0
            patch = 0
        elif bump_type == "patch":
            patch += 1
        else:  # minor
            minor += 1
            patch = 0

        return f"v{major}.{minor}.{patch}"
